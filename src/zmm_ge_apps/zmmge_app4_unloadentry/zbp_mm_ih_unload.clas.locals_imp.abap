CLASS lhc_UnloadHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR UnloadHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR UnloadHead RESULT result.

    METHODS Unloadst FOR MODIFY
      IMPORTING keys FOR ACTION UnloadHead~Unloadst RESULT result.

    METHODS UnloadEnd FOR MODIFY
      IMPORTING keys FOR ACTION UnloadHead~UnloadEnd RESULT result.

ENDCLASS.

CLASS lhc_UnloadHead IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zmm_ih_unload IN LOCAL MODE
      ENTITY UnloadHead
      FIELDS ( Unloadstindi Unloadendindi ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_head)
      ENTITY UnloadHead by \_Item
      FIELDS ( Unloadind ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_item).

    DATA(ls_head) = VALUE #( lt_head[ 1 ] OPTIONAL ).

    result = VALUE #( FOR ls_key IN lt_item
                      ( %tky              = ls_head-%tky
                        %action-Unloadst  = COND #( WHEN ls_head-Unloadstindi = 'X'
                                                    THEN if_abap_behv=>fc-o-disabled
                                                    ELSE if_abap_behv=>fc-o-enabled )
                        %action-UnloadEnd = COND #( WHEN ls_head-Unloadendindi = 'X'
                                                    THEN if_abap_behv=>fc-o-disabled
                                                    WHEN ls_head-Unloadstindi = 'X'
                                                    AND ls_key-Unloadind = abap_true
                                                    THEN if_abap_behv=>fc-o-enabled
                                                    ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD Unloadst.
    GET TIME STAMP FIELD DATA(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

    MODIFY ENTITIES OF zmm_ih_unload IN LOCAL MODE
      ENTITY UnloadHead
      UPDATE FIELDS ( Unloadstdate Unloadsttime Unloadstindi )
      WITH VALUE #( FOR ls_key IN keys
                    ( %tky         = ls_key-%tky
                      Unloadstdate = lv_date
                      Unloadsttime = lv_time
                      Unloadstindi = 'X' ) ).

    READ ENTITIES OF zmm_ih_unload IN LOCAL MODE
      ENTITY UnloadHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_ord IN lt_result
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

  METHOD UnloadEnd.
    GET TIME STAMP FIELD DATA(ts).
    CONVERT TIME STAMP ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

    MODIFY ENTITIES OF zmm_ih_unload IN LOCAL MODE
      ENTITY UnloadHead
      UPDATE FIELDS ( Unloadenddate Unloadendtime Unloadendindi )
      WITH VALUE #( FOR ls_key IN keys
                    ( %tky          = ls_key-%tky
                      Unloadenddate = lv_date
                      Unloadendtime = lv_time
                      Unloadendindi = 'X' ) ).

    READ ENTITIES OF zmm_ih_unload IN LOCAL MODE
      ENTITY UnloadHead
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_ord IN lt_result
                      ( %tky   = ls_ord-%tky
                        %param = ls_ord ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_UnloadItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR UnloadItem RESULT result.

ENDCLASS.

CLASS lhc_UnloadItem IMPLEMENTATION.

  METHOD get_instance_features.
    " Empty as in S/4: update / delete stay enabled.
  ENDMETHOD.

ENDCLASS.

