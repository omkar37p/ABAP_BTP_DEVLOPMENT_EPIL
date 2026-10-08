CLASS zcl_ge_adobe_pdf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Renders form/template with the given data XML (UTF-8).
    "! Raises zcx_fp_tmpl_store_error with the HTTP status on failure.
    CLASS-METHODS render
      IMPORTING iv_form_name     TYPE string
                iv_template_name TYPE string
                iv_xml_data      TYPE xstring
                iv_locale        TYPE string DEFAULT `en_US`
      RETURNING VALUE(rv_pdf)    TYPE xstring
      RAISING   zcx_fp_tmpl_store_error.
ENDCLASS.


CLASS zcl_ge_adobe_pdf IMPLEMENTATION.

  METHOD render.
    TYPES: BEGIN OF ty_request,
             xdp_template TYPE string,
             xml_data     TYPE string,
             form_type    TYPE string,
             form_locale  TYPE string,
             tagged_pdf   TYPE i,
             embed_font   TYPE i,
           END OF ty_request,
           BEGIN OF ty_response,
             file_name    TYPE string,
             file_content TYPE string,
           END OF ty_response.
    DATA ls_response TYPE ty_response.

    TRY.
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination(
                            cl_http_destination_provider=>create_by_comm_arrangement(
                              comm_scenario = 'ZADS_CS'
                              service_id    = 'ZADS_OUT_REST' ) ).

        " throw-away first request (BTP refuses the first one with 403)
        TRY.
            lo_client->get_http_request( )->set_uri_path( |/v1/forms/ZZ_PRIME| ).
            lo_client->execute( if_web_http_client=>get ).
          CATCH cx_web_http_client_error.
            " ignore
        ENDTRY.

        DATA(lo_request) = lo_client->get_http_request( ).
        lo_request->set_uri_path( |/v1/adsRender/pdf| ).
        lo_request->set_query( |templateSource=storageName| ).
        lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
        lo_request->set_header_field( i_name = 'Accept'       i_value = 'application/json' ).
        lo_request->set_text( /ui2/cl_json=>serialize(
                                data        = VALUE ty_request(
                                                xdp_template = |{ iv_form_name }/{ iv_template_name }|
                                                xml_data     = cl_web_http_utility=>encode_x_base64( iv_xml_data )
                                                form_type    = `print`
                                                form_locale  = iv_locale
                                                tagged_pdf   = 1
                                                embed_font   = 0 )
                                pretty_name = /ui2/cl_json=>pretty_mode-camel_case ) ).

        DATA(lo_response) = lo_client->execute( if_web_http_client=>post ).
        DATA(ls_status)   = lo_response->get_status( ).
        IF ls_status-code <> 200.
          RAISE EXCEPTION TYPE zcx_fp_tmpl_store_error
            EXPORTING
              textid              = zcx_fp_tmpl_store_error=>data_error
              mv_http_status_code = ls_status-code
              mv_http_reason      = |{ ls_status-reason } { substring( val = lo_response->get_text( )
                                                                       len = nmin( val1 = strlen( lo_response->get_text( ) ) val2 = 200 ) ) }|.
        ENDIF.

        /ui2/cl_json=>deserialize( EXPORTING json        = lo_response->get_text( )
                                             pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                   CHANGING  data        = ls_response ).
        rv_pdf = cl_web_http_utility=>decode_x_base64( ls_response-file_content ).
        lo_client->close( ).

      CATCH cx_http_dest_provider_error.
        RAISE EXCEPTION TYPE zcx_fp_tmpl_store_error
          EXPORTING
            textid = zcx_fp_tmpl_store_error=>setup_not_complete.
      CATCH cx_web_http_client_error cx_web_message_error INTO DATA(lx_http).
        RAISE EXCEPTION TYPE zcx_fp_tmpl_store_error
          EXPORTING
            textid         = zcx_fp_tmpl_store_error=>http_client_error
            mv_http_reason = lx_http->get_text( ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

