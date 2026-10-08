CLASS lhc_GateSecEntry DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR GateSecEntry RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR GateSecEntry RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR GateSecEntry RESULT result.

    METHODS print FOR MODIFY
      keys FOR ACTION GateSecEntry~print RESULT result.

    METHODS head_modify FOR DETERMINE ON SAVE
      keys FOR GateSecEntry~head_modify.

    METHODS gatenocheck FOR VALIDATE ON SAVE
      keys FOR GateSecEntry~gatenocheck.

ENDCLASS.

CLASS lhc_GateSecEntry IMPLEMENTATION.

  METHOD get_instance_features.
**********************************************************************
            READ ENTITIES OF zmmge_app1_re IN LOCAL MODE
            ENTITY GateSecEntry
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_gatehd)
            FAILED DATA(lt_failed).
**********************************************************************
            DATA(ls_gatehd) = VALUE #( lt_gatehd[ 1 ] OPTIONAL ).

            result = VALUE #( FOR gs_header IN lt_gatehd
                            ( %tky   = gs_header-%tky

                       %field-Minepassno =  COND #( WHEN gs_header-Gateentryseries = 'G1'
                                                                  THEN if_abap_behv=>fc-f-unrestricted
                                                                  ELSE if_abap_behv=>fc-f-read_only )

                       %field-Forestpassno =  COND #( WHEN gs_header-Gateentryseries = 'G1'
                                                                  THEN if_abap_behv=>fc-f-unrestricted
                                                                  ELSE if_abap_behv=>fc-f-read_only )
                        ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD print.
  ENDMETHOD.

  METHOD head_modify.
************************************************************************
            DATA: gateid TYPE zmmge_hdr_t01-gateentryid,
                  securityremark TYPE zmmge_hdr_t01-securityremarks.
            DATA: lv_trans TYPE n LENGTH 10.
***********************************************************************
            READ ENTITIES OF zmmge_app1_re IN LOCAL MODE
            ENTITY GateSecEntry
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_head).
***********************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
            lv_trans = ls_head-Trasporterid.
************************************************************************

            GET TIME STAMP FIELD DATA(ts).
            CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).
***********************************************************************
            TRY.
                DATA(lv_user) = cl_abap_context_info=>get_user_business_partner_id(  ).
              CATCH cx_abap_context_info_error.
                DATA(ls_x1) = 1.
            ENDTRY.

            TRY.
                DATA(lv_user1) = cl_abap_context_info=>get_user_alias(  ).
              CATCH cx_abap_context_info_error.
                DATA(ls_x11) = 1.
            ENDTRY.

            DATA(lv_cbuser) = 'CB' && lv_user.

            SELECT SINGLE PersonFullName,UserID FROM I_BusinessUserBasic WITH PRIVILEGED ACCESS
            WHERE UserID = @lv_cbuser
            INTO @DATA(lv_username).

            securityremark = |{ lv_cbuser }-{ lv_username-PersonFullName }|.
***********************************************************************

            LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<ls_head>).
                IF <ls_head> IS ASSIGNED.

                SELECT SINGLE value_low,text FROM  zgate_series_vh WITH PRIVILEGED ACCESS
                WHERE value_low = @<ls_head>-Gateentryseries
                INTO @DATA(gs_gateentryseries).

                SELECT SINGLE value_low,text FROM  zgate_num_vh WITH PRIVILEGED ACCESS
                WHERE value_low = @<ls_head>-Gateno
                INTO @DATA(gs_gateenno).

*                SELECT SINGLE * from ZSD_BP_ZTRP_VH WITH PRIVILEGED ACCESS
*                WHERE Transporterid = @lv_trans
*                INTO @DATA(ls_trans).

***********************************************************************
                SELECT SINGLE MAX( gateentryid ) AS gateentryid
                FROM zmmge_hdr_t01
                INTO @DATA(gs_id).

                IF gs_id IS NOT INITIAL.
                gateid = gs_id + 1.
                 ELSE.
                gateid = '2000000001'.
                ENDIF.

************************************************************************
                MODIFY ENTITIES OF zmmge_app1_re IN LOCAL MODE
                ENTITY GateSecEntry
                UPDATE
                FIELDS ( Gateentryid Gateentryiddate  Gateentryseriesdes
                         Gatenodes Securityremarks Createdname  )
                WITH VALUE #(  FOR key IN keys
                               ( %tky = <ls_head>-%tky
                                 Gateentryid = gateid
                                 Gateentryiddate = lv_date
                                 Gateentryseriesdes = gs_gateentryseries-text
                                 Gatenodes = gs_gateenno-text
                                 Securityremarks = securityremark
                                 Createdname = lv_username-PersonFullName

                                %control-Gateentryid = if_abap_behv=>mk-on
                                %control-Gateentryiddate = if_abap_behv=>mk-on
                                %control-Gateentryseriesdes = if_abap_behv=>mk-on
                                %control-Gatenodes = if_abap_behv=>mk-on
                                %control-Securityremarks = if_abap_behv=>mk-on
*                                %control-CreatedByDisplayName = if_abap_behv=>mk-on


                                 ) ).
************************************************************************
                ENDIF.
            ENDLOOP.
************************************************************************

  ENDMETHOD.

  METHOD gatenocheck.
************************************************************************
                READ ENTITIES OF zmmge_app1_re IN LOCAL MODE
                ENTITY GateSecEntry
                ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT DATA(lt_head)
                FAILED DATA(lt_failed).
***********************************************************************
            DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).
************************************************************************
*""""" Gate Master Validation process--*********************************

*            SELECT SINGLE * FROM zgate_num_vh WITH PRIVILEGED ACCESS
*            WHERE value_low  = @ls_head-Gateno
*            INTO @DATA(gs_gatenouser).
*
*       IF gs_gatenouser IS INITIAL.
*
*        DATA(lv_msgs) = |Gate No User Auth not Maintained|.
*        APPEND VALUE #( %tky        = ls_head-%tky
*                        %state_area = 'Validate_Head'
*                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                             text     = lv_msgs ) )
*               TO reported-gatesecentry.
*
*        APPEND VALUE #( %tky = ls_head-%tky )
*               TO failed-gatesecentry.
*       ENDIF.
*************************************************************************
       if ls_head-Vehicleno is INITIAL.

        DATA(lv_msgvn) = |Vehicle Number is Mandatory|.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgvn ) )
               TO reported-gatesecentry.

        APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-gatesecentry.
*       ELSEIF ls_head-Vehicleno is not INITIAL.
*                SELECT SINGLE uuid,vehicleno,Gateexitindicator FROM zmm_app04_hdb WITH PRIVILEGED ACCESS
*                WHERE vehicleno = @ls_head-Vehicleno
*                AND gateexitindicator is INITIAL
*                INTO @DATA(ls_vehicle).
*              if ls_vehicle-gateexitindicator is INITIAL.
*
*                DATA(lv_msgvs) = |Vehicle Still in the Plant|.
*                APPEND VALUE #( %tky        = ls_head-%tky
*                        %state_area = 'Validate_Head'
*                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                             text     = lv_msgvs ) )
*                 TO reported-gatesecentry.
*
*                APPEND VALUE #( %tky = ls_head-%tky )
*                TO failed-gatesecentry.

*              ENDIF.
       ENDIF.
************************************************************************
       if ls_head-Vehicletype is INITIAL.

        DATA(lv_msgVt) = |Vehicle Type is Mandatory|.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgVt ) )
               TO reported-gatesecentry.

        APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-gatesecentry.
       ENDIF.
************************************************************************
       if ls_head-Trasporterid is INITIAL and ls_head-GateEntrySeries = 'G1'.

        DATA(lv_msgTid) = |Transport ID is Mandatory|.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgTid ) )
               TO reported-gatesecentry.

        APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-gatesecentry.
       ENDIF.
************************************************************************
       if ls_head-Licenseno is INITIAL.

        DATA(lv_msgTli) = |License No is Mandatory|.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgTli ) )
               TO reported-gatesecentry.

        APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-gatesecentry.
       ENDIF.
************************************************************************
       if ls_head-Engineno is INITIAL.

        DATA(lv_msgTEgn) = |Engine Number is Mandatory|.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = lv_msgTEgn ) )
               TO reported-gatesecentry.

        APPEND VALUE #( %tky = ls_head-%tky )
               TO failed-gatesecentry.
       ENDIF.
************************************************************************

  ENDMETHOD.

ENDCLASS.
