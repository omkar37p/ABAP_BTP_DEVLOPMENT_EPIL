CLASS lhc_weightitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR WeightItem RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR WeightItem RESULT result.

    METHODS AutoFetchTWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~AutoFetchTWt RESULT result.

    METHODS ManualFetchTWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~ManualFetchTWt RESULT result.

    METHODS ImgCapture FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~ImgCapture RESULT result.

ENDCLASS.

CLASS lhc_weightitem IMPLEMENTATION.

  METHOD get_instance_features.
    " As in S/4: the rules were commented out, so everything stays enabled.
*   result = VALUE #( FOR gs_item IN lt_item
*                     ( %tky = gs_item-%tky
*                       %field-Netweight = COND #( WHEN ( gs_item-Baseunit = 'TO' OR gs_item-Baseunit = 'KG' )
*                                                  THEN if_abap_behv=>fc-f-read_only
*                                                  ELSE if_abap_behv=>fc-f-unrestricted )
*                       %action-ManualFetchTWt = COND #( WHEN gs_item-Weightindicator = 'X'
*                                                        THEN if_abap_behv=>fc-o-disabled
*                                                        ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD AutoFetchTWt.
    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightItem
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT FINAL(lt_item).

    result = VALUE #( FOR ls_ord IN lt_item
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

  METHOD ManualFetchTWt.
    TYPES ty_weight TYPE zmmge_itm_t01-netweight.

    DATA: lv_netwt      TYPE zmmge_itm_t01-netweight,
          lv_grswt       TYPE zmmge_itm_t01-netweight,
          lv_tarewt      TYPE zmmge_itm_t01-netweight,
          lv_weiuom      TYPE zmmge_itm_t01-weiuom,
          lv_total_netwt TYPE zmmge_itm_t01-netweight,
          lv_grnqty      TYPE zmmge_itm_t01-grnqty.

    DATA lt_update TYPE TABLE FOR UPDATE zmm_ih_weight\\WeightItem.

    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT FINAL(lt_head)
      ENTITY WeightItem
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_item).

    DATA(ls_header) = VALUE #( lt_head[ 1 ] OPTIONAL ).
    DATA(gs_keys)   = VALUE #( keys[ 1 ] OPTIONAL ).

      GET TIME STAMP FIELD DATA(ts).
      CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
    "" -- Value Validation -----
    IF gs_keys-%param-Weight IS NOT INITIAL.

      " net already weighed on this gate entry (all items, same draft/active state)
      READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
        ENTITY WeightHead BY \_Item
        FIELDS ( Netweight ) WITH VALUE #( ( %tky = ls_header-%tky ) )
        RESULT DATA(lt_all_items).

      " INIT with a typed 0: "INIT lv_sum = 0" (as in S/4) makes lv_sum an
      " integer and rounds away the decimals of every net weight
      lv_total_netwt = REDUCE #( INIT lv_sum = CONV ty_weight( 0 )
                                 FOR ls_all IN lt_all_items
                                 NEXT lv_sum = lv_sum + ls_all-Netweight ).

      SORT lt_item ASCENDING BY Purchaseorder Purchaseorderitem.
      DATA(gs_count) = 1.

      LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).

        IF <ls_item>-Weightindicator IS INITIAL AND <ls_item>-Unloadind IS NOT INITIAL.

          "" this logic for GRN Posting logic---
          SELECT SINGLE * FROM zmmge_wghflg_t01 WITH PRIVILEGED ACCESS
            WHERE gateentryseries = @ls_header-Gateentryseries
              AND materialgroup   = @<ls_item>-Materialgroup
            INTO @DATA(ls_master).

          IF gs_count = 1.
            lv_grswt  = ( ls_header-Grosswt - lv_total_netwt ).
            lv_weiuom = gs_keys-%param-Unit.
            lv_tarewt = gs_keys-%param-Weight.
            lv_netwt  = lv_grswt - gs_keys-%param-Weight.
          ENDIF.

          "" this logic for GRN Posting logic---
          IF ls_master-challanqtyflag = 'X' AND ( <ls_item>-Baseunit = 'KG' OR <ls_item>-Baseunit = 'TO' ).
            lv_grnqty = <ls_item>-Challannetweight.
          ELSEIF ls_master-challanqtyflag = 'X' AND ( <ls_item>-Baseunit NE 'KG' OR <ls_item>-Baseunit NE 'TO' ).
            lv_grnqty = <ls_item>-Challanqty.
          ELSE.
            lv_grnqty = lv_netwt.
          ENDIF.

          APPEND VALUE #( %tky            = <ls_item>-%tky
                          Grossweight     = lv_grswt
                          Weiuom          = lv_weiuom
                          Netweight       = lv_netwt
                          Tareweight      = lv_tarewt
                          Weightindicator = 'X'
                          Grnqty          = lv_grnqty
                          Gateentryno     = ls_header-Gateentryno
                          Weighmentdate = lv_date
                          Weighmenttime = lv_time ) TO lt_update.

          CLEAR: lv_grswt, lv_netwt, lv_tarewt, lv_weiuom, lv_grnqty, ls_master.
          gs_count += 1.

        ELSE.
          DATA(lv_msg) = |Weighment is done { <ls_item>-Purchaseorderitem } or Unload not started|.
          APPEND VALUE #( %tky        = <ls_item>-%tky
                          %state_area = 'Validate_Head'
                          %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                               text     = lv_msg ) )
                 TO reported-weightitem.
          APPEND VALUE #( %tky = <ls_item>-%tky ) TO failed-weightitem.
        ENDIF.

      ENDLOOP.

      IF lt_update IS NOT INITIAL.
        MODIFY ENTITIES OF zmm_ih_weight IN LOCAL MODE
          ENTITY WeightItem
          UPDATE FIELDS ( Grossweight Weiuom Netweight Tareweight Weightindicator
                          Grnqty Gateentryno Weighmentdate Weighmenttime )
          WITH lt_update.
      ENDIF.

    ELSE.
      DATA(lv_msgs) = |Weightment is Empty|.
      APPEND VALUE #( %tky        = ls_header-%tky
                      %state_area = 'Validate_Head'
                      %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                           text     = lv_msgs ) )
             TO reported-weighthead.
      APPEND VALUE #( %tky = ls_header-%tky ) TO failed-weighthead.
    ENDIF.

    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightItem
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_ord IN lt_result
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

  METHOD ImgCapture.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_WeightHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR WeightHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR WeightHead RESULT result.

    METHODS FirstImg FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~FirstImg RESULT result.

    METHODS SecondImg FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~SecondImg RESULT result.

    METHODS AutoFetchWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~AutoFetchWt RESULT result.

    METHODS ManualFetchWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~ManualFetchWt RESULT result.

    METHODS ImageValid FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~ImageValid RESULT result.

    METHODS Weighmentform FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~Weighmentform RESULT result.

ENDCLASS.

CLASS lhc_WeightHead IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      FIELDS ( Unloadendindi ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_head).

    " SecondImg only after unloading has finished (unchanged rule).
    " The commented-out Baseunit rules for AutoFetchWt / ManualFetchWt /
    " Edit from S/4 were not active and are left out.
    result = VALUE #( FOR ls_head IN lt_head
                      ( %tky              = ls_head-%tky
                        %action-SecondImg = COND #( WHEN ls_head-Unloadendindi = 'X'
                                                    THEN if_abap_behv=>fc-o-enabled
                                                    ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD FirstImg.
    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT FINAL(gt_weighthd).

    result = VALUE #( FOR ls_ord IN gt_weighthd
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

  METHOD SecondImg.
    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT FINAL(gt_weighthd).

    result = VALUE #( FOR ls_ord IN gt_weighthd
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

  METHOD AutoFetchWt.
    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT FINAL(gt_weighthd).

    result = VALUE #( FOR ls_ord IN gt_weighthd
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

  METHOD ManualFetchWt.
    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT FINAL(gt_weighthd).

    DATA(ls_header) = VALUE #( gt_weighthd[ 1 ] OPTIONAL ).
    DATA(gs_keys)   = VALUE #( keys[ 1 ] OPTIONAL ).

    "" -- Value Validation -----
    IF gs_keys-%param-Weight IS NOT INITIAL.

      GET TIME STAMP FIELD DATA(ts).
      CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

      SELECT SINGLE * FROM zmm_weighment_vh WITH PRIVILEGED ACCESS
        WHERE value_low = @gs_keys-%param-Weighmentmcno
          AND language  = 'E'
        INTO @DATA(ls_mcno).

      " The G1/G2 gross-vs-tare logic stays commented out, as in S/4;
      " this action records the gross weight only.
      MODIFY ENTITIES OF zmm_ih_weight IN LOCAL MODE
        ENTITY WeightHead
        UPDATE FIELDS ( Grosswt Weighuom Weighmentmcno weighmentmcndes Weighmentdate Weighmenttime )
        WITH VALUE #( FOR ls_weight IN gt_weighthd
                      ( %tky            = ls_weight-%tky
                        Grosswt         = gs_keys-%param-Weight
                        Weighmentmcno   = gs_keys-%param-Weighmentmcno
                        Weighuom        = gs_keys-%param-Unit
                        weighmentmcndes = ls_mcno-text
                        Weighmentdate   = lv_date
                        Weighmenttime   = lv_time ) ).

    ELSE.
      DATA(lv_msgs) = |Weightment is Empty|.
      APPEND VALUE #( %tky        = ls_header-%tky
                      %state_area = 'Validate_Head'
                      %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                           text     = lv_msgs ) )
             TO reported-weighthead.
      APPEND VALUE #( %tky = ls_header-%tky ) TO failed-weighthead.
    ENDIF.

    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_ord IN lt_result
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

  METHOD ImageValid.
    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT FINAL(lt_gatehd).

    MODIFY ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      UPDATE FIELDS ( Imagevaldindicator )
      WITH VALUE #( FOR ls_hd IN lt_gatehd
                    ( %tky               = ls_hd-%tky
                      Imagevaldindicator = 'X' ) ).

    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_ord IN lt_result
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

    METHOD Weighmentform.
    " STUB until Phase 5: the Adobe helper class ZCL_FP_TMPL_STORE_CLIENT
    " is not in BTP yet. The full method is in file 07b - paste it over
    " this one when the Forms Service objects exist.
    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
      ENTITY WeightHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    LOOP AT lt_result INTO DATA(ls_res).
      APPEND VALUE #( %tky = ls_res-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-information
                                                    text     = 'Weighment slip is not available yet' ) )
             TO reported-weighthead.
    ENDLOOP.

    result = VALUE #( FOR ls_ord IN lt_result
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

*  METHOD Weighmentform.
*    DATA: printque TYPE c LENGTH 32,
*          lv_name  TYPE c LENGTH 120.
*
*    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
*      ENTITY WeightHead
*      ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT FINAL(gt_head).
*
*    DATA(ls_header) = VALUE #( gt_head[ 1 ] OPTIONAL ).
*
*    IF ls_header-Gateentryno IS NOT INITIAL.
*
*      TRY.
*          "Initialize Template Store Client
*          DATA(lo_store) = NEW zcl_fp_tmpl_store_client( iv_name                  = 'ZADS_CS'
*                                                         iv_service_instance_name = 'ZADS_OUT_REST' ).
*
*          DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZWEIGHT_SLIP_CE_SD'
*                                                                iv_root_node          = 'ZMM_WEIGHT_SLIP_CE' ).
*
*          printque = 'ADOBE_DEFAULT'.
*
*          TRY.
*              lo_store->get_schema_by_name( iv_form_name = 'ZMM_WEIGHT_SLIP' ).
*            CATCH zcx_fp_tmpl_store_error INTO DATA(lo_tmpl_error) ##NEEDED.
*              " schema upload was commented out in S/4 - nothing to do
*          ENDTRY.
*
*          DATA(lt_keys) = lo_fdp_util->get_keys( ).
*          lt_keys[ name = 'UUID' ]-value = ls_header-Uuid.
*
*          TRY.
*              DATA(lv_xml) = lo_fdp_util->read_to_xml( lt_keys ).
*            CATCH cx_fp_fdp_error ##NO_HANDLER.
*          ENDTRY.
*
*          DATA(ls_template) = lo_store->get_template_by_name( iv_get_binary    = abap_true
*                                                              iv_form_name     = 'ZMM_WEIGHT_SLIP'
*                                                              iv_template_name = 'WEIGHT_SLIP' ).
*
*          cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
*                                                iv_xml_data     = lv_xml
*                                                iv_xdp_layout   = ls_template-xdp_template
*                                                is_options      = VALUE #( trace_level = 4 ) " Use 0 in production environment
*                                      IMPORTING ev_trace_string = DATA(lv_trace) ##NEEDED
*                                                ev_pdf          = DATA(lv_pdf) ).
*
*          lv_name = |Weighment Slip-{ ls_header-Gateentryno }|.
*
*          cl_print_queue_utils=>create_queue_item_by_data( iv_qname            = printque
*                                                           iv_print_data       = lv_pdf
*                                                           iv_name_of_main_doc = lv_name
*                                                           iv_itemid           = cl_print_queue_utils=>create_queue_itemid( ) ).
*
*        CATCH cx_fp_fdp_error zcx_fp_tmpl_store_error cx_fp_ads_util ##NO_HANDLER.
*      ENDTRY.
*
*      IF lv_pdf IS NOT INITIAL.
*        MODIFY ENTITIES OF zmm_ih_weight IN LOCAL MODE
*          ENTITY WeightHead
*          UPDATE FIELDS ( Weighslipattcmt Weighmimetype Weighfilename )
*          WITH VALUE #( ( %tky            = ls_header-%tky
*                          Weighslipattcmt = lv_pdf
*                          Weighmimetype   = 'application/pdf'
*                          Weighfilename   = lv_name ) ).
*      ENDIF.
*
*    ENDIF.
*
*    READ ENTITIES OF zmm_ih_weight IN LOCAL MODE
*      ENTITY WeightHead
*      ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_result).
*
*    result = VALUE #( FOR ls_ord IN lt_result
*                      ( %tky   = ls_ord-%tky
*                        %param = ls_ord ) ).
*  ENDMETHOD.

ENDCLASS.

