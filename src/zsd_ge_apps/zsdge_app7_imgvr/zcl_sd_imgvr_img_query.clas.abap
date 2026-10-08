CLASS zcl_sd_imgvr_img_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PRIVATE SECTION.
    TYPES tt_result TYPE STANDARD TABLE OF zsd_ce_imgvr_img WITH EMPTY KEY.

    "! The 4 images of one CamView record (or one row with the error)
    METHODS add_stage
      IMPORTING iv_uuid   TYPE sysuuid_x16
                iv_stage  TYPE c
                iv_seqno  TYPE clike
      CHANGING  ct_result TYPE tt_result.
ENDCLASS.


CLASS zcl_sd_imgvr_img_query IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    DATA lt_result TYPE tt_result.
    DATA lt_ranges TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA lv_uuid   TYPE sysuuid_x16.

    TRY.
        lt_ranges = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        CLEAR lt_ranges.
    ENDTRY.

    " the gate entry: UUID eq <value> (hex, with or without dashes)
    READ TABLE lt_ranges INTO DATA(ls_range) WITH KEY name = 'UUID'.
    IF sy-subrc = 0 AND lines( ls_range-range ) = 1 AND ls_range-range[ 1 ]-option = 'EQ'.
      DATA(lv_hex) = to_upper( replace( val = CONV string( ls_range-range[ 1 ]-low ) sub = `-` with = `` occ = 0 ) ).
      lv_uuid = lv_hex.
    ENDIF.

    IF lv_uuid IS NOT INITIAL.
      SELECT SINGLE imgseqnotare, imgseqnogross
        FROM zsdge_sentry_ht1
        WHERE uuid = @lv_uuid
        INTO @DATA(ls_head).
      IF sy-subrc = 0.
        IF ls_head-imgseqnotare IS NOT INITIAL.
          add_stage( EXPORTING iv_uuid = lv_uuid iv_stage = 'T' iv_seqno = ls_head-imgseqnotare
                     CHANGING  ct_result = lt_result ).
        ENDIF.
        IF ls_head-imgseqnogross IS NOT INITIAL.
          add_stage( EXPORTING iv_uuid = lv_uuid iv_stage = 'G' iv_seqno = ls_head-imgseqnogross
                     CHANGING  ct_result = lt_result ).
        ENDIF.
      ENDIF.
    ENDIF.

    " sorting / paging done here (at most 8 rows); the framework expects
    " get_sort_elements and get_paging to be read
    io_request->get_sort_elements( ).
    SORT lt_result BY Stage DESCENDING Imageno ASCENDING.   " T (tare) before G (gross)

    DATA(lv_total) = CONV int8( lines( lt_result ) ).
    DATA(lo_paging) = io_request->get_paging( ).
    DATA(lv_offset) = lo_paging->get_offset( ).
    DATA(lv_size)   = lo_paging->get_page_size( ).
    IF lv_offset > 0.
      DELETE lt_result TO lv_offset.
    ENDIF.
    IF lv_size <> if_rap_query_paging=>page_size_unlimited AND lines( lt_result ) > lv_size.
      DATA(lv_from) = lv_size + 1.
      DELETE lt_result FROM lv_from.
    ENDIF.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_result ).
    ENDIF.
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lv_total ).
    ENDIF.
  ENDMETHOD.

  METHOD add_stage.
    DATA(lv_stagetext) = COND string( WHEN iv_stage = 'T' THEN `Tare` ELSE `Gross` ).
    DATA(ls_record)    = zcl_sd_camview_api=>get_record( iv_seqno ).

    IF ls_record-ok = abap_false.
      APPEND VALUE #( Uuid      = iv_uuid
                      Stage     = iv_stage
                      Imageno   = 0
                      Stagetext = lv_stagetext
                      Rowidseq  = iv_seqno
                      Message   = ls_record-message ) TO ct_result.
      RETURN.
    ENDIF.

    DATA(lt_images) = VALUE string_table( ( ls_record-image1 ) ( ls_record-image2 )
                                          ( ls_record-image3 ) ( ls_record-image4 ) ).
    LOOP AT lt_images INTO DATA(lv_image).
      IF lv_image IS INITIAL.
        CONTINUE.
      ENDIF.
      APPEND VALUE #( Uuid       = iv_uuid
                      Stage      = iv_stage
                      Imageno    = sy-tabix
                      Stagetext  = lv_stagetext
                      Rowidseq   = iv_seqno
                      Imageurl   = |data:image/jpeg;base64,{ lv_image }|
                      Camweight  = ls_record-wb_wt
                      Ocrtext    = ls_record-ocr_text
                      Capturedat = replace( val = ls_record-timestamp sub = `T` with = ` ` ) ) TO ct_result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

