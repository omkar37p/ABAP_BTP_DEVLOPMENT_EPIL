CLASS zcl_mm_inv_penqty_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
ENDCLASS.


CLASS zcl_mm_inv_penqty_calc IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF line_exists( it_requested_calc_elements[ table_line = `PENDQTY` ] ).
      INSERT `PURCHASEORDER`     INTO TABLE et_requested_orig_elements.
      INSERT `PURCHASEORDERITEM` INTO TABLE et_requested_orig_elements.
    ENDIF.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_items TYPE STANDARD TABLE OF zmmge_app2_pv1 WITH DEFAULT KEY.
    DATA lt_keys  TYPE zcl_mm_s4_penqty=>tt_key.
    DATA lt_pend  TYPE zcl_mm_s4_penqty=>tt_penqty.

    lt_items = CORRESPONDING #( it_original_data ).

    LOOP AT lt_items INTO DATA(ls_item) WHERE purchaseorder IS NOT INITIAL.
      INSERT VALUE #( purchaseorder     = ls_item-purchaseorder
                      purchaseorderitem = ls_item-purchaseorderitem ) INTO TABLE lt_keys.
    ENDLOOP.

    TRY.
        lt_pend = zcl_mm_s4_penqty=>get( lt_keys ).
      CATCH cx_http_dest_provider_error
            cx_web_http_client_error
            /iwbep/cx_gateway.
        CLEAR lt_pend.
    ENDTRY.

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).
      <ls_item>-pendqty = VALUE #( lt_pend[ purchaseorder     = <ls_item>-purchaseorder
                                            purchaseorderitem = <ls_item>-purchaseorderitem ]-pendqty OPTIONAL ).
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_items ).
  ENDMETHOD.

ENDCLASS.
