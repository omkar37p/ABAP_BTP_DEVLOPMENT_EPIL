CLASS zentry_form_imp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zentry_form_imp IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    DATA rt_table TYPE TABLE OF zsd_hce_gatesec.
    DATA lv_uuid  TYPE zsd_hce_gatesec-uuid.

    IF NOT io_request->is_data_requested( ).
      RETURN.
    ENDIF.

    TRY.
        DATA(lt_range) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        RETURN.
    ENDTRY.

    IF NOT line_exists( lt_range[ name = 'UUID' ] ).
      RETURN.
    ENDIF.

    LOOP AT lt_range[ name = 'UUID' ]-range ASSIGNING FIELD-SYMBOL(<ls>).
      lv_uuid = <ls>-low.

      SELECT SINGLE uuid, gateentryid, vehicleno, gateentryiddate, gateentryidtime
        FROM zsdge_sentry_ht1 WITH PRIVILEGED ACCESS
        WHERE uuid = @lv_uuid
        INTO @DATA(ls_gate).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      INSERT VALUE zsd_hce_gatesec( uuid          = ls_gate-uuid
                                    gateentryid   = ls_gate-gateentryid
                                    vehicleno     = ls_gate-vehicleno
                                    gateentrydate = ls_gate-gateentryiddate
                                    gateentrytime = ls_gate-gateentryidtime )
             INTO TABLE rt_table.
    ENDLOOP.

    io_response->set_data( rt_table ).
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( rt_table ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

