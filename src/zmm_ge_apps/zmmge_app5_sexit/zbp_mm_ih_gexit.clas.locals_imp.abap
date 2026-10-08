CLASS lhc_GateExitHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateExitHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR GateExitHead RESULT result.

    METHODS GateExit FOR MODIFY
      IMPORTING keys FOR ACTION GateExitHead~GateExit RESULT result.

    METHODS ImageVald FOR MODIFY
      IMPORTING keys FOR ACTION GateExitHead~ImageVald RESULT result.

ENDCLASS.

CLASS lhc_GateExitHead IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zmm_ih_gexit IN LOCAL MODE
      ENTITY GateExitHead
      FIELDS ( Gateexitindicator Exitindicator ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_head).

    result = VALUE #( FOR ls_head IN lt_head
                      ( %tky              = ls_head-%tky
                        %action-GateExit  = COND #( WHEN ls_head-Gateexitindicator = 'X'
                                                    THEN if_abap_behv=>fc-o-disabled
                                                    WHEN ls_head-Exitindicator = 'X'
                                                    THEN if_abap_behv=>fc-o-enabled
                                                    ELSE if_abap_behv=>fc-o-disabled )
                        %action-ImageVald = COND #( WHEN ls_head-Exitindicator = 'X'
                                                    THEN if_abap_behv=>fc-o-disabled
                                                    ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD GateExit.
    GET TIME STAMP FIELD DATA(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

    MODIFY ENTITIES OF zmm_ih_gexit IN LOCAL MODE
      ENTITY GateExitHead
      UPDATE FIELDS ( Gateexitdate Gateexittime Gateexitindicator )
      WITH VALUE #( FOR ls_key IN keys
                    ( %tky              = ls_key-%tky
                      Gateexitdate      = lv_date
                      Gateexittime      = lv_time
                      Gateexitindicator = 'X' ) ).

    READ ENTITIES OF zmm_ih_gexit IN LOCAL MODE
      ENTITY GateExitHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_ord IN lt_result
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

  METHOD ImageVald.
    MODIFY ENTITIES OF zmm_ih_gexit IN LOCAL MODE
      ENTITY GateExitHead
      UPDATE FIELDS ( Exitindicator )
      WITH VALUE #( FOR ls_key IN keys
                    ( %tky          = ls_key-%tky
                      Exitindicator = 'X' ) ).

    READ ENTITIES OF zmm_ih_gexit IN LOCAL MODE
      ENTITY GateExitHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_ord IN lt_result
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_GateExitItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR GateExitItem RESULT result.

ENDCLASS.

CLASS lhc_GateExitItem IMPLEMENTATION.

  METHOD get_instance_features.
    " Empty as in S/4: update / delete stay enabled (all fields are read-only).
  ENDMETHOD.

ENDCLASS.

