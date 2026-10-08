CLASS zcl_sd_camview_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    TYPES: BEGIN OF ty_record,
             ok         TYPE abap_bool,
             message    TYPE string,
             wb_wt      TYPE string,
             rowid_seq  TYPE string,
             ocr_text   TYPE string,
             timestamp  TYPE string,
             camview_ip TYPE string,
             image1     TYPE string,
             image2     TYPE string,
             image3     TYPE string,
             image4     TYPE string,
           END OF ty_record.

    "! The record of one camera capture, images as base64 JPEG
    CLASS-METHODS get_record
      IMPORTING iv_rowid_seq     TYPE clike
      RETURNING VALUE(rs_record) TYPE ty_record.

  PRIVATE SECTION.
    CONSTANTS c_base_url TYPE string VALUE 'https://camview.nrxen.com'.
    CONSTANTS c_auth_key TYPE string VALUE '92n09wv84m03v'.
ENDCLASS.


CLASS zcl_sd_camview_api IMPLEMENTATION.

  METHOD get_record.
    DATA lv_seq TYPE string.
    lv_seq = iv_rowid_seq.
    CONDENSE lv_seq NO-GAPS.
    IF lv_seq IS INITIAL.
      rs_record-message = `No image sequence number (camera not launched)`.
      RETURN.
    ENDIF.

    TRY.
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination(
                            cl_http_destination_provider=>create_by_url(
                              |{ c_base_url }/record_with_image?rowid_seq={ lv_seq }| ) ).
        DATA(lo_request) = lo_client->get_http_request( ).
        lo_request->set_header_field( i_name = 'auth_key' i_value = c_auth_key ).
        lo_request->set_header_field( i_name = 'Accept'   i_value = 'application/json' ).

        DATA(lo_response) = lo_client->execute( if_web_http_client=>get ).
        DATA(ls_status)   = lo_response->get_status( ).
        DATA(lv_body)     = lo_response->get_text( ).
        lo_client->close( ).

        IF ls_status-code <> 200.
          rs_record-message = |CamView { ls_status-code } { ls_status-reason } for seq { lv_seq }: { substring( val = lv_body len = nmin( val1 = strlen( lv_body ) val2 = 200 ) ) }|.
          RETURN.
        ENDIF.

        /ui2/cl_json=>deserialize( EXPORTING json = lv_body
                                   CHANGING  data = rs_record ).
        CLEAR rs_record-message.
        IF rs_record-rowid_seq IS INITIAL.
          rs_record-message = |No CamView record for seq { lv_seq }: { substring( val = lv_body len = nmin( val1 = strlen( lv_body ) val2 = 200 ) ) }|.
          RETURN.
        ENDIF.
        rs_record-ok = abap_true.

      CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_error).
        rs_record-message = |CamView error: { lx_error->get_text( ) }|.
    ENDTRY.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    DATA(ls_record) = get_record( '115' ).

    IF ls_record-ok = abap_false.
      out->write( ls_record-message ).
      RETURN.
    ENDIF.

    out->write( |rowid_seq  { ls_record-rowid_seq }| ).
    out->write( |wb_wt      { ls_record-wb_wt }| ).
    out->write( |ocr_text   { ls_record-ocr_text }| ).
    out->write( |timestamp  { ls_record-timestamp }| ).
    out->write( |camview_ip { ls_record-camview_ip }| ).
    out->write( |image1     { strlen( ls_record-image1 ) } chars, starts { substring( val = ls_record-image1 len = nmin( val1 = strlen( ls_record-image1 ) val2 = 20 ) ) }| ).
    out->write( |image2     { strlen( ls_record-image2 ) } chars| ).
    out->write( |image3     { strlen( ls_record-image3 ) } chars| ).
    out->write( |image4     { strlen( ls_record-image4 ) } chars| ).
    out->write( `A JPEG in base64 starts with /9j/` ).

    " what does "not found" look like?
    DATA(ls_missing) = get_record( '1' ).
    out->write( |rowid_seq 1: ok={ ls_missing-ok } { ls_missing-message }| ).
  ENDMETHOD.

ENDCLASS.

