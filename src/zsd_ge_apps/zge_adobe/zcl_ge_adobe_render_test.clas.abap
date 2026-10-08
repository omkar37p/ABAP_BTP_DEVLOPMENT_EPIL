CLASS zcl_ge_adobe_render_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_ge_adobe_render_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " minimal data: an empty data root, the form renders with blank fields
    DATA(lv_xml) = cl_web_http_utility=>encode_utf8( `<?xml version="1.0" encoding="UTF-8"?><form1/>` ).

    TRY.
        DATA(lv_pdf) = zcl_ge_adobe_pdf=>render( iv_form_name     = `ZSD_WEIGHT_SLIP`
                                                  iv_template_name = `WEIGHMENT_SLIP`
                                                  iv_xml_data      = lv_xml ).
        out->write( |PDF rendered: { xstrlen( lv_pdf ) } bytes| ).
        IF xstrlen( lv_pdf ) > 4.
          DATA lv_head TYPE x LENGTH 4.
          lv_head = lv_pdf.   " first 4 bytes
          out->write( |Starts with: { lv_head }  (a PDF starts with 25504446 = %PDF)| ).
        ENDIF.
      CATCH zcx_fp_tmpl_store_error INTO DATA(lx_error).
        out->write( |Rendering error: HTTP { lx_error->mv_http_status_code } { lx_error->mv_http_reason }| ).
        out->write( lx_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

