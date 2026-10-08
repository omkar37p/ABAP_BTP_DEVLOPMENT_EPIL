CLASS zcl_sd_sloc_vh_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_sd_sloc_vh_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA lt_remote TYPE zsd_s4_sloc_scm=>tyt_storage_location_type.

    " --- part 1: client proxy, as in the query class ---
    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                 comm_scenario = 'ZMMGE_S4_PLANT_CS'
                                 service_id    = 'ZMMGE_S4_PLANT_REST' ).
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

        DATA(lo_proxy) = /iwbep/cl_cp_factory_remote=>create_v4_remote_proxy(
                           is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                               proxy_model_id      = 'ZSD_S4_SLOC_SCM'
                                                               proxy_model_version = '0001' )
                           io_http_client           = lo_http_client
                           iv_relative_service_root = '/sap/opu/odata4/sap/zsd_api_sloc_o2/srvd_a2x/sap/zsd_sd_sloc/0001/' ).

        DATA(lo_read) = lo_proxy->create_resource_for_entity_set( 'STORAGE_LOCATION' )->create_request_for_read( ).
        lo_read->set_top( 10 ).
        lo_read->request_count( ).
        DATA(lo_response) = lo_read->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = lt_remote ).

        out->write( |Proxy: count = { lo_response->get_count( ) }, rows read = { lines( lt_remote ) }| ).
        LOOP AT lt_remote INTO DATA(ls_row).
          out->write( |  { ls_row-plant } / { ls_row-storagelocation } / { ls_row-storagelocationname }| ).
        ENDLOOP.

      CATCH cx_root INTO DATA(lx_proxy).
        out->write( |Proxy error: { lx_proxy->get_text( ) }| ).
        DATA(lx_prev) = lx_proxy->previous.
        WHILE lx_prev IS BOUND.
          out->write( |  caused by: { lx_prev->get_text( ) }| ).
          lx_prev = lx_prev->previous.
        ENDWHILE.
    ENDTRY.

    " --- part 2: plain HTTP GET ---
    TRY.
        DATA(lo_dest2)   = cl_http_destination_provider=>create_by_comm_arrangement(
                             comm_scenario = 'ZMMGE_S4_PLANT_CS'
                             service_id    = 'ZMMGE_S4_PLANT_REST' ).
        DATA(lo_client2) = cl_web_http_client_manager=>create_by_http_destination( lo_dest2 ).
        lo_client2->get_http_request( )->set_uri_path(
          `/sap/opu/odata4/sap/zsd_api_sloc_o2/srvd_a2x/sap/zsd_sd_sloc/0001/StorageLocation?$top=3` ).
        DATA(lo_resp2) = lo_client2->execute( if_web_http_client=>get ).
        DATA(ls_status) = lo_resp2->get_status( ).
        out->write( |HTTP GET: { ls_status-code } { ls_status-reason }| ).
        DATA(lv_body) = lo_resp2->get_text( ).
        out->write( substring( val = lv_body len = nmin( val1 = 1500 val2 = strlen( lv_body ) ) ) ).
      CATCH cx_root INTO DATA(lx_http).
        out->write( |HTTP error: { lx_http->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

