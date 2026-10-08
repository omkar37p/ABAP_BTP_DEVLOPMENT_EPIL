CLASS zcl_ge_adobe_diag DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_ge_adobe_diag IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                 comm_scenario = 'ZADS_CS'
                                 service_id    = 'ZADS_OUT_REST' ).
      CATCH cx_http_dest_provider_error INTO DATA(lx_dest).
        out->write( |Destination error: { lx_dest->get_text( ) }| ).
        RETURN.
    ENDTRY.

    LOOP AT VALUE string_table( ( `/` )
                                ( `/v1/forms` )
                                ( `/v1/forms/ZSD_WEIGHT_SLIP` ) ) INTO DATA(lv_path).
      TRY.
          DATA(lo_client)  = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
          DATA(lo_request) = lo_client->get_http_request( ).
          lo_request->set_uri_path( lv_path ).
          lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).

          DATA(lo_response) = lo_client->execute( if_web_http_client=>get ).
          DATA(ls_status)   = lo_response->get_status( ).
          DATA(lv_body)     = lo_response->get_text( ).

          out->write( |--- GET { lv_path }: HTTP { ls_status-code } { ls_status-reason }| ).
          out->write( |WWW-Authenticate: { lo_response->get_header_field( 'www-authenticate' ) }| ).
          out->write( |Body: { substring( val = lv_body len = nmin( val1 = strlen( lv_body ) val2 = 600 ) ) }| ).
          lo_client->close( ).

        CATCH cx_web_http_client_error cx_web_message_error INTO DATA(lx_http).
          out->write( |--- GET { lv_path }: client error { lx_http->get_text( ) }| ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

