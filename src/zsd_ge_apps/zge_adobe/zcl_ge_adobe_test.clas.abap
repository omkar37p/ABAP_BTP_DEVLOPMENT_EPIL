CLASS zcl_ge_adobe_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_ge_adobe_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    TYPES: BEGIN OF ty_pair,
             form     TYPE string,
             template TYPE string,
           END OF ty_pair.
    DATA lt_pairs TYPE STANDARD TABLE OF ty_pair WITH EMPTY KEY.

    " v3: ZSD_ENTRY_SLIP last (not first), plus a form that surely does
    " not exist, to see which HTTP code a missing form gives
    lt_pairs = VALUE #( ( form = `ZSD_LOADING_SLIP` template = `LOADING_SLIP` )     " Sales Order Update
                        ( form = `ZSD_WEIGHT_SLIP`  template = `WEIGHMENT_SLIP` )   " Outgoing Weighment
                        ( form = `ZMM_ENTRY_SLIP`   template = `ENTRY_SLIP` )       " Inventory
                        ( form = `ZMM_WEIGHT_SLIP`  template = `WEIGHT_SLIP` )      " Weight Recording
                        ( form = `ZZ_NO_SUCH_FORM`  template = `NO_SUCH_TEMPLATE` ) " must fail: shows the 'missing' code
                        ( form = `ZSD_ENTRY_SLIP`   template = `ENTRY_SLIP` ) ).    " Security Entry

    TRY.
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client( iv_name                  = 'ZADS_CS'
                                                       iv_service_instance_name = 'ZADS_OUT_REST' ).
      CATCH zcx_fp_tmpl_store_error INTO DATA(lx_setup).
        out->write( |Setup error: { lx_setup->get_text( ) }| ).
        RETURN.
    ENDTRY.

    LOOP AT lt_pairs INTO DATA(ls_pair).
      TRY.
          DATA(ls_template) = lo_store->get_template_by_name( iv_get_binary    = abap_true
                                                              iv_form_name     = ls_pair-form
                                                              iv_template_name = ls_pair-template ).
          out->write( |OK   { ls_pair-form } / { ls_pair-template }: { xstrlen( ls_template-xdp_template ) } bytes, | &&
                      |"{ ls_template-description }"| ).
        CATCH zcx_fp_tmpl_store_error INTO DATA(lx_error).
          out->write( |FAIL { ls_pair-form } / { ls_pair-template }: HTTP { lx_error->mv_http_status_code } { lx_error->mv_http_reason }| ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

