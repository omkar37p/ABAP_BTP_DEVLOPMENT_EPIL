*----------------------------------------------------------------*
* SYSTEM: BTP ABAP Environment   Package: ZSDGE_APP5_LOAD
* ADT object: Class (behavior pool)   ZBP_SD_IH_LOAD - Local Types tab
*
* Changes vs S/4:
*   - get_global_authorizations removed (header create is gone)
*   - item get_instance_features removed (the BDEF item update has no
*     feature control any more; the S/4 method was empty)
*   - feature control: one result per entry. S/4 gave every key the
*     first entry's %tky.
*   - imagecount determination: one update per changed item. S/4 wrote
*     each item once per key (FOR key IN keys) and also read the header
*     with item keys, which it didn't use.
*   - Itemimagecount is int4 in BTP (NUMC2 in S/4): 1 / 0 instead of
*     '01' / '00'
*   - action results are read again after the update
*   LoadSt / Loadend logic unchanged (Loading Finished sets Loadendindi,
*   which enables the item weight actions in Outgoing Weighment).
*----------------------------------------------------------------*
CLASS lhc_LoadHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR LoadHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR LoadHead RESULT result.

    METHODS LoadSt FOR MODIFY
      IMPORTING keys FOR ACTION LoadHead~LoadSt RESULT result.

    METHODS Loadend FOR MODIFY
      IMPORTING keys FOR ACTION LoadHead~Loadend RESULT result.

ENDCLASS.

CLASS lhc_LoadHead IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zsd_ih_load IN LOCAL MODE
      ENTITY LoadHead
        FIELDS ( Loadstindi Loadendindi ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).

    result = VALUE #( FOR ls_head IN lt_head
                      ( %tky           = ls_head-%tky
                        %update        = if_abap_behv=>fc-o-enabled
                        %action-Edit   = if_abap_behv=>fc-o-enabled
                        %action-LoadSt = COND #( WHEN ls_head-Loadstindi = 'X'
                                                 THEN if_abap_behv=>fc-o-disabled
                                                 ELSE if_abap_behv=>fc-o-enabled )
                        %action-Loadend = COND #( WHEN ls_head-Loadendindi IS INITIAL AND ls_head-Loadstindi = 'X'
                                                  THEN if_abap_behv=>fc-o-enabled
                                                  ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD LoadSt.
    GET TIME STAMP FIELD DATA(lv_ts).
    CONVERT TIME STAMP lv_ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

    MODIFY ENTITIES OF zsd_ih_load IN LOCAL MODE
      ENTITY LoadHead
        UPDATE FIELDS ( Loadstdate Loadsttime Loadstindi Loadendindi )
        WITH VALUE #( FOR key IN keys
                      ( %tky        = key-%tky
                        Loadstdate  = lv_date
                        Loadsttime  = lv_time
                        Loadstindi  = 'X'
                        Loadendindi = ' ' ) ).

    READ ENTITIES OF zsd_ih_load IN LOCAL MODE
      ENTITY LoadHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD Loadend.
    GET TIME STAMP FIELD DATA(lv_ts).
    CONVERT TIME STAMP lv_ts TIME ZONE 'INDIA' INTO DATE DATA(lv_date) TIME DATA(lv_time).

    MODIFY ENTITIES OF zsd_ih_load IN LOCAL MODE
      ENTITY LoadHead
        UPDATE FIELDS ( Loadenddate Loadendtime Loadendindi )
        WITH VALUE #( FOR key IN keys
                      ( %tky        = key-%tky
                        Loadenddate = lv_date
                        Loadendtime = lv_time
                        Loadendindi = 'X' ) ).

    READ ENTITIES OF zsd_ih_load IN LOCAL MODE
      ENTITY LoadHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_LoadItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS imagecount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR LoadItem~imagecount.

ENDCLASS.

CLASS lhc_LoadItem IMPLEMENTATION.

  METHOD imagecount.
    " Loading Checkbox ticked = 1 image for this item (Weighment compares
    " the sum with the header image count before starting the camera)
    READ ENTITIES OF zsd_ih_load IN LOCAL MODE
      ENTITY LoadItem
        FIELDS ( Loadcheck ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item).

    MODIFY ENTITIES OF zsd_ih_load IN LOCAL MODE
      ENTITY LoadItem
        UPDATE FIELDS ( Itemimagecount )
        WITH VALUE #( FOR ls_item IN lt_item
                      ( %tky           = ls_item-%tky
                        Itemimagecount = COND #( WHEN ls_item-Loadcheck = abap_true THEN 1 ELSE 0 ) ) ).
  ENDMETHOD.

ENDCLASS.

