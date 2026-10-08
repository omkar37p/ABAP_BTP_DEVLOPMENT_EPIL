CLASS lhc_ExitHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ExitHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ExitHead RESULT result.

    METHODS GateExit FOR MODIFY
      IMPORTING keys FOR ACTION ExitHead~GateExit RESULT result.

    METHODS ImageVald FOR MODIFY
      IMPORTING keys FOR ACTION ExitHead~ImageVald RESULT result.

ENDCLASS.

CLASS lhc_ExitHead IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zsd_ih_gexit IN LOCAL MODE
      ENTITY ExitHead
        FIELDS ( Exitindic Imagevalid ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).

    result = VALUE #( FOR ls_head IN lt_head
                      ( %tky              = ls_head-%tky
                        %update           = if_abap_behv=>fc-o-enabled
                        %action-Edit      = if_abap_behv=>fc-o-enabled
                        %action-GateExit  = COND #( WHEN ls_head-Exitindic = 'X'
                                                    THEN if_abap_behv=>fc-o-disabled
                                                    WHEN ls_head-Imagevalid = 'X'
                                                    THEN if_abap_behv=>fc-o-enabled
                                                    ELSE if_abap_behv=>fc-o-disabled )
                        %action-ImageVald = COND #( WHEN ls_head-Imagevalid = 'X'
                                                    THEN if_abap_behv=>fc-o-disabled
                                                    ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD GateExit.
    GET TIME STAMP FIELD DATA(lv_ts).
    CONVERT TIME STAMP lv_ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

    MODIFY ENTITIES OF zsd_ih_gexit IN LOCAL MODE
      ENTITY ExitHead
        UPDATE FIELDS ( Gateexitdate Gateexittime Exitindic )
        WITH VALUE #( FOR key IN keys
                      ( %tky         = key-%tky
                        Gateexitdate = lv_date
                        Gateexittime = lv_time
                        Exitindic    = 'X' ) ).

    READ ENTITIES OF zsd_ih_gexit IN LOCAL MODE
      ENTITY ExitHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD ImageVald.
    MODIFY ENTITIES OF zsd_ih_gexit IN LOCAL MODE
      ENTITY ExitHead
        UPDATE FIELDS ( Imagevalid )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky  Imagevalid = 'X' ) ).

    READ ENTITIES OF zsd_ih_gexit IN LOCAL MODE
      ENTITY ExitHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

ENDCLASS.

