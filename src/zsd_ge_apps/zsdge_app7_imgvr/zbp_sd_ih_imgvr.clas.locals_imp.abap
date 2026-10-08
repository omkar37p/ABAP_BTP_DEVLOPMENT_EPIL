CLASS lhc_ImgVerify DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES ty_head   TYPE STRUCTURE FOR READ RESULT zsd_ih_imgvr\\ImgVerify.
    TYPES ty_update TYPE STRUCTURE FOR UPDATE zsd_ih_imgvr\\ImgVerify.
    TYPES tt_update TYPE TABLE FOR UPDATE zsd_ih_imgvr\\ImgVerify.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ImgVerify RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ImgVerify RESULT result.

    METHODS Approve FOR MODIFY
      IMPORTING keys FOR ACTION ImgVerify~Approve RESULT result.

    METHODS Reject FOR MODIFY
      IMPORTING keys FOR ACTION ImgVerify~Reject RESULT result.

    "! The update for one decision (A / R) on the pending stage
    METHODS decide
      IMPORTING is_head          TYPE ty_head
                iv_decision      TYPE c
                iv_reason        TYPE clike OPTIONAL
      RETURNING VALUE(rs_update) TYPE ty_update.

    METHODS save_decisions
      IMPORTING it_update TYPE tt_update.

    METHODS status_text
      IMPORTING iv_status      TYPE c
      RETURNING VALUE(rv_text) TYPE string.

    METHODS status_criticality
      IMPORTING iv_status             TYPE c
      RETURNING VALUE(rv_criticality) TYPE int1.
ENDCLASS.

CLASS lhc_ImgVerify IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zsd_ih_imgvr IN LOCAL MODE
      ENTITY ImgVerify
        FIELDS ( Pendingstage ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).

    result = VALUE #( FOR h IN lt_head
                      LET lv_fc = COND #( WHEN h-Pendingstage IS INITIAL
                                          THEN if_abap_behv=>fc-o-disabled
                                          ELSE if_abap_behv=>fc-o-enabled ) IN
                      ( %tky           = h-%tky
                        %action-Approve = lv_fc
                        %action-Reject  = lv_fc ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD Approve.
    DATA lt_update TYPE tt_update.

    READ ENTITIES OF zsd_ih_imgvr IN LOCAL MODE
      ENTITY ImgVerify ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_head).

    LOOP AT lt_head INTO DATA(ls_head).
      IF ls_head-Pendingstage IS INITIAL.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-imgverify.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = |{ ls_head-Gateentryno }: no images waiting for verification| ) )
               TO reported-imgverify.
        CONTINUE.
      ENDIF.

      APPEND decide( is_head = ls_head iv_decision = 'A' ) TO lt_update.
      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-success
                               text     = COND #( WHEN ls_head-Pendingstage = 'T'
                                                  THEN |{ ls_head-Gateentryno }: tare images approved, released for loading|
                                                  ELSE |{ ls_head-Gateentryno }: gross images approved, Create Delivery enabled| ) ) )
             TO reported-imgverify.
    ENDLOOP.

    save_decisions( lt_update ).

    READ ENTITIES OF zsd_ih_imgvr IN LOCAL MODE
      ENTITY ImgVerify ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD Reject.
    DATA lt_update TYPE tt_update.

    READ ENTITIES OF zsd_ih_imgvr IN LOCAL MODE
      ENTITY ImgVerify ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_head).

    LOOP AT lt_head INTO DATA(ls_head).
      DATA(lv_reason) = condense( CONV string( keys[ KEY id %tky = ls_head-%tky ]-%param-Reason ) ).

      IF ls_head-Pendingstage IS INITIAL OR lv_reason IS INITIAL.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-imgverify.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = COND #( WHEN ls_head-Pendingstage IS INITIAL
                                                    THEN |{ ls_head-Gateentryno }: no images waiting for verification|
                                                    ELSE `Enter a reject reason` ) ) )
               TO reported-imgverify.
        CONTINUE.
      ENDIF.

      APPEND decide( is_head = ls_head iv_decision = 'R' iv_reason = lv_reason ) TO lt_update.
      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-success
                               text     = |{ ls_head-Gateentryno }: { to_lower( ls_head-Pendingstagetext ) } images rejected, recapture in Outgoing Weighment| ) )
             TO reported-imgverify.
    ENDLOOP.

    save_decisions( lt_update ).

    READ ENTITIES OF zsd_ih_imgvr IN LOCAL MODE
      ENTITY ImgVerify ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD decide.
    DATA lv_ts TYPE timestampl.
    GET TIME STAMP FIELD lv_ts.

    DATA(lv_tare)  = is_head-Imgvrstatustare.
    DATA(lv_gross) = is_head-Imgvrstatusgross.
    IF lv_tare = 'P'.
      lv_tare = iv_decision.
    ELSE.
      lv_gross = iv_decision.
    ENDIF.

    rs_update = VALUE #(
      %tky               = is_head-%tky
      Imgvrstatustare    = lv_tare
      Imgvrstatusgross   = lv_gross
      " gross approved = images valid for Create Delivery
      Imagevalid         = COND #( WHEN is_head-Pendingstage = 'G' AND iv_decision = 'A' THEN 'X'
                                   WHEN is_head-Pendingstage = 'G'                     THEN ''
                                   ELSE is_head-Imagevalid )
      Imgrejreason       = COND #( WHEN iv_decision = 'R' THEN iv_reason ELSE '' )
      Imgverifiedby      = cl_abap_context_info=>get_user_technical_name( )
      Imgverifiedat      = lv_ts
      " calculated fields, so the result shows the new state at once
      Pendingstage       = COND #( WHEN lv_tare = 'P' THEN 'T' WHEN lv_gross = 'P' THEN 'G' ELSE '' )
      Pendingstagetext   = COND #( WHEN lv_tare = 'P' THEN 'Tare' WHEN lv_gross = 'P' THEN 'Gross' ELSE '' )
      Ispending          = COND #( WHEN lv_tare = 'P' OR lv_gross = 'P' THEN 'X' ELSE '' )
      Imgstatustaretext  = status_text( lv_tare )
      Imgcrittare        = status_criticality( lv_tare )
      Imgstatusgrosstext = status_text( lv_gross )
      Imgcritgross       = status_criticality( lv_gross ) ).
  ENDMETHOD.

  METHOD save_decisions.
    CHECK it_update IS NOT INITIAL.
    DATA(lt_update) = it_update.   " MODIFY ENTITIES needs a changeable table
    MODIFY ENTITIES OF zsd_ih_imgvr IN LOCAL MODE
      ENTITY ImgVerify
        UPDATE FIELDS ( Imgvrstatustare Imgvrstatusgross Imagevalid Imgrejreason
                        Imgverifiedby Imgverifiedat
                        Pendingstage Pendingstagetext Ispending
                        Imgstatustaretext Imgcrittare Imgstatusgrosstext Imgcritgross )
        WITH lt_update.
  ENDMETHOD.

  METHOD status_text.
    rv_text = SWITCH #( iv_status WHEN 'P' THEN `Pending`
                                  WHEN 'A' THEN `Approved`
                                  WHEN 'R' THEN `Rejected`
                                  ELSE `Not captured` ).
  ENDMETHOD.

  METHOD status_criticality.
    rv_criticality = SWITCH #( iv_status WHEN 'P' THEN 2
                                         WHEN 'A' THEN 3
                                         WHEN 'R' THEN 1
                                         ELSE 0 ).
  ENDMETHOD.

ENDCLASS.

