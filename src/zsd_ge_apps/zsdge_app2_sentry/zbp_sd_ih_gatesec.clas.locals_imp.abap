CLASS lhc_GateSecHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateSecHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR GateSecHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR GateSecHead RESULT result.

    METHODS GatePrint FOR MODIFY
      IMPORTING keys FOR ACTION GateSecHead~GatePrint RESULT result.

    METHODS headmodify FOR DETERMINE ON SAVE
      IMPORTING keys FOR GateSecHead~headmodify.

ENDCLASS.


CLASS lhc_GateSecHead IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD GatePrint.
    READ ENTITIES OF zsd_ih_gatesec IN LOCAL MODE
      ENTITY GateSecHead
        FIELDS ( Uuid Gateentryid ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).

    LOOP AT lt_head INTO DATA(ls_head) WHERE Gateentryid IS NOT INITIAL.

      TRY.
          DATA(lo_fdp)  = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZSD_WEIGHT_SLIP_CE'
                                                             iv_root_node          = 'ZSD_HCE_GATESEC' ).
          DATA(lt_keys) = lo_fdp->get_keys( ).
          lt_keys[ name = 'UUID' ]-value = ls_head-Uuid.
          DATA(lv_xml)  = lo_fdp->read_to_xml( lt_keys ).

          DATA(lv_pdf)  = zcl_ge_adobe_pdf=>render( iv_form_name     = `ZSD_ENTRY_SLIP`
                                                    iv_template_name = `ENTRY_SLIP`
                                                    iv_xml_data      = lv_xml ).

        CATCH cx_fp_fdp_error INTO DATA(lx_fdp).
          APPEND VALUE #( %tky = ls_head-%tky ) TO failed-gatesechead.
          APPEND VALUE #( %tky = ls_head-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = |Slip data: { lx_fdp->get_text( ) }| ) )
                 TO reported-gatesechead.
          CONTINUE.
        CATCH zcx_fp_tmpl_store_error INTO DATA(lx_ads).
          APPEND VALUE #( %tky = ls_head-%tky ) TO failed-gatesechead.
          APPEND VALUE #( %tky = ls_head-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = |Adobe: HTTP { lx_ads->mv_http_status_code } { lx_ads->mv_http_reason }| ) )
                 TO reported-gatesechead.
          CONTINUE.
      ENDTRY.

      MODIFY ENTITIES OF zsd_ih_gatesec IN LOCAL MODE
        ENTITY GateSecHead
          UPDATE FIELDS ( Attachment Mimetype Filename )
          WITH VALUE #( ( %tky       = ls_head-%tky
                          Attachment = lv_pdf
                          Mimetype   = 'application/pdf'
                          Filename   = |Entry Slip-{ ls_head-Gateentryid }.pdf| ) ).

      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Gate entry slip created for { ls_head-Gateentryid }| ) )
             TO reported-gatesechead.
    ENDLOOP.

    READ ENTITIES OF zsd_ih_gatesec IN LOCAL MODE
      ENTITY GateSecHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD headmodify.
    DATA lv_nextid   TYPE n LENGTH 10.
    DATA lv_typetext TYPE zsdge_sentry_ht1-gateentrytypetext.
    DATA lv_gatetext TYPE zsdge_sentry_ht1-gatenodes.
    DATA lv_modetext TYPE zsdge_sentry_ht1-modeoftransporttext.
    DATA lt_update   TYPE TABLE FOR UPDATE zsd_ih_gatesec\\GateSecHead.

    READ ENTITIES OF zsd_ih_gatesec IN LOCAL MODE
      ENTITY GateSecHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(gt_head).

    DELETE gt_head WHERE Gateentryid IS NOT INITIAL.
    IF gt_head IS INITIAL.
      RETURN.
    ENDIF.

    GET TIME STAMP FIELD DATA(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

    SELECT SINGLE MAX( gateentryid ) FROM zsdge_sentry_ht1 INTO @DATA(lv_maxid).
    lv_nextid = COND #( WHEN lv_maxid IS INITIAL THEN '1000000000' ELSE lv_maxid ).

    LOOP AT gt_head ASSIGNING FIELD-SYMBOL(<fs_head>).
      lv_nextid += 1.

      CLEAR: lv_typetext, lv_gatetext, lv_modetext.

      IF <fs_head>-Gateentrytype IS NOT INITIAL.
        SELECT SINGLE text FROM zsd_type_vh WITH PRIVILEGED ACCESS
          WHERE value_low = @<fs_head>-Gateentrytype
          INTO @lv_typetext.
      ENDIF.

      IF <fs_head>-Gateno IS NOT INITIAL.
        SELECT SINGLE text FROM zsd_gateno_vh WITH PRIVILEGED ACCESS
          WHERE value_low = @<fs_head>-Gateno
          INTO @lv_gatetext.
      ENDIF.

      IF <fs_head>-Modeoftransport IS NOT INITIAL.
        SELECT SINGLE text FROM zsd_mode_tvh WITH PRIVILEGED ACCESS
          WHERE value_low = @<fs_head>-Modeoftransport
          INTO @lv_modetext.
      ENDIF.

      APPEND VALUE #( %tky                = <fs_head>-%tky
                      Gateentryid         = lv_nextid
                      Gateentryiddate     = lv_date
                      Gateentryidtime     = lv_time
                      Gateentrytypetext   = lv_typetext
                      Gatenodes           = lv_gatetext
                      Vehicletype         = 'R'
                      Modeoftransporttext = lv_modetext
                      %control = VALUE #( Gateentryid         = if_abap_behv=>mk-on
                                          Gateentryiddate     = if_abap_behv=>mk-on
                                          Gateentryidtime     = if_abap_behv=>mk-on
                                          Gateentrytypetext   = if_abap_behv=>mk-on
                                          Gatenodes           = if_abap_behv=>mk-on
                                          Vehicletype         = if_abap_behv=>mk-on
                                          Modeoftransporttext = if_abap_behv=>mk-on ) )
             TO lt_update.
    ENDLOOP.

    MODIFY ENTITIES OF zsd_ih_gatesec IN LOCAL MODE
      ENTITY GateSecHead
      UPDATE FROM lt_update.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_GateSecItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateSecItem RESULT result.

ENDCLASS.


CLASS lhc_GateSecItem IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
