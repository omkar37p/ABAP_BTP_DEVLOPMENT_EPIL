CLASS zweigh_form_imp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
ENDCLASS.


CLASS zweigh_form_imp IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    DATA lt_result TYPE STANDARD TABLE OF zsd_ce_weight WITH EMPTY KEY.
    DATA lv_uuid   TYPE sysuuid_x16.

    IF NOT io_request->is_data_requested( ).
      RETURN.
    ENDIF.

    TRY.
        DATA(lt_range) = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        RETURN.
    ENDTRY.

    IF NOT line_exists( lt_range[ name = 'UUID' ] ).
      " the slip is always read for one gate entry (FDP key UUID)
      io_response->set_data( lt_result ).
      io_response->set_total_number_of_records( 0 ).
      RETURN.
    ENDIF.

    LOOP AT lt_range[ name = 'UUID' ]-range INTO DATA(ls_uuid).
      lv_uuid = ls_uuid-low.

      SELECT SINGLE uuid, vehicleno, gateentryno, gateentrydate, weighuom, tarewt
        FROM zsdge_sentry_ht1
        WHERE uuid = @lv_uuid
        INTO @DATA(ls_gate).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      SELECT baseunit, grossweight, netweight
        FROM zsdge_sentry_it1
        WHERE uuid = @lv_uuid
        ORDER BY salesdocument, salesitem
        INTO TABLE @DATA(lt_item).

      APPEND VALUE #( uuid          = ls_gate-uuid
                      gateentryno   = ls_gate-gateentryno
                      vehicleno     = ls_gate-vehicleno
                      gateentrydate = ls_gate-gateentrydate
                      weighuom      = ls_gate-weighuom
                      tarewt        = ls_gate-tarewt
                      baseunit      = VALUE #( lt_item[ 1 ]-baseunit OPTIONAL )
                      grossweight   = VALUE #( lt_item[ 1 ]-grossweight OPTIONAL )
                      netweight     = REDUCE #( INIT n = CONV zsd_ce_weight-netweight( 0 )
                                                FOR itm IN lt_item NEXT n = n + itm-netweight ) )
             TO lt_result.
    ENDLOOP.

    io_response->set_data( lt_result ).
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_result ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

