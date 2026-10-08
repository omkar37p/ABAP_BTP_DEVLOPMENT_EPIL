CLASS lsc_zmmge_app2_re DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zmmge_app2_re IMPLEMENTATION.

  METHOD save_modified.
*********************************************************************
"" Item Details update in custom table
*********************************************************************
        if zbp_mmge_app2_re=>gt_upitem is NOT INITIAL.
            MODIFY zmmge_itm_t01 FROM TABLE @zbp_mmge_app2_re=>gt_upitem.
        ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_GateHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR GateHead RESULT result.

    METHODS GateCheckIn FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~GateCheckIn RESULT result.

    METHODS Purchase FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~Purchase RESULT result.

    METHODS WeightScrn FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~WeightScrn RESULT result.

    METHODS MigoPost FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~MigoPost RESULT result.

    METHODS GateSlipForm FOR MODIFY
      IMPORTING keys FOR ACTION GateHead~GateSlipForm RESULT result.

    "! Reads PO item data from S/4; connection errors come back in rs_response-message
    METHODS read_po_items
      IMPORTING iv_po              TYPE zmmge_itm_t01-purchaseorder
                iv_item            TYPE zmmge_itm_t01-purchaseorderitem OPTIONAL
      RETURNING VALUE(rs_response) TYPE zcl_mm_s4_gate_api=>ty_response.

ENDCLASS.

CLASS lhc_GateHead IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateHead
      FIELDS ( Materialdocument ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_head).

    " Your S/4 rules for Purchase / GateCheckIn / WeightScrn / Edit were
    " commented out, so those stay always enabled. MigoPost: only on a
    " saved gate entry that has no material document yet.
    result = VALUE #( FOR ls_head IN lt_head
                      ( %tky             = ls_head-%tky
                        %action-MigoPost = COND #( WHEN ls_head-%is_draft = if_abap_behv=>mk-on
                                                     OR ls_head-Materialdocument IS NOT INITIAL
                                                   THEN if_abap_behv=>fc-o-disabled
                                                   ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD GateCheckIn.
    DATA: seqno  TYPE zmmge_hdr_t01-gateentryseqno,
          gateno TYPE zmmge_hdr_t01-gateentryno.

    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_head).

    GET TIME STAMP FIELD DATA(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

    LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<fs_head>).
      SELECT SINGLE MAX( gateentryseqno ) AS gateentryseqno,
             gateentrydate
        FROM zmmge_hdr_t01
        WHERE gateentrydate = @lv_date
        GROUP BY gateentrydate
        INTO @DATA(gs_seqno).

      IF sy-subrc = 0 AND gs_seqno-gateentryseqno IS NOT INITIAL.
        seqno = gs_seqno-gateentryseqno + 1.
      ELSE.
        seqno = '001'.
      ENDIF.
      gateno = |{ <fs_head>-Gateentryseries }{ lv_date }-{ seqno }|.

      MODIFY ENTITIES OF zmmge_app2_re IN LOCAL MODE
        ENTITY GateHead
        UPDATE FIELDS ( Gateentryno Gateentryseqno Gateentrydate Gateentrytime )
        WITH VALUE #( ( %tky           = <fs_head>-%tky
                        Gateentryno    = gateno
                        Gateentryseqno = seqno
                        Gateentrydate  = lv_date
                        Gateentrytime  = lv_time ) ).
    ENDLOOP.

    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    result = VALUE #( FOR ls_res IN lt_result ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.

  METHOD Purchase.
    DATA ls_response    TYPE zcl_mm_s4_gate_api=>ty_response.
    DATA lv_subgate     TYPE zmmge_itm_t01-subgateentryno.
    DATA lt_po_on_entry TYPE SORTED TABLE OF zmmge_itm_t01-purchaseorder WITH UNIQUE KEY table_line.

    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(gt_head)
      ENTITY GateHead BY \_Item
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(gt_item).

    DATA(ls_header) = VALUE #( gt_head[ 1 ] OPTIONAL ).
    DATA(gs_keys)   = VALUE #( keys[ 1 ] OPTIONAL ).
    DATA(lv_po)     = CONV zmmge_itm_t01-purchaseorder( gs_keys-%param-PurchaseOrder ).
    DATA(lv_poitem) = CONV zmmge_itm_t01-purchaseorderitem( gs_keys-%param-PurchaseOrderItem ).

    " G2: one sub gate entry letter per PO already on the gate entry
    " (no PO yet = A, one PO = B, ... ten POs = K) - same as the S/4 IF chain
*    IF ls_header-Gateentryseries = 'G2'.
*      LOOP AT gt_item INTO DATA(ls_item).
*        INSERT ls_item-Purchaseorder INTO TABLE lt_po_on_entry.
*      ENDLOOP.
*      DATA(lv_subcount) = lines( lt_po_on_entry ).
*      IF lv_subcount <= 10.
*        lv_subgate = |{ ls_header-Gateentryno }-{ substring( val = `ABCDEFGHIJK` off = lv_subcount len = 1 ) }|.
*      ENDIF.
*    ENDIF.

    SELECT SINGLE purchaseorder, purchaseorderitem FROM zmmge_itm_t01
      WHERE purchaseorder     = @lv_po
        AND purchaseorderitem = @lv_poitem
        AND uuid              = @ls_header-Uuid
      INTO @DATA(wa_poitemdb).

    SELECT SINGLE purchaseorder, purchaseorderitem FROM zmmge_itm_t01
      WHERE purchaseorder = @lv_po
        AND uuid          = @ls_header-Uuid
      INTO @DATA(wa_poitemdb_st).

    IF lv_po IS NOT INITIAL AND ls_header-Gateentryseries <> 'G2' AND wa_poitemdb IS INITIAL.
      IF lv_poitem IS NOT INITIAL.
        ls_response = read_po_items( iv_po = lv_po iv_item = lv_poitem ).
      ENDIF.
    ELSEIF lv_po IS NOT INITIAL AND ls_header-Gateentryseries = 'G2' AND wa_poitemdb_st IS INITIAL.
      ls_response = read_po_items( iv_po = lv_po ).
    ELSE.
      APPEND VALUE #( %tky = ls_header-%tky ) TO failed-gatehead.
      APPEND VALUE #( %tky = ls_header-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                    text     = |Order Already Exists-{ ls_header-Gateentryno }| ) )
             TO reported-gatehead.
    ENDIF.

    IF ls_response-success = abap_true.
      MODIFY ENTITIES OF zmmge_app2_re IN LOCAL MODE
        ENTITY GateHead
        CREATE BY \_Item
        AUTO FILL CID
        FIELDS ( Purchaseorder Purchaseorderitem Vendor Suppliername Gateentryno Gateentryseries Subgateentryno
                 Material Materialtext Materialgroup Plant Plantname Baseunit Quantity
                 Poordertype Poordertypetext Orderdate )
        WITH VALUE #( FOR gs_head IN gt_head
                      ( %tky    = gs_head-%tky
                        %target = VALUE #( FOR ls_po IN ls_response-poitems
                                           ( Purchaseorder     = ls_po-purchaseorder
                                             Purchaseorderitem = ls_po-purchaseorderitem
                                             Vendor            = ls_po-supplier
                                             Suppliername      = ls_po-suppliername
                                             Gateentryno       = gs_head-Gateentryno
                                             Gateentryseries   = gs_head-Gateentryseries
                                             Subgateentryno    = lv_subgate
                                             Material          = ls_po-material
                                             Materialtext      = ls_po-productname
                                             Materialgroup     = ls_po-materialgroup
                                             Plant             = ls_po-plant
                                             Plantname         = ls_po-plantname
                                             Baseunit          = ls_po-baseunit
                                             Quantity          = ls_po-orderquantity
                                             Poordertype       = ls_po-purchaseordertype
                                             Poordertypetext   = ls_po-purchasingdocumenttypename
                                             Orderdate         = ls_po-purchaseorderdate ) ) ) )
        MAPPED mapped
        FAILED failed
        REPORTED reported.
    ELSEIF ls_response-message IS NOT INITIAL.
      APPEND VALUE #( %tky = ls_header-%tky ) TO failed-gatehead.
      APPEND VALUE #( %tky = ls_header-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                    text     = ls_response-message ) )
             TO reported-gatehead.
    ENDIF.

    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    result = VALUE #( FOR ls_res IN lt_result ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.

  METHOD read_po_items.
    TRY.
        rs_response = zcl_mm_s4_gate_api=>call( VALUE #( operation         = 'POITEMS'
                                                         purchaseorder     = iv_po
                                                         purchaseorderitem = iv_item ) ).
      CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_error).
        rs_response = VALUE #( message = |S/4 not reachable: { lx_error->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

  METHOD WeightScrn.
    " unchanged: the body was already commented out in the S/4 version
  ENDMETHOD.

  METHOD MigoPost.
    DATA ls_response TYPE zcl_mm_s4_gate_api=>ty_response.

    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_head)
      ENTITY GateHead BY \_Item
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_poitem).

    LOOP AT lt_head INTO DATA(ls_header).
      DATA(ls_key) = keys[ %tky = ls_header-%tky ].

      TRY.
          ls_response = zcl_mm_s4_gate_api=>call(
                          VALUE #( operation   = 'MIGO'
                                   gateentryno = ls_header-Gateentryno
                                   postingdate = ls_key-%param-PostingDate
                                   items       = VALUE #( FOR ls_poitem IN lt_poitem WHERE ( Uuid = ls_header-Uuid )
                                                          ( purchaseorder     = ls_poitem-Purchaseorder
                                                            purchaseorderitem = ls_poitem-Purchaseorderitem
                                                            plant             = ls_poitem-Plant
                                                            material          = ls_poitem-Material
                                                            quantity          = ls_poitem-Netweight
                                                            unit              = ls_poitem-Baseunit
                                                            storagelocation   = ls_poitem-Storagelocation ) ) ) ).
        CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_error).
          ls_response = VALUE #( message = |S/4 not reachable: { lx_error->get_text( ) }| ).
      ENDTRY.

      IF ls_response-success = abap_false.
        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-gatehead.
        APPEND VALUE #( %tky = ls_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = |Goods receipt not posted: { ls_response-message }| ) )
               TO reported-gatehead.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zmmge_app2_re IN LOCAL MODE
        ENTITY GateHead
        UPDATE FIELDS ( Materialdocument Materialdocumentyear )
        WITH VALUE #( ( %tky                 = ls_header-%tky
                        Materialdocument     = ls_response-materialdocument
                        Materialdocumentyear = ls_response-materialdocumentyear ) ).

      APPEND VALUE #( %tky = ls_header-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Material document { ls_response-materialdocument } posted| ) )
             TO reported-gatehead.
    ENDLOOP.

    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    result = VALUE #( FOR ls_res IN lt_result ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.

  METHOD GateSlipForm.
    " TEMPORARY until Step 12 (Adobe form setup in BTP) - the real code
    " replaces this method then.
    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    LOOP AT lt_result INTO DATA(ls_res).
      APPEND VALUE #( %tky = ls_res-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-warning
                                                    text     = 'Entry slip printing is not set up yet in BTP' ) )
             TO reported-gatehead.
    ENDLOOP.

    result = VALUE #( FOR ls_r IN lt_result ( %tky = ls_r-%tky %param = ls_r ) ).
  ENDMETHOD.

ENDCLASS.


CLASS lhc_GateItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateItem RESULT result.

    METHODS ChallanQtyCal FOR DETERMINE ON MODIFY
      IMPORTING keys FOR GateItem~ChallanQtyCal.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR GateItem RESULT result.

    METHODS InbDelivery FOR MODIFY
      IMPORTING keys FOR ACTION GateItem~InbDelivery RESULT result.
    METHODS ChallanInput FOR MODIFY
      keys FOR ACTION GateItem~ChallanInput RESULT result.

ENDCLASS.

CLASS lhc_GateItem IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateItem
      FIELDS ( Inbounddelivery ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_item).

    " InbDelivery: only on a saved gate entry, and only once per item
    result = VALUE #( FOR ls_item IN lt_item
                      ( %tky                = ls_item-%tky
                        %action-InbDelivery = COND #( WHEN ls_item-%is_draft = if_abap_behv=>mk-on
                                                        OR ls_item-Inbounddelivery IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD ChallanQtyCal.
    DATA lv_chnetqty TYPE zmmge_app2_iv1-Challannetweight.

    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateItem
      FIELDS ( Challangrossweight Challantareweight ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_item).

    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>) WHERE Challangrossweight IS NOT INITIAL.
      lv_chnetqty = (  <ls_item>-Challangrossweight - <ls_item>-Challantareweight ).

      MODIFY ENTITIES OF zmmge_app2_re IN LOCAL MODE
        ENTITY GateItem
        UPDATE FIELDS ( Challannetweight )
        WITH VALUE #( ( %tky             = <ls_item>-%tky
                        Challannetweight = lv_chnetqty ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD InbDelivery.
    DATA ls_response TYPE zcl_mm_s4_gate_api=>ty_response.

    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateItem
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_poitem)
      ENTITY GateItem BY \_Head
      FIELDS ( Gateentryno ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_head).

    IF lt_poitem IS INITIAL.
      RETURN.
    ENDIF.

    SORT lt_poitem ASCENDING BY Purchaseorder Purchaseorderitem.
    DATA(ls_pohead) = VALUE #( lt_head[ 1 ] OPTIONAL ).
    DATA(ls_item)   = lt_poitem[ 1 ].

    " one inbound delivery for all selected items, as in S/4
    TRY.
        ls_response = zcl_mm_s4_gate_api=>call(
                        VALUE #( operation   = 'INBDLV'
                                 supplier    = ls_item-Vendor
                                 gateentryno = ls_pohead-Gateentryno
                                 items       = VALUE #( FOR ls_poitem IN lt_poitem
                                                        ( purchaseorder     = ls_poitem-Purchaseorder
                                                          purchaseorderitem = ls_poitem-Purchaseorderitem ) ) ) ).
      CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_error).
        ls_response = VALUE #( message = |S/4 not reachable: { lx_error->get_text( ) }| ).
    ENDTRY.

    IF ls_response-success = abap_false.
      LOOP AT lt_poitem INTO DATA(ls_failed_item).
        APPEND VALUE #( %tky = ls_failed_item-%tky ) TO failed-gateitem.
        APPEND VALUE #( %tky = ls_failed_item-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = |Inbound delivery not created: { ls_response-message }| ) )
               TO reported-gateitem.
      ENDLOOP.
    ELSE.
      MODIFY ENTITIES OF zmmge_app2_re IN LOCAL MODE
        ENTITY GateItem
        UPDATE FIELDS ( Inbounddelivery )
        WITH VALUE #( FOR ls_poitem IN lt_poitem
                      ( %tky            = ls_poitem-%tky
                        Inbounddelivery = ls_response-inbounddelivery ) ).

      APPEND VALUE #( %tky = ls_item-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Inbound delivery { ls_response-inbounddelivery } created| ) )
             TO reported-gateitem.
    ENDIF.

    READ ENTITIES OF zmmge_app2_re IN LOCAL MODE
      ENTITY GateItem
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    result = VALUE #( FOR ls_res IN lt_result ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.

  METHOD ChallanInput.
********************************************************************************
            READ ENTITIES OF ZMMGE_APP2_RE in LOCAL MODE
            ENTITY GateHead
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head)
            ENTITY GateItem
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_item)
            FAILED DATA(lt_failed).
********************************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] optional ).
            sort lt_item ASCENDING BY Purchaseorder Purchaseorderitem.
            DATA(gt_keys) = keys.
            DATA(gs_keys) = VALUE #( gt_keys[ 1 ] OPTIONAL ).
            DATA: lv_subgate type zmmge_itm_t01-subgateentryno.
            DATA: lv_trans TYPE n LENGTH 10.
            data: up_item TYPE TABLE of zmmge_itm_t01,
                  ups_item TYPE zmmge_itm_t01.
********************************************************************************
                lv_trans = gs_keys-%param-trasporterid.

*                SELECT SINGLE * FROM ZMM_BP_ZTRP_VH WITH PRIVILEGED ACCESS
*                WHERE Transporterid = @lv_trans
*                INTO @DATA(ls_transname).
********************************************************************************

                SELECT * FROM zmmge_itm_t01 WITH PRIVILEGED ACCESS
                WHERE uuid = @ls_head-Uuid
                AND challanno is NOT INITIAL
                INTO TABLE @DATA(t_item).

                DATA(t_item_count) = lines( t_item ).

            if ls_head-Gateentryseries = 'G2'.

            TYPES: BEGIN OF ty_po_count,
                    invoiceno TYPE c LENGTH 20,
                    item_count    TYPE i,
            END OF ty_po_count.

            DATA gt_Inv_count TYPE TABLE OF ty_po_count.

********************************************************************************
            LOOP AT t_item ASSIGNING FIELD-SYMBOL(<gs_item>)
             GROUP BY <gs_item>-challanno
             INTO DATA(lv_Ino1).

              DATA(lv_count) = 0.

              LOOP AT GROUP lv_Ino1 ASSIGNING FIELD-SYMBOL(<fs_group>).
                lv_count += 1.
              ENDLOOP.

              APPEND VALUE #(
                invoiceno = lv_Ino1
                item_count    = lv_count
              ) TO gt_Inv_count.

            ENDLOOP.

            DATA(lv_subcount) = lines( gt_Inv_count ).
            DATA(lv_finalCount) = lv_subcount.

                    if lv_finalCount = '0'.
                        lv_subgate = |{ ls_head-Gateentryno }-A|.
                    ELSEIF lv_finalCount = '1'.
                        lv_subgate = |{ ls_head-Gateentryno }-B|.
                    ELSEIF lv_finalCount = '2'.
                        lv_subgate = |{ ls_head-Gateentryno }-C|.
                    ELSEIF lv_finalCount = '3'.
                        lv_subgate = |{ ls_head-Gateentryno }-D|.
                    ELSEIF lv_finalCount = '4'.
                        lv_subgate = |{ ls_head-Gateentryno }-E|.
                    ELSEIF lv_finalCount = '5'.
                        lv_subgate = |{ ls_head-Gateentryno }-F|.
                    ELSEIF lv_finalCount = '6'.
                        lv_subgate = |{ ls_head-Gateentryno }-G|.
                    ELSEIF lv_finalCount = '7'.
                        lv_subgate = |{ ls_head-Gateentryno }-H|.
                    ELSEIF lv_finalCount = '8'.
                        lv_subgate = |{ ls_head-Gateentryno }-I|.
                    ELSEIF lv_finalCount = '9'.
                        lv_subgate = |{ ls_head-Gateentryno }-J|.
                    ELSEIF lv_finalCount = '10'.
                        lv_subgate = |{ ls_head-Gateentryno }-K|.
                    ENDIF.
ENDIF.


**********************************************************************

            LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
            if <fs_item> is ASSIGNED.

                    MOVE-CORRESPONDING <fs_item> to ups_item.
                    ups_item-challanno = gs_keys-%param-Challanno.
                    ups_item-challandate = gs_keys-%param-Challandate.
                    ups_item-trasporterid = gs_keys-%param-trasporterid.
*                    ups_item-trasportername = ls_transname-Transportername.
                    ups_item-lrno = gs_keys-%param-lrno.
                    ups_item-lrdate = gs_keys-%param-lrdate.
                    ups_item-subgateentryno = lv_subgate.

                    APPEND ups_item to up_item.
            ENDIF.
            ENDLOOP.
                if up_item is NOT INITIAL.
                    zbp_mmge_app2_re=>gt_upitem = up_item.
                ENDIF.
********************************************************************************
               result = VALUE #( FOR ls_item IN lt_item
                         ( %tky   = ls_item-%tky
                           %param = ls_item ) ).

  ENDMETHOD.

ENDCLASS.
