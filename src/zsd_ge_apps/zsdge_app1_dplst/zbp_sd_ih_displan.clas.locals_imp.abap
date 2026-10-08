CLASS lcl_conv DEFINITION FINAL.
  PUBLIC SECTION.
    "! Excel date cell (serial number) or text date -> ABAP date.
    "! Returns initial when the text can't be read as a date.
    CLASS-METHODS to_date
      IMPORTING iv_text        TYPE string
      RETURNING VALUE(rv_date) TYPE d.

    "! Text with optional thousand separators -> quantity
    CLASS-METHODS to_qty
      IMPORTING iv_text       TYPE string
      RETURNING VALUE(rv_qty) TYPE menge_d
      RAISING   cx_sy_conversion_error.
ENDCLASS.

CLASS lcl_conv IMPLEMENTATION.

  METHOD to_date.
    DATA lv_d TYPE string.
    DATA lv_m TYPE string.
    DATA lv_y TYPE string.

    " drop a time part, e.g. '05.10.2026 00:00:00'
    DATA(lv_full) = condense( iv_text ).
    SPLIT lv_full AT space INTO DATA(lv_text) DATA(lv_rest) ##NEEDED.
    IF lv_text IS INITIAL.
      RETURN.
    ENDIF.

    " same separator for all text formats
    DATA(lv_dots) = replace( val = lv_text pcre = `[/-]` with = `.` occ = 0 ).

    IF matches( val = lv_text pcre = `\d{1,5}(\.\d+)?` ).
      " Excel date cell: days since 30.12.1899
      SPLIT lv_text AT '.' INTO DATA(lv_days) DATA(lv_frac) ##NEEDED.
      rv_date = '18991230'.
      rv_date = rv_date + CONV i( lv_days ).
      RETURN.
    ELSEIF matches( val = lv_text pcre = `\d{8}` ).
      lv_y = lv_text(4).
      lv_m = lv_text+4(2).
      lv_d = lv_text+6(2).
    ELSEIF matches( val = lv_dots pcre = `\d{4}\.\d{1,2}\.\d{1,2}` ).
      SPLIT lv_dots AT '.' INTO lv_y lv_m lv_d.
    ELSEIF matches( val = lv_dots pcre = `\d{1,2}\.\d{1,2}\.\d{4}` ).
      SPLIT lv_dots AT '.' INTO lv_d lv_m lv_y.
    ELSE.
      RETURN.
    ENDIF.

    IF CONV i( lv_m ) NOT BETWEEN 1 AND 12 OR CONV i( lv_d ) NOT BETWEEN 1 AND 31.
      RETURN.
    ENDIF.

    rv_date = |{ lv_y }{ lv_m WIDTH = 2 ALIGN = RIGHT PAD = '0' }{ lv_d WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.
  ENDMETHOD.

  METHOD to_qty.
    DATA(lv_text) = replace( val = replace( val = iv_text sub = `,` with = `` occ = 0 )
                             sub = ` ` with = `` occ = 0 ).
    IF lv_text IS INITIAL.
      RETURN.
    ENDIF.
    rv_qty = lv_text.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_DispHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR DispHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR DispHead RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR DispHead RESULT result.

    METHODS ExcelUpload FOR MODIFY
      IMPORTING keys FOR ACTION DispHead~ExcelUpload RESULT result.

    METHODS attach FOR DETERMINE ON MODIFY
      IMPORTING keys FOR DispHead~attach.

ENDCLASS.

CLASS lhc_DispHead IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD ExcelUpload.
***********************************************************************
    " Excel columns, in this order (row 1 = column titles)
    TYPES: BEGIN OF ty_excel,
             slno           TYPE string,
             dispatchdate   TYPE string,
             customer       TYPE string,
             plant          TYPE string,
             transmode      TYPE string,
             salesorder     TYPE string,
             salesorderitem TYPE string,
             material       TYPE string,
             baseunit       TYPE string,
             totalorderqty  TYPE string,
             dispplantqty   TYPE string,
             vehicleno      TYPE string,
           END OF ty_excel.
***********************************************************************
    DATA lt_excel TYPE STANDARD TABLE OF ty_excel WITH EMPTY KEY.
    DATA lt_cba   TYPE TABLE FOR CREATE zsd_ih_displan\\DispHead\_SalesItem.
    DATA ls_cba   LIKE LINE OF lt_cba.
    DATA lt_upd   TYPE TABLE FOR UPDATE zsd_ih_displan\\DispHead.
***********************************************************************
    READ ENTITIES OF zsd_ih_displan IN LOCAL MODE
      ENTITY DispHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).
***********************************************************************
    LOOP AT lt_head INTO DATA(ls_head).

      IF ls_head-Attachment IS INITIAL.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'Attach the Excel file first' ) )
               TO reported-disphead.
        CONTINUE.
      ENDIF.

      " read sheet 1 into lt_excel (all cells as text)
      CLEAR lt_excel.
      TRY.
          DATA(lo_worksheet) = xco_cp_xlsx=>document->for_file_content( iv_file_content = ls_head-Attachment
                                 )->read_access( )->get_workbook( )->worksheet->at_position( 1 ).
          DATA(lo_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
          DATA(lo_execute) = lo_worksheet->select( lo_pattern )->row_stream( )->operation->write_to( REF #( lt_excel ) ).
          lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
                    )->if_xco_xlsx_ra_operation~execute( ).
        CATCH cx_root.
          APPEND VALUE #( %tky = ls_head-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = 'The file could not be read. Upload an .xlsx file.' ) )
                 TO reported-disphead.
          CONTINUE.
      ENDTRY.

      DELETE lt_excel INDEX 1.     " column titles

      CLEAR ls_cba.
      ls_cba-%tky = ls_head-%tky.
      DATA(lv_ok) = abap_true.

      LOOP AT lt_excel INTO DATA(ls_row).
        DATA(lv_rowno) = sy-tabix + 1.   " row number as shown in Excel

        IF condense( ls_row-salesorder ) = ``.
          CONTINUE.                      " blank row
        ENDIF.

        DATA(lv_so)   = CONV vbeln( |{ condense( ls_row-salesorder ) ALPHA = IN WIDTH = 10 }| ).
        DATA(lv_item) = CONV posnr( condense( ls_row-salesorderitem ) ).

        IF line_exists( ls_cba-%target[ Salesorder = lv_so Salesorderitem = lv_item ] ).
          APPEND VALUE #( %tky = ls_head-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = |Row { lv_rowno }: order { ls_row-salesorder } item { ls_row-salesorderitem } is in the file twice| ) )
                 TO reported-disphead.
          lv_ok = abap_false.
          CONTINUE.
        ENDIF.

        DATA(lv_date) = lcl_conv=>to_date( ls_row-dispatchdate ).
        IF lv_date IS INITIAL AND condense( ls_row-dispatchdate ) <> ``.
          APPEND VALUE #( %tky = ls_head-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = |Row { lv_rowno }: dispatch date '{ ls_row-dispatchdate }' is not a valid date| ) )
                 TO reported-disphead.
          lv_ok = abap_false.
          CONTINUE.
        ENDIF.

        TRY.
            DATA(lv_totqty)  = lcl_conv=>to_qty( ls_row-totalorderqty ).
            DATA(lv_dispqty) = lcl_conv=>to_qty( ls_row-dispplantqty ).
          CATCH cx_sy_conversion_error.
            APPEND VALUE #( %tky = ls_head-%tky
                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text     = |Row { lv_rowno }: quantity is not a number| ) )
                   TO reported-disphead.
            lv_ok = abap_false.
            CONTINUE.
        ENDTRY.

        APPEND VALUE #( %is_draft      = ls_head-%is_draft
                        Salesorder     = lv_so
                        Salesorderitem = lv_item
                        Slno           = condense( ls_row-slno )
                        Dispatchdate   = lv_date
                        Customer       = condense( ls_row-customer )
                        Plant          = to_upper( condense( ls_row-plant ) )
                        Transmode      = condense( ls_row-transmode )
                        Material       = to_upper( condense( ls_row-material ) )
                        Baseunit       = to_upper( condense( ls_row-baseunit ) )
                        Totalorderqty  = lv_totqty
                        Dispplantqty   = lv_dispqty
                        Vehicleno      = to_upper( condense( ls_row-vehicleno ) ) )
               TO ls_cba-%target.
      ENDLOOP.

      IF lv_ok = abap_false.
        CONTINUE.                        " nothing is created for this file
      ENDIF.

      IF ls_cba-%target IS INITIAL.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'The file has no order rows' ) )
               TO reported-disphead.
        CONTINUE.
      ENDIF.

      SORT ls_cba-%target BY Salesorder Salesorderitem.
      APPEND ls_cba TO lt_cba.
    ENDLOOP.
***********************************************************************
    IF lt_cba IS NOT INITIAL.

      MODIFY ENTITIES OF zsd_ih_displan IN LOCAL MODE
        ENTITY DispHead
          CREATE BY \_SalesItem
          AUTO FILL CID
          FIELDS ( Salesorder Salesorderitem Slno Dispatchdate Customer Plant Transmode
                   Material Baseunit Totalorderqty Dispplantqty Vehicleno )
          WITH lt_cba
        MAPPED   DATA(lt_mapped)
        FAILED   DATA(lt_failed)
        REPORTED DATA(lt_reported).

      APPEND LINES OF lt_failed-salesorder     TO failed-salesorder.
      APPEND LINES OF lt_reported-salesorder   TO reported-salesorder.
      APPEND LINES OF lt_reported-disphead     TO reported-disphead.

      " headers that got items -> Active
      LOOP AT lt_cba INTO ls_cba.
        IF line_exists( lt_mapped-salesorder[ Uuid = ls_cba-Uuid ] ).
          APPEND VALUE #( %tky         = ls_cba-%tky
                          Status       = 'X'
                          UploadStatus = 'Active' ) TO lt_upd.
          APPEND VALUE #( %tky = ls_cba-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                        text     = |{ lines( ls_cba-%target ) } order rows uploaded| ) )
                 TO reported-disphead.
        ENDIF.
      ENDLOOP.

      IF lt_upd IS NOT INITIAL.
        MODIFY ENTITIES OF zsd_ih_displan IN LOCAL MODE
          ENTITY DispHead
            UPDATE FIELDS ( Status UploadStatus )
            WITH lt_upd.
      ENDIF.

    ENDIF.
***********************************************************************
    READ ENTITIES OF zsd_ih_displan IN LOCAL MODE
      ENTITY DispHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                      ( %tky   = ls_res-%tky
                        %param = ls_res ) ).
***********************************************************************
  ENDMETHOD.
***********************************************************************

  METHOD attach.
***********************************************************************
    READ ENTITIES OF zsd_ih_displan IN LOCAL MODE
      ENTITY DispHead
        FIELDS ( Attachment ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).
***********************************************************************
    MODIFY ENTITIES OF zsd_ih_displan IN LOCAL MODE
      ENTITY DispHead
        UPDATE FIELDS ( Filename Minetype )
        WITH VALUE #( FOR ls_head IN lt_head WHERE ( Attachment IS NOT INITIAL )
                      ( %tky     = ls_head-%tky
                        Filename = 'DispatchPlan.xlsx'
                        Minetype = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ) ).
  ENDMETHOD.

ENDCLASS.


CLASS lhc_SalesOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR SalesOrder RESULT result.

ENDCLASS.

CLASS lhc_SalesOrder IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.

