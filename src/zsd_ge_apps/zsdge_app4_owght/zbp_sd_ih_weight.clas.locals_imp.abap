*----------------------------------------------------------------*
* Weighbridge REST client (local helper)
*----------------------------------------------------------------*
CLASS lcl_weighbridge DEFINITION FINAL.
  PUBLIC SECTION.
    CONSTANTS c_api_key TYPE string VALUE 'enviro-1-15sep-2026-wb1-mm'.

    TYPES ty_weight TYPE zsdge_sentry_ht1-tarewt.
    TYPES ty_mcno   TYPE c LENGTH 10.
    TYPES ty_mcndes TYPE c LENGTH 60.

    TYPES: BEGIN OF ty_reading,
             ok      TYPE abap_bool,
             weight  TYPE ty_weight,
             mcno    TYPE ty_mcno,
             mcndes  TYPE ty_mcndes,
             message TYPE string,
           END OF ty_reading.

    "! GET <machine URL>/weight
    CLASS-METHODS read_weight
      IMPORTING iv_mcno           TYPE clike
      RETURNING VALUE(rs_reading) TYPE ty_reading.

    TYPES: BEGIN OF ty_launch,
             ok      TYPE abap_bool,
             seqno   TYPE c LENGTH 20,
             message TYPE string,
           END OF ty_launch.

    "! POST <machine URL>/launch - starts the camera. The seqno sent is
    "! the CamView rowid_seq the verification app reads the images with.
    CLASS-METHODS launch_camera
      IMPORTING iv_mcno          TYPE clike
      RETURNING VALUE(rs_launch) TYPE ty_launch.

    CLASS-METHODS machine_text
      IMPORTING iv_mcno          TYPE clike
      RETURNING VALUE(rv_text)   TYPE ty_mcndes.

    CLASS-METHODS now
      EXPORTING ev_date TYPE d
                ev_time TYPE t.

  PRIVATE SECTION.
    CLASS-METHODS base_url
      IMPORTING iv_mcno       TYPE clike
      RETURNING VALUE(rv_url) TYPE string.

    "! 2 digits that make the seqno unique across weighbridges
    CLASS-METHODS machine_code
      IMPORTING iv_mcno        TYPE clike
      RETURNING VALUE(rv_code) TYPE string.
ENDCLASS.

CLASS lcl_weighbridge IMPLEMENTATION.

  METHOD base_url.
    DATA lv_mcno TYPE ty_mcno.
    lv_mcno = iv_mcno.
    CONDENSE lv_mcno.
    CASE lv_mcno.
      WHEN 'WB-2'.   rv_url = 'http://15.207.178.30:6020'.
      WHEN 'WB-7'.   rv_url = 'http://15.207.178.30:6070'.
      WHEN 'WB-8.1'. rv_url = 'http://15.207.178.30:6081'.
      WHEN 'WB-8.2'. rv_url = 'http://15.207.178.30:6082'.
      WHEN 'WB-8.3'. rv_url = 'http://15.207.178.30:6083'.
      WHEN 'WB-10'.  rv_url = 'http://15.207.178.30:6100'.
    ENDCASE.
  ENDMETHOD.

  METHOD machine_code.
    DATA lv_mcno TYPE ty_mcno.
    lv_mcno = iv_mcno.
    CONDENSE lv_mcno.
    CASE lv_mcno.
      WHEN 'WB-2'.   rv_code = '02'.
      WHEN 'WB-7'.   rv_code = '07'.
      WHEN 'WB-8.1'. rv_code = '81'.
      WHEN 'WB-8.2'. rv_code = '82'.
      WHEN 'WB-8.3'. rv_code = '83'.
      WHEN 'WB-10'.  rv_code = '10'.
    ENDCASE.
  ENDMETHOD.

  METHOD machine_text.
    SELECT SINGLE text FROM zsd_weight_vh
      WHERE value_low = @iv_mcno
        AND language  = 'E'
      INTO @rv_text.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD DATA(lv_ts).
    CONVERT TIME STAMP lv_ts TIME ZONE 'INDIA' INTO DATE ev_date TIME ev_time.
  ENDMETHOD.

  METHOD read_weight.
    TYPES: BEGIN OF ty_response,
             raw_value TYPE string,
             wb_no     TYPE string,
           END OF ty_response.
    DATA ls_response TYPE ty_response.

    DATA(lv_url) = base_url( iv_mcno ).
    IF lv_url IS INITIAL.
      rs_reading-message = |No weighbridge address is set up for machine { iv_mcno }|.
      RETURN.
    ENDIF.

    TRY.
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination(
                            cl_http_destination_provider=>create_by_url( lv_url ) ).
        DATA(lo_request) = lo_client->get_http_request( ).
        lo_request->set_uri_path( i_uri_path = '/weight' ).
        lo_request->set_header_field( i_name = 'X-API-Key' i_value = c_api_key ).

        DATA(lo_response) = lo_client->execute( if_web_http_client=>get ).
        DATA(ls_status)   = lo_response->get_status( ).
        IF ls_status-code <> 200.
          rs_reading-message = |Weight API error: { ls_status-code } { ls_status-reason }|.
          RETURN.
        ENDIF.

        xco_cp_json=>data->from_string( lo_response->get_text( ) )->write_to( REF #( ls_response ) ).

        " raw_value comes as \"2121210\" -> 2121210
        DATA(lv_weight) = ls_response-raw_value.
        REPLACE ALL OCCURRENCES OF `"` IN lv_weight WITH ``.
        CONDENSE lv_weight NO-GAPS.
        IF lv_weight IS INITIAL.
          rs_reading-message = |Weighbridge { iv_mcno } returned no weight|.
          RETURN.
        ENDIF.
        rs_reading-weight = lv_weight.

        " machine: the one the weighbridge reports, if it is a known value
        CONDENSE ls_response-wb_no.
        IF ls_response-wb_no IS NOT INITIAL.
          rs_reading-mcno   = |WB-{ ls_response-wb_no }|.
          rs_reading-mcndes = machine_text( rs_reading-mcno ).
        ENDIF.
        IF rs_reading-mcndes IS INITIAL.
          rs_reading-mcno   = iv_mcno.
          rs_reading-mcndes = machine_text( rs_reading-mcno ).
        ENDIF.

        rs_reading-ok = abap_true.

      CATCH cx_http_dest_provider_error INTO DATA(lx_dest).
        rs_reading-message = |Destination error: { lx_dest->get_text( ) }|.
      CATCH cx_web_http_client_error INTO DATA(lx_http).
        rs_reading-message = |HTTP error: { lx_http->get_text( ) }|.
      CATCH cx_sy_conversion_error cx_xco_runtime_exception.
        rs_reading-message = |Weighbridge { iv_mcno } returned an invalid weight|.
    ENDTRY.
  ENDMETHOD.

  METHOD launch_camera.
    DATA: BEGIN OF ls_response,
            seqno  TYPE string,
            status TYPE string,
            wb_no  TYPE string,
          END OF ls_response.

    DATA(lv_url)  = base_url( iv_mcno ).
    DATA(lv_code) = machine_code( iv_mcno ).
    IF lv_url IS INITIAL OR lv_code IS INITIAL.
      rs_launch-message = |Camera: unknown weighbridge { iv_mcno }|.
      RETURN.
    ENDIF.

    " yymmddhhmmss + machine code, e.g. 26100818300002 (CamView rowid_seq)
    now( IMPORTING ev_date = DATA(lv_date) ev_time = DATA(lv_time) ).
    rs_launch-seqno = |{ lv_date+2(6) }{ lv_time }{ lv_code }|.

    TRY.
        DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination(
                            cl_http_destination_provider=>create_by_url( |{ lv_url }/launch| ) ).
        DATA(lo_request) = lo_client->get_http_request( ).
        lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
        lo_request->set_header_field( i_name = 'X-API-Key'    i_value = c_api_key ).
        lo_request->set_text( |\{"seqno":"{ rs_launch-seqno }"\}| ).

        DATA(lo_response) = lo_client->execute( if_web_http_client=>post ).

        DATA(ls_status) = lo_response->get_status( ).
        IF ls_status-code <> 200.
          rs_launch-message = |Camera launch error: { ls_status-code } { ls_status-reason }|.
          RETURN.
        ENDIF.

        /ui2/cl_json=>deserialize( EXPORTING json = lo_response->get_text( )
                                   CHANGING  data = ls_response ).
        IF to_lower( ls_response-status ) <> 'launched'.
          rs_launch-message = |Camera not launched: { ls_response-status }|.
          RETURN.
        ENDIF.

        rs_launch-ok = abap_true.

      CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_error).
        " the weight is already saved; the user gets a warning and can recapture
        rs_launch-message = |Camera launch error: { lx_error->get_text( ) }|.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------*
* Camera launch + image verification status (local helper)
* Launches the camera and, when it started, stores the seqno on the
* header for the stage (T tare / G gross) with status P (pending),
* so the entry shows up in the Image Verification app. A new gross
* capture also clears Imagevalid: the new images are not approved.
*----------------------------------------------------------------*
CLASS lcl_camera DEFINITION FINAL.
  PUBLIC SECTION.
    CONSTANTS: c_tare  TYPE c LENGTH 1 VALUE 'T',
               c_gross TYPE c LENGTH 1 VALUE 'G'.

    CLASS-METHODS launch
      IMPORTING iv_is_draft      TYPE abp_behv_flag
                iv_uuid          TYPE sysuuid_x16
                iv_mcno          TYPE clike
                iv_stage         TYPE c
      RETURNING VALUE(rs_launch) TYPE lcl_weighbridge=>ty_launch.

    "! success when the camera started, else warning (the weight is saved anyway)
    CLASS-METHODS severity
      IMPORTING is_launch          TYPE lcl_weighbridge=>ty_launch
      RETURNING VALUE(rv_severity) TYPE if_abap_behv_message=>t_severity.
ENDCLASS.

CLASS lcl_camera IMPLEMENTATION.

  METHOD launch.
    DATA(lv_stage) = COND string( WHEN iv_stage = c_tare THEN `Tare` ELSE `Gross` ).

    rs_launch = lcl_weighbridge=>launch_camera( iv_mcno ).
    IF rs_launch-ok = abap_false.
      rs_launch-message = |{ rs_launch-message }. Use Recapture { lv_stage }.|.
      RETURN.
    ENDIF.

    IF iv_stage = c_tare.
      MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightHead
          UPDATE FIELDS ( Imgseqnotare Imgvrstatustare Imgrejreason Imgstatustaretext Imgcrittare )
          WITH VALUE #( ( %is_draft         = iv_is_draft
                          Uuid              = iv_uuid
                          Imgseqnotare      = rs_launch-seqno
                          Imgvrstatustare   = 'P'
                          Imgrejreason      = ''
                          Imgstatustaretext = 'Pending'      " CDS texts are not recalculated in the draft
                          Imgcrittare       = 2 ) ).
    ELSE.
      MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightHead
          UPDATE FIELDS ( Imgseqnogross Imgvrstatusgross Imgrejreason Imagevalid Imgstatusgrosstext Imgcritgross )
          WITH VALUE #( ( %is_draft          = iv_is_draft
                          Uuid               = iv_uuid
                          Imgseqnogross      = rs_launch-seqno
                          Imgvrstatusgross   = 'P'
                          Imgrejreason       = ''
                          Imagevalid         = ''
                          Imgstatusgrosstext = 'Pending'
                          Imgcritgross       = 2 ) ).
    ENDIF.

    rs_launch-message = |{ lv_stage } images captured (seq { rs_launch-seqno }), sent for verification|.
  ENDMETHOD.

  METHOD severity.
    rv_severity = COND #( WHEN is_launch-ok = abap_true
                          THEN if_abap_behv_message=>severity-success
                          ELSE if_abap_behv_message=>severity-warning ).
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------*
* Standard S/4 delivery APIs (local helper)
* API_OUTBOUND_DELIVERY_SRV / API_CUSTOMER_RETURNS_DELIVERY_SRV, both
* in S/4 scenario SAP_COM_0106. Same calls as the S/4 DeliveryPG and
* UpDlyheadertext, but through the communication arrangement of
* ZMMGE_S4_PLANT_CS (empty path prefix) instead of a hardcoded user.
*----------------------------------------------------------------*
CLASS lcl_s4_delivery DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             ok      TYPE abap_bool,
             message TYPE string,
           END OF ty_result.

    TYPES: BEGIN OF ty_text,
             id   TYPE c LENGTH 4,
             text TYPE string,
           END OF ty_text,
           tt_text TYPE STANDARD TABLE OF ty_text WITH EMPTY KEY.

    "! PostGoodsIssue (SD1, outbound delivery) or PostGoodsReceipt (SD2, returns delivery)
    CLASS-METHODS post_goods_movement
      IMPORTING iv_gateentrytype TYPE clike
                iv_delivery      TYPE clike
      RETURNING VALUE(rs_result) TYPE ty_result.

    TYPES: BEGIN OF ty_item_sloc,
             item            TYPE n LENGTH 6,
             storagelocation TYPE c LENGTH 4,
           END OF ty_item_sloc,
           tt_item_sloc TYPE STANDARD TABLE OF ty_item_sloc WITH EMPTY KEY.

    "! PATCH StorageLocation on the delivery items (A_OutbDeliveryItem /
    "! A_ReturnsDeliveryItem). I_OutboundDeliveryItemTP can't change it,
    "! and PGI fails without it.
    CLASS-METHODS set_storage_locations
      IMPORTING iv_gateentrytype TYPE clike
                iv_delivery      TYPE clike
                it_items         TYPE tt_item_sloc
      RETURNING VALUE(rs_result) TYPE ty_result.

    "! one A_OutbDeliveryHeaderText per text
    CLASS-METHODS add_header_texts
      IMPORTING iv_delivery      TYPE clike
                it_texts         TYPE tt_text
      RETURNING VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    CONSTANTS c_outbound TYPE string VALUE '/sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002'.
    CONSTANTS c_returns  TYPE string VALUE '/sap/opu/odata/sap/API_CUSTOMER_RETURNS_DELIVERY_SRV;v=0002'.

    CLASS-METHODS new_client
      RETURNING VALUE(ro_client) TYPE REF TO if_web_http_client
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error.

    "! error.message.value of an OData error, else the HTTP status
    CLASS-METHODS error_text
      IMPORTING io_response    TYPE REF TO if_web_http_response
      RETURNING VALUE(rv_text) TYPE string.
ENDCLASS.

CLASS lcl_s4_delivery IMPLEMENTATION.

  METHOD new_client.
    ro_client = cl_web_http_client_manager=>create_by_http_destination(
                  cl_http_destination_provider=>create_by_comm_arrangement(
                    comm_scenario = 'ZMMGE_S4_PLANT_CS'
                    service_id    = 'ZMMGE_S4_PLANT_REST' ) ).
  ENDMETHOD.

  METHOD error_text.
    TYPES: BEGIN OF ty_msg,
             value TYPE string,
           END OF ty_msg,
           BEGIN OF ty_err,
             code    TYPE string,
             message TYPE ty_msg,
           END OF ty_err,
           BEGIN OF ty_body,
             error TYPE ty_err,
           END OF ty_body.
    DATA ls_body TYPE ty_body.

    DATA(ls_status) = io_response->get_status( ).
    TRY.
        /ui2/cl_json=>deserialize( EXPORTING json = io_response->get_text( )
                                   CHANGING  data = ls_body ).
      CATCH cx_web_message_error.
        CLEAR ls_body.
    ENDTRY.

    rv_text = COND #( WHEN ls_body-error-message-value IS NOT INITIAL
                      THEN ls_body-error-message-value
                      ELSE |HTTP { ls_status-code } { ls_status-reason }| ).
  ENDMETHOD.

  METHOD post_goods_movement.
    DATA lt_actions TYPE string_table.
    DATA lv_csrf    TYPE string.

    DATA(lv_delivery) = condense( CONV string( iv_delivery ) ).
    DATA(lv_returns)  = xsdbool( condense( CONV string( iv_gateentrytype ) ) = `SD2` ).

    DATA(lv_root)   = COND string( WHEN lv_returns = abap_true THEN c_returns ELSE c_outbound ).
    DATA(lv_entity) = COND string( WHEN lv_returns = abap_true
                                   THEN |A_ReturnsDeliveryHeader(DeliveryDocument='{ lv_delivery }')|
                                   ELSE |A_OutbDeliveryHeader(DeliveryDocument='{ lv_delivery }')| ).

    " SD1: pick all items first. The picking update in S/4 only sets the
    " delivery quantity; PGI then failed with "Delivery has not yet been
    " picked (completely)". PickAllItems picks that quantity.
    IF lv_returns = abap_true.
      lt_actions = VALUE #( ( |PostGoodsReceipt?DeliveryDocument='{ lv_delivery }'| ) ).
    ELSE.
      lt_actions = VALUE #( ( |PickAllItems?DeliveryDocument='{ lv_delivery }'| )
                            ( |PostGoodsIssue?DeliveryDocument='{ lv_delivery }'| ) ).
    ENDIF.

    TRY.
        DATA(lo_client)  = new_client( ).
        DATA(lo_request) = lo_client->get_http_request( ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).

        LOOP AT lt_actions INTO DATA(lv_action).

          " 1. GET the delivery: current ETag (and the CSRF token the first time)
          lo_request->set_uri_path( |{ lv_root }/{ lv_entity }| ).
          lo_request->delete_header_field( 'If-Match' ).
          lo_request->set_header_field( i_name  = 'X-CSRF-Token'
                                        i_value = COND #( WHEN lv_csrf IS INITIAL THEN `fetch` ELSE lv_csrf ) ).
          DATA(lo_get) = lo_client->execute( if_web_http_client=>get ).
          IF lo_get->get_status( )-code <> 200.
            rs_result-message = |Delivery { lv_delivery }: { error_text( lo_get ) }|.
            lo_client->close( ).
            RETURN.
          ENDIF.
          IF lv_csrf IS INITIAL.
            lv_csrf = lo_get->get_header_field( 'x-csrf-token' ).
          ENDIF.
          DATA(lv_etag) = lo_get->get_header_field( 'etag' ).
          IF lv_csrf IS INITIAL OR lv_etag IS INITIAL.
            rs_result-message = |CSRF token or ETag not received for delivery { lv_delivery }|.
            lo_client->close( ).
            RETURN.
          ENDIF.

          " 2. POST the action
          lo_request->set_uri_path( |{ lv_root }/{ lv_action }| ).
          lo_request->set_header_field( i_name = 'X-CSRF-Token' i_value = lv_csrf ).
          lo_request->set_header_field( i_name = 'If-Match'     i_value = lv_etag ).
          lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
          DATA(lo_post) = lo_client->execute( if_web_http_client=>post ).
          DATA(lv_code) = lo_post->get_status( )-code.
          IF lv_code < 200 OR lv_code >= 300.
            rs_result-message = |{ segment( val = lv_action index = 1 sep = `?` ) }: { error_text( lo_post ) }|.
            lo_client->close( ).
            RETURN.
          ENDIF.
        ENDLOOP.

        rs_result-ok = abap_true.
        lo_client->close( ).

      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error INTO DATA(lx_error).
        rs_result-message = |S/4 not reachable: { lx_error->get_text( ) }|.
    ENDTRY.
  ENDMETHOD.

  METHOD set_storage_locations.
    DATA lt_errors TYPE string_table.
    DATA lv_csrf   TYPE string.

    DATA(lv_delivery) = condense( CONV string( iv_delivery ) ).
    DATA(lv_returns)  = xsdbool( condense( CONV string( iv_gateentrytype ) ) = `SD2` ).
    DATA(lv_root)     = COND string( WHEN lv_returns = abap_true THEN c_returns ELSE c_outbound ).
    DATA(lv_set)      = COND string( WHEN lv_returns = abap_true THEN `A_ReturnsDeliveryItem` ELSE `A_OutbDeliveryItem` ).

    TRY.
        DATA(lo_client)  = new_client( ).
        DATA(lo_request) = lo_client->get_http_request( ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).

        LOOP AT it_items INTO DATA(ls_item) WHERE storagelocation IS NOT INITIAL.
          lo_request->set_uri_path( |{ lv_root }/{ lv_set }(DeliveryDocument='{ lv_delivery }',| &&
                                    |DeliveryDocumentItem='{ ls_item-item }')| ).

          " GET: ETag of the item (and the CSRF token the first time)
          lo_request->set_text( `` ).
          lo_request->delete_header_field( 'If-Match' ).   " ETag of the previous item
          lo_request->set_header_field( i_name = 'X-CSRF-Token'
                                        i_value = COND #( WHEN lv_csrf IS INITIAL THEN `fetch` ELSE lv_csrf ) ).
          DATA(lo_get) = lo_client->execute( if_web_http_client=>get ).
          IF lo_get->get_status( )-code <> 200.
            APPEND |Item { ls_item-item }: { error_text( lo_get ) }| TO lt_errors.
            CONTINUE.
          ENDIF.
          IF lv_csrf IS INITIAL.
            lv_csrf = lo_get->get_header_field( 'x-csrf-token' ).
          ENDIF.
          DATA(lv_etag) = lo_get->get_header_field( 'etag' ).

          " PATCH StorageLocation
          lo_request->set_header_field( i_name = 'X-CSRF-Token' i_value = lv_csrf ).
          lo_request->set_header_field( i_name = 'If-Match'     i_value = lv_etag ).
          lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
          lo_request->set_text( |\{"StorageLocation":"{ ls_item-storagelocation }"\}| ).
          DATA(lo_patch) = lo_client->execute( if_web_http_client=>patch ).
          IF lo_patch->get_status( )-code <> 204 AND lo_patch->get_status( )-code <> 200.
            APPEND |Item { ls_item-item }: { error_text( lo_patch ) }| TO lt_errors.
          ENDIF.
        ENDLOOP.
        lo_client->close( ).

      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error INTO DATA(lx_error).
        APPEND |S/4 not reachable: { lx_error->get_text( ) }| TO lt_errors.
    ENDTRY.

    rs_result-ok      = xsdbool( lt_errors IS INITIAL ).
    rs_result-message = concat_lines_of( table = lt_errors sep = `; ` ).
  ENDMETHOD.

  METHOD add_header_texts.
    DATA lt_errors TYPE string_table.
    DATA(lv_delivery) = condense( CONV string( iv_delivery ) ).

    TRY.
        DATA(lo_client)  = new_client( ).
        DATA(lo_request) = lo_client->get_http_request( ).

        " CSRF token from the service root
        lo_request->set_uri_path( |{ c_outbound }/| ).
        lo_request->set_header_field( i_name = 'Accept'       i_value = 'application/json' ).
        lo_request->set_header_field( i_name = 'X-CSRF-Token' i_value = 'fetch' ).
        DATA(lo_get) = lo_client->execute( if_web_http_client=>get ).
        DATA(lv_csrf) = lo_get->get_header_field( 'x-csrf-token' ).
        IF lv_csrf IS INITIAL.
          rs_result-message = |CSRF token not received ({ error_text( lo_get ) })|.
          lo_client->close( ).
          RETURN.
        ENDIF.

        lo_request->set_uri_path( |{ c_outbound }/A_OutbDeliveryHeaderText| ).
        lo_request->set_header_field( i_name = 'X-CSRF-Token' i_value = lv_csrf ).
        lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).

        LOOP AT it_texts INTO DATA(ls_text).
          lo_request->set_text( |\{"DeliveryDocument":"{ lv_delivery }","TextElement":"{ ls_text-id }",| &&
                                |"Language":"EN","TextElementText":"{ escape( val    = ls_text-text
                                                                               format = cl_abap_format=>e_json_string ) }"\}| ).
          DATA(lo_post) = lo_client->execute( if_web_http_client=>post ).
          IF lo_post->get_status( )-code <> 201.
            APPEND |{ ls_text-id }: { error_text( lo_post ) }| TO lt_errors.
          ENDIF.
        ENDLOOP.
        lo_client->close( ).

      CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error INTO DATA(lx_error).
        APPEND |S/4 not reachable: { lx_error->get_text( ) }| TO lt_errors.
    ENDTRY.

    rs_result-ok      = xsdbool( lt_errors IS INITIAL ).
    rs_result-message = concat_lines_of( table = lt_errors sep = `; ` ).
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------*
* Header
*----------------------------------------------------------------*
CLASS lhc_WeightHead DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR WeightHead RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR WeightHead RESULT result.

    METHODS AutoFetchWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~AutoFetchWt RESULT result.

    METHODS ManualFetchWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~ManualFetchWt RESULT result.

    METHODS RecaptureTare FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~RecaptureTare RESULT result.

    METHODS RecaptureGross FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~RecaptureGross RESULT result.

    METHODS CancelGateEntry FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~CancelGateEntry RESULT result.

    METHODS CrtDelivery FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~CrtDelivery RESULT result.

    METHODS PickingQty FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~PickingQty RESULT result.

    METHODS DeliveryPG FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~DeliveryPG RESULT result.

    METHODS UpDlyheadertext FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~UpDlyheadertext RESULT result.

    METHODS TransExit FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~TransExit RESULT result.

    METHODS Weighmentslip FOR MODIFY
      IMPORTING keys FOR ACTION WeightHead~Weighmentslip RESULT result.

ENDCLASS.

CLASS lhc_WeightHead IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead
        FIELDS ( Cancelgateentry Deliyindicator Imagevalid Pickqtyindicator Giindicator Gateentrytype
                 Tarewt Imgseqnotare Imgseqnogross Imgvrstatustare Imgvrstatusgross )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head)
      ENTITY WeightHead BY \_Item
        FIELDS ( Netweight )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item).

    LOOP AT lt_head INTO DATA(ls_head).

      DATA(lv_cancelled) = xsdbool( ls_head-Cancelgateentry IS NOT INITIAL ).

      " all items weighed?
      DATA(lv_items)     = 0.
      DATA(lv_unweighed) = 0.
      LOOP AT lt_item INTO DATA(ls_item) WHERE Uuid = ls_head-Uuid.
        lv_items += 1.
        IF ls_item-Netweight IS INITIAL.
          lv_unweighed += 1.
        ENDIF.
      ENDLOOP.
      DATA(lv_all_weighed) = xsdbool( lv_items > 0 AND lv_unweighed = 0 ).

      DATA(lv_open) = COND #( WHEN lv_cancelled = abap_true
                              THEN if_abap_behv=>fc-o-disabled
                              ELSE if_abap_behv=>fc-o-enabled ).

      " S/4 postings commit in S/4 at once. In edit mode (draft) a later
      " Discard would lose the S/4 document number, so these actions are
      " only offered on the saved entry.
      DATA(lv_post_blocked) = xsdbool( lv_cancelled = abap_true OR ls_head-%is_draft = if_abap_behv=>mk-on ).

      APPEND VALUE #(
        %tky    = ls_head-%tky
        %update = lv_open

        %action-Edit            = lv_open
        %action-AutoFetchWt     = lv_open
        %action-ManualFetchWt   = lv_open
        %action-CancelGateEntry = lv_open
        %action-TransExit       = COND #( WHEN lv_post_blocked = abap_true
                                          THEN if_abap_behv=>fc-o-disabled
                                          ELSE if_abap_behv=>fc-o-enabled )

        " recapture: the stage was rejected, or its camera launch failed
        %action-RecaptureTare = COND #( WHEN lv_cancelled = abap_true
                                        THEN if_abap_behv=>fc-o-disabled
                                        WHEN ls_head-Imgvrstatustare = 'R'
                                          OR ( ls_head-Tarewt IS NOT INITIAL AND ls_head-Imgseqnotare IS INITIAL )
                                        THEN if_abap_behv=>fc-o-enabled
                                        ELSE if_abap_behv=>fc-o-disabled )

        %action-RecaptureGross = COND #( WHEN lv_cancelled = abap_true
                                         THEN if_abap_behv=>fc-o-disabled
                                         WHEN ls_head-Imgvrstatusgross = 'R'
                                           OR ( lv_all_weighed = abap_true AND ls_head-Imgseqnogross IS INITIAL )
                                         THEN if_abap_behv=>fc-o-enabled
                                         ELSE if_abap_behv=>fc-o-disabled )

        %action-CrtDelivery = COND #( WHEN ls_head-Deliyindicator = 'X' OR lv_post_blocked = abap_true
                                      THEN if_abap_behv=>fc-o-disabled
                                      WHEN lv_all_weighed = abap_true AND ls_head-Imagevalid = 'X'
                                      THEN if_abap_behv=>fc-o-enabled
                                      ELSE if_abap_behv=>fc-o-disabled )

        %action-PickingQty = COND #( WHEN ls_head-Pickqtyindicator = 'X' OR ls_head-Gateentrytype = 'SD2'
                                          OR lv_post_blocked = abap_true
                                     THEN if_abap_behv=>fc-o-disabled
                                     WHEN ls_head-Deliyindicator = 'X'
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )

        %action-DeliveryPG = COND #( WHEN ls_head-Giindicator = 'X' OR lv_post_blocked = abap_true
                                     THEN if_abap_behv=>fc-o-disabled
                                     WHEN ls_head-Pickqtyindicator = 'X' OR ls_head-Gateentrytype = 'SD2'
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled )

        %action-Weighmentslip   = if_abap_behv=>fc-o-enabled
        %action-UpDlyheadertext = COND #( WHEN lv_post_blocked = abap_true
                                          THEN if_abap_behv=>fc-o-disabled
                                          ELSE if_abap_behv=>fc-o-enabled )
      ) TO result.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD AutoFetchWt.
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head)
      ENTITY WeightHead BY \_Item
        FIELDS ( Uuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item).

    LOOP AT lt_head INTO DATA(ls_head).
      DATA(ls_param) = keys[ KEY id %tky = ls_head-%tky ]-%param.

      DATA(ls_reading) = lcl_weighbridge=>read_weight( ls_param-Weighmentmcno ).
      IF ls_reading-ok = abap_false.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = ls_reading-message ) )
               TO reported-weighthead.
        CONTINUE.
      ENDIF.

      lcl_weighbridge=>now( IMPORTING ev_date = DATA(lv_date) ev_time = DATA(lv_time) ).
      DATA(lv_itemcount) = REDUCE i( INIT n = 0 FOR itm IN lt_item WHERE ( Uuid = ls_head-Uuid ) NEXT n = n + 1 ).

      MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightHead
          UPDATE FIELDS ( Tarewt Weighuom Weighmentmcno Weighmentmcndes Weighmentdate Weighmenttime Imagecount )
          WITH VALUE #( ( %tky            = ls_head-%tky
                          Tarewt          = ls_reading-weight
                          Weighuom        = 'TO'
                          Weighmentmcno   = ls_reading-mcno
                          Weighmentmcndes = ls_reading-mcndes
                          Weighmentdate   = lv_date
                          Weighmenttime   = lv_time
                          Imagecount      = lv_itemcount ) )
        ENTITY WeightItem
          UPDATE FIELDS ( Tareweight )
          WITH VALUE #( FOR itm IN lt_item WHERE ( Uuid = ls_head-Uuid )
                        ( %tky = itm-%tky  Tareweight = ls_reading-weight ) ).

      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Weighment { ls_reading-weight }-Ton Capture Success| ) )
             TO reported-weighthead.

      DATA(ls_launch) = lcl_camera=>launch( iv_is_draft = ls_head-%is_draft
                                            iv_uuid     = ls_head-Uuid
                                            iv_mcno     = ls_param-Weighmentmcno
                                            iv_stage    = lcl_camera=>c_tare ).
      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text( severity = lcl_camera=>severity( ls_launch )
                                                    text     = ls_launch-message ) )
             TO reported-weighthead.
    ENDLOOP.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD ManualFetchWt.
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead
        FIELDS ( Uuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head)
      ENTITY WeightHead BY \_Item
        FIELDS ( Uuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item).

    LOOP AT lt_head INTO DATA(ls_head).
      DATA(ls_param) = keys[ KEY id %tky = ls_head-%tky ]-%param.

      IF ls_param-Weight IS INITIAL OR ls_param-Unit IS INITIAL.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
        APPEND VALUE #( %tky        = ls_head-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = 'Weighment is empty' ) )
               TO reported-weighthead.
        CONTINUE.
      ENDIF.

      lcl_weighbridge=>now( IMPORTING ev_date = DATA(lv_date) ev_time = DATA(lv_time) ).
      DATA(lv_itemcount) = REDUCE i( INIT n = 0 FOR itm IN lt_item WHERE ( Uuid = ls_head-Uuid ) NEXT n = n + 1 ).

      MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightHead
          UPDATE FIELDS ( Tarewt Weighuom Weighmentmcno Weighmentmcndes Weighmentdate Weighmenttime Imagecount )
          WITH VALUE #( ( %tky            = ls_head-%tky
                          Tarewt          = ls_param-Weight
                          Weighuom        = ls_param-Unit
                          Weighmentmcno   = ls_param-Weighmentmcno
                          Weighmentmcndes = lcl_weighbridge=>machine_text( ls_param-Weighmentmcno )
                          Weighmentdate   = lv_date
                          Weighmenttime   = lv_time
                          Imagecount      = lv_itemcount ) )
        ENTITY WeightItem
          UPDATE FIELDS ( Tareweight )
          WITH VALUE #( FOR itm IN lt_item WHERE ( Uuid = ls_head-Uuid )
                        ( %tky = itm-%tky  Tareweight = ls_param-Weight ) ).

      DATA(ls_launch) = lcl_camera=>launch( iv_is_draft = ls_head-%is_draft
                                            iv_uuid     = ls_head-Uuid
                                            iv_mcno     = ls_param-Weighmentmcno
                                            iv_stage    = lcl_camera=>c_tare ).
      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text( severity = lcl_camera=>severity( ls_launch )
                                                    text     = ls_launch-message ) )
             TO reported-weighthead.
    ENDLOOP.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD RecaptureTare.
    " camera only, the tare weight stays (truck back on the weighbridge, empty)
    LOOP AT keys INTO DATA(key).
      DATA(ls_launch) = lcl_camera=>launch( iv_is_draft = key-%is_draft
                                            iv_uuid     = key-Uuid
                                            iv_mcno     = key-%param-Weighmentmcno
                                            iv_stage    = lcl_camera=>c_tare ).
      IF ls_launch-ok = abap_false.
        APPEND VALUE #( %tky = key-%tky ) TO failed-weighthead.
      ENDIF.
      APPEND VALUE #( %tky = key-%tky
                      %msg = new_message_with_text( severity = COND #( WHEN ls_launch-ok = abap_true
                                                                       THEN if_abap_behv_message=>severity-success
                                                                       ELSE if_abap_behv_message=>severity-error )
                                                    text     = ls_launch-message ) )
             TO reported-weighthead.
    ENDLOOP.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD RecaptureGross.
    " camera only, the gross / net weights stay (truck back on the weighbridge, loaded)
    LOOP AT keys INTO DATA(key).
      DATA(ls_launch) = lcl_camera=>launch( iv_is_draft = key-%is_draft
                                            iv_uuid     = key-Uuid
                                            iv_mcno     = key-%param-Weighmentmcno
                                            iv_stage    = lcl_camera=>c_gross ).
      IF ls_launch-ok = abap_false.
        APPEND VALUE #( %tky = key-%tky ) TO failed-weighthead.
      ENDIF.
      APPEND VALUE #( %tky = key-%tky
                      %msg = new_message_with_text( severity = COND #( WHEN ls_launch-ok = abap_true
                                                                       THEN if_abap_behv_message=>severity-success
                                                                       ELSE if_abap_behv_message=>severity-error )
                                                    text     = ls_launch-message ) )
             TO reported-weighthead.
    ENDLOOP.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD CancelGateEntry.
    MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead
        UPDATE FIELDS ( Cancelgateentry )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky  Cancelgateentry = 'X' ) ).

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  "------------------------------------------------------------------
  " Stubs: these need S/4 (delivery, picking, PGI, texts, billing) or
  " the Adobe template store. Implemented in later steps.
  "------------------------------------------------------------------
  METHOD CrtDelivery.
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head)
      ENTITY WeightHead BY \_Item
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item).

    LOOP AT lt_head INTO DATA(ls_head).

      DATA(ls_request) = VALUE zcl_sd_s4_owght_api=>ty_request(
        operation     = 'CRTDLV'
        gateentrytype = condense( CONV string( ls_head-Gateentrytype ) )
        items         = VALUE #( FOR itm IN lt_item WHERE ( Uuid = ls_head-Uuid )
                                 ( salesdocument              = itm-Salesdocument
                                   salesitem                  = itm-Salesitem
                                   material                   = itm-Material
                                   plant                      = itm-Plant
                                   storagelocation            = itm-Storagelocation
                                   netweight                  = itm-Netweight
                                   unit                       = itm-Baseunit
                                   independentrequirementtype = itm-Independentrequirementtype
                                   shippingpoint              = itm-Shippingpoint ) ) ).
      SORT ls_request-items BY salesdocument salesitem.

      TRY.
          DATA(ls_response) = zcl_sd_s4_owght_api=>call( ls_request ).
        CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_conn).
          ls_response = VALUE #( message = |S/4 not reachable: { lx_conn->get_text( ) }| ).
      ENDTRY.

      IF ls_response-success = abap_false.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = ls_response-message ) )
               TO reported-weighthead.
        CONTINUE.
      ENDIF.

      " delivery number on header and items (the S/4 saver did this)
      MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightHead
          UPDATE FIELDS ( Deliveryno Deliyindicator Picqtindicator )
          WITH VALUE #( ( %tky           = ls_head-%tky
                          Deliveryno     = ls_response-deliveryno
                          Deliyindicator = 'X'
                          Picqtindicator = abap_true ) )
        ENTITY WeightItem
          UPDATE FIELDS ( Deliveryno Deliveritem )
          WITH VALUE #( FOR itm IN lt_item WHERE ( Uuid = ls_head-Uuid )
                        LET ls_dlv = VALUE zcl_sd_s4_owght_api=>ty_resp_item(
                                       ls_response-items[ salesdocument = itm-Salesdocument
                                                          salesitem     = itm-Salesitem ] OPTIONAL )
                        IN ( %tky        = itm-%tky
                             Deliveryno  = ls_response-deliveryno
                             Deliveritem = ls_dlv-deliveritem ) ).

      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text( severity = COND #( WHEN ls_response-message IS INITIAL
                                                                           THEN if_abap_behv_message=>severity-success
                                                                           ELSE if_abap_behv_message=>severity-warning )
                                                    text     = COND #( WHEN ls_response-message IS INITIAL
                                                                       THEN |Delivery { ls_response-deliveryno } created with the net weight|
                                                                       ELSE |Delivery { ls_response-deliveryno } created. { ls_response-message }| ) ) )
             TO reported-weighthead.
    ENDLOOP.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD PickingQty.
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head)
      ENTITY WeightHead BY \_Item
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item).

    LOOP AT lt_head INTO DATA(ls_head).

      DATA(ls_request) = VALUE zcl_sd_s4_owght_api=>ty_request(
        operation  = 'PICK'
        deliveryno = ls_head-Deliveryno
        items      = VALUE #( FOR itm IN lt_item WHERE ( Uuid = ls_head-Uuid )
                              ( salesdocument = itm-Salesdocument
                                salesitem     = itm-Salesitem
                                deliveryno    = itm-Deliveryno
                                deliveritem   = itm-Deliveritem
                                netweight     = itm-Netweight
                                unit          = itm-Baseunit ) ) ).

      " every item needs its delivery item (filled by Create Delivery)
      IF ls_request-items IS INITIAL OR line_exists( ls_request-items[ deliveritem = '000000' ] ).
        DATA(ls_response) = VALUE zcl_sd_s4_owght_api=>ty_response(
                              message = 'The items have no delivery item yet. Create the delivery first.' ).
      ELSE.
        TRY.
            ls_response = zcl_sd_s4_owght_api=>call( ls_request ).
          CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_conn).
            ls_response = VALUE #( message = |S/4 not reachable: { lx_conn->get_text( ) }| ).
        ENDTRY.
      ENDIF.

      IF ls_response-success = abap_false.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = ls_response-message ) )
               TO reported-weighthead.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightHead
          UPDATE FIELDS ( Pickqtyindicator )
          WITH VALUE #( ( %tky = ls_head-%tky  Pickqtyindicator = 'X' ) ).

      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Picking quantity updated in delivery { ls_head-Deliveryno }| ) )
             TO reported-weighthead.
    ENDLOOP.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD DeliveryPG.
    DATA ls_response TYPE zcl_sd_s4_owght_api=>ty_response.
    DATA ls_matdoc   TYPE zcl_sd_s4_owght_api=>ty_response.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head)
      ENTITY WeightHead BY \_Item
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item).

    LOOP AT lt_head INTO DATA(ls_head).
      CLEAR: ls_response, ls_matdoc.

      " 1. broker / LC limits in S/4 (SD1 only; S/4 answers OK for SD2)
      IF ls_head-Deliveryno IS INITIAL.
        ls_response-message = 'Create the delivery first'.
      ELSE.
        TRY.
            ls_response = zcl_sd_s4_owght_api=>call( VALUE #(
                            operation     = 'PGICHECK'
                            gateentrytype = condense( CONV string( ls_head-Gateentrytype ) )
                            items         = VALUE #( FOR itm IN lt_item WHERE ( Uuid = ls_head-Uuid )
                                                     ( salesdocument = itm-Salesdocument
                                                       salesitem     = itm-Salesitem
                                                       netweight     = itm-Netweight ) ) ) ).
          CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_conn).
            ls_response-message = |S/4 not reachable: { lx_conn->get_text( ) }|.
        ENDTRY.
      ENDIF.

      IF ls_response-success = abap_false.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = ls_response-message ) )
               TO reported-weighthead.
        CONTINUE.
      ENDIF.

      " 2a. storage location on the delivery items (standard API PATCH)
      DATA(ls_sloc) = lcl_s4_delivery=>set_storage_locations(
                        iv_gateentrytype = ls_head-Gateentrytype
                        iv_delivery      = ls_head-Deliveryno
                        it_items         = VALUE #( FOR itm IN lt_item WHERE ( Uuid = ls_head-Uuid )
                                                    ( item            = itm-Deliveritem
                                                      storagelocation = itm-Storagelocation ) ) ).
      IF ls_sloc-ok = abap_false.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = |Storage location: { ls_sloc-message }| ) )
               TO reported-weighthead.
        CONTINUE.
      ENDIF.

      " 2b. PostGoodsIssue (SD1) / PostGoodsReceipt (SD2) - standard API
      DATA(ls_post) = lcl_s4_delivery=>post_goods_movement( iv_gateentrytype = ls_head-Gateentrytype
                                                            iv_delivery      = ls_head-Deliveryno ).
      IF ls_post-ok = abap_false.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = ls_post-message ) )
               TO reported-weighthead.
        CONTINUE.
      ENDIF.

      " 3. material document of the goods movement
      TRY.
          ls_matdoc = zcl_sd_s4_owght_api=>call( VALUE #( operation  = 'MATDOC'
                                                          deliveryno = ls_head-Deliveryno ) ).
        CATCH cx_http_dest_provider_error cx_web_http_client_error.
          CLEAR ls_matdoc.
      ENDTRY.

      " the goods movement is posted: set the indicator even if the
      " material document can't be read yet, so PGI is not repeated
      MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightHead
          UPDATE FIELDS ( Materialdocument Materialdocumentyear Giindicator )
          WITH VALUE #( ( %tky                 = ls_head-%tky
                          Materialdocument     = ls_matdoc-materialdocument
                          Materialdocumentyear = ls_matdoc-materialdocumentyear
                          Giindicator          = 'X' ) ).

      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Goods movement posted for delivery { ls_head-Deliveryno }| &&
                                                               | (material document { ls_matdoc-materialdocument })| ) )
             TO reported-weighthead.
    ENDLOOP.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD UpDlyheadertext.
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead
        FIELDS ( Deliveryno Vehicleno Transportid ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).

    LOOP AT lt_head INTO DATA(ls_head).

      IF ls_head-Deliveryno IS INITIAL.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'Create the delivery first' ) )
               TO reported-weighthead.
        CONTINUE.
      ENDIF.

      lcl_weighbridge=>now( IMPORTING ev_date = DATA(lv_date) ).

      " the same four texts as in S/4 (S/4 built the 4th but never sent it)
      DATA(ls_texts) = lcl_s4_delivery=>add_header_texts(
        iv_delivery = ls_head-Deliveryno
        it_texts    = VALUE #( ( id = 'JGVN' text = ls_head-Vehicleno )                       " vehicle no
                               ( id = 'JGEB' text = 'R' )                                     " vehicle type
                               ( id = 'JGTD' text = |{ lv_date DATE = ENVIRONMENT }| )        " transport date
                               ( id = 'Z018' text = |{ ls_head-Transportid ALPHA = OUT }| ) ) ). " transport ID

      IF ls_texts-ok = abap_false.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = ls_texts-message ) )
               TO reported-weighthead.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Header texts created for delivery { ls_head-Deliveryno }| ) )
             TO reported-weighthead.
    ENDLOOP.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD TransExit.
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead
        FIELDS ( Deliveryno ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).

    LOOP AT lt_head INTO DATA(ls_head).

      IF ls_head-Deliveryno IS INITIAL.
        DATA(ls_response) = VALUE zcl_sd_s4_owght_api=>ty_response(
                              message = 'The billing & E-Way Bill have not been generated.' ).
      ELSE.
        TRY.
            ls_response = zcl_sd_s4_owght_api=>call( VALUE #( operation  = 'BILLING'
                                                              deliveryno = ls_head-Deliveryno ) ).
          CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_conn).
            ls_response = VALUE #( message = |S/4 not reachable: { lx_conn->get_text( ) }| ).
        ENDTRY.
      ENDIF.

      IF ls_response-success = abap_false.
        APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
        APPEND VALUE #( %tky = ls_head-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = ls_response-message ) )
               TO reported-weighthead.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightHead
          UPDATE FIELDS ( Transferexit Billingdocument Billingdocumentdate Einvoiceno
                          Einvoicedate Ewaybillno Ewaybilldate )
          WITH VALUE #( ( %tky                = ls_head-%tky
                          Transferexit        = 'X'
                          Billingdocument     = ls_response-billingdocument
                          Billingdocumentdate = ls_response-billingdocumentdate
                          Einvoiceno          = ls_response-einvoiceno
                          Einvoicedate        = ls_response-einvoicedate
                          Ewaybillno          = ls_response-ewaybillno
                          Ewaybilldate        = ls_response-ewaybilldate ) ).

      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Transferred to exit (billing { ls_response-billingdocument })| ) )
             TO reported-weighthead.
    ENDLOOP.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD Weighmentslip.
    " Weighment slip (2026-10-08): data XML from the slip service
    " ZSD_WEIGHT_SLIP (custom entity ZSD_CE_WEIGHT, class
    " ZWEIGH_FORM_IMP), rendered with the Adobe REST API through
    " ZCL_GE_ADOBE_PDF (form ZSD_WEIGHT_SLIP / template WEIGHMENT_SLIP),
    " stored in Attachmentwt like in S/4. The slip reads the SAVED data,
    " as in S/4. Print queue: later step.
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead
        FIELDS ( Uuid Gateentryno ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).

    LOOP AT lt_head INTO DATA(ls_head).

      IF ls_head-Gateentryno IS INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          DATA(lo_fdp)  = cl_fp_fdp_services=>get_instance( iv_service_definition = 'ZSD_WEIGHT_SLIP'
                                                             iv_root_node          = 'ZSD_CE_WEIGHT' ).
          DATA(lt_keys) = lo_fdp->get_keys( ).
          lt_keys[ name = 'UUID' ]-value = ls_head-Uuid.
          DATA(lv_xml)  = lo_fdp->read_to_xml( lt_keys ).

          DATA(lv_pdf)  = zcl_ge_adobe_pdf=>render( iv_form_name     = `ZSD_WEIGHT_SLIP`
                                                    iv_template_name = `WEIGHMENT_SLIP`
                                                    iv_xml_data      = lv_xml ).

        CATCH cx_fp_fdp_error INTO DATA(lx_fdp).
          APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
          APPEND VALUE #( %tky = ls_head-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = |Slip data: { lx_fdp->get_text( ) }| ) )
                 TO reported-weighthead.
          CONTINUE.
        CATCH zcx_fp_tmpl_store_error INTO DATA(lx_ads).
          APPEND VALUE #( %tky = ls_head-%tky ) TO failed-weighthead.
          APPEND VALUE #( %tky = ls_head-%tky
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text     = |Adobe: HTTP { lx_ads->mv_http_status_code } { lx_ads->mv_http_reason }| ) )
                 TO reported-weighthead.
          CONTINUE.
      ENDTRY.

      MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightHead
          UPDATE FIELDS ( Attachmentwt Mimetypewt Filenamewt )
          WITH VALUE #( ( %tky         = ls_head-%tky
                          Attachmentwt = lv_pdf
                          Mimetypewt   = 'application/pdf'
                          Filenamewt   = |Weighment Slip-{ ls_head-Gateentryno }.pdf| ) ).

      APPEND VALUE #( %tky = ls_head-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                    text     = |Weighment slip created for { ls_head-Gateentryno }| ) )
             TO reported-weighthead.
    ENDLOOP.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightHead ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------*
* Item
*----------------------------------------------------------------*
CLASS lhc_WeightItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES ty_items TYPE TABLE FOR READ RESULT zsd_ih_weight\\WeightItem.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR WeightItem RESULT result.

    " no item get_instance_authorizations: the item actions are checked with
    " the header's update authorization ( authorization : update in the BDEF)

    METHODS AutoFetchTWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~AutoFetchTWt RESULT result.

    METHODS ManualFetchTWt FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~ManualFetchTWt RESULT result.

    METHODS ImgCapture FOR MODIFY
      IMPORTING keys FOR ACTION WeightItem~ImgCapture RESULT result.

    "! Share of the net weight for one item: OpenQty / OpenQty of all
    "! selected items of the same material (S/4 logic). Falls back to
    "! the order quantity when OpenQty is 0.
    METHODS split_share
      IMPORTING it_items        TYPE ty_items
                is_item         TYPE LINE OF ty_items
      RETURNING VALUE(rv_share) TYPE decfloat34.

ENDCLASS.

CLASS lhc_WeightItem IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightItem BY \_Head
        FIELDS ( Loadendindi ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).

    LOOP AT keys INTO DATA(key).
      READ TABLE lt_head INTO DATA(ls_head) WITH KEY Uuid = key-Uuid.
      IF sy-subrc <> 0.
        CLEAR ls_head.
      ENDIF.

      DATA(lv_fc) = COND #( WHEN ls_head-Loadendindi = 'X'
                            THEN if_abap_behv=>fc-o-enabled
                            ELSE if_abap_behv=>fc-o-disabled ).

      APPEND VALUE #( %tky                  = key-%tky
                      %action-ImgCapture     = lv_fc
                      %action-AutoFetchTWt   = lv_fc
                      %action-ManualFetchTWt = lv_fc ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD split_share.
    DATA(lv_open_total) = REDUCE decfloat34( INIT s = CONV decfloat34( 0 )
                                             FOR itm IN it_items WHERE ( Material = is_item-Material )
                                             NEXT s = s + itm-OpenQty ).
    IF lv_open_total > 0.
      rv_share = is_item-OpenQty / lv_open_total.
      RETURN.
    ENDIF.

    DATA(lv_qty_total) = REDUCE decfloat34( INIT s = CONV decfloat34( 0 )
                                            FOR itm IN it_items WHERE ( Material = is_item-Material )
                                            NEXT s = s + itm-Quantity ).
    rv_share = COND #( WHEN lv_qty_total > 0 THEN is_item-Quantity / lv_qty_total ELSE 1 ).
  ENDMETHOD.

  METHOD AutoFetchTWt.
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightItem
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item)
      ENTITY WeightItem BY \_Head
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).

    DATA(ls_head)  = VALUE #( lt_head[ 1 ] OPTIONAL ).
    DATA(ls_param) = VALUE #( keys[ 1 ]-%param OPTIONAL ).

    IF ls_head-Tarewt IS INITIAL.
      LOOP AT lt_item INTO DATA(ls_err).
        APPEND VALUE #( %tky = ls_err-%tky ) TO failed-weightitem.
        APPEND VALUE #( %tky        = ls_err-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = '1st Weighment (tare) is empty' ) )
               TO reported-weightitem.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA(ls_reading) = lcl_weighbridge=>read_weight( ls_param-Weighmentmcno ).
    IF ls_reading-ok = abap_false.
      LOOP AT lt_item INTO ls_err.
        APPEND VALUE #( %tky = ls_err-%tky ) TO failed-weightitem.
        APPEND VALUE #( %tky = ls_err-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = ls_reading-message ) )
               TO reported-weightitem.
      ENDLOOP.
      RETURN.
    ENDIF.

    " net split (S/4 logic; no net > 0 check for the auto weight, as in S/4)
    SORT lt_item BY Salesdocument Salesitem.
    DATA lt_update TYPE TABLE FOR UPDATE zsd_ih_weight\\WeightItem.
    LOOP AT lt_item INTO DATA(ls_item).
      DATA(lv_net) = COND decfloat34( WHEN ls_head-Gateentrytype = 'SD2'
                                      THEN ls_item-Tareweight - ls_reading-weight
                                      ELSE ls_reading-weight - ls_item-Tareweight ).
      APPEND VALUE #( %tky            = ls_item-%tky
                      Netweight       = split_share( it_items = lt_item is_item = ls_item ) * lv_net
                      Grossweight     = ls_reading-weight
                      Weighmentmcno   = ls_reading-mcno
                      Weighmentmcndes = ls_reading-mcndes ) TO lt_update.
    ENDLOOP.

    MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightItem
        UPDATE FIELDS ( Netweight Grossweight Weighmentmcno Weighmentmcndes )
        WITH lt_update.

    DATA(ls_first) = lt_item[ 1 ].
    APPEND VALUE #( %tky = ls_first-%tky
                    %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                  text     = |Weighment { ls_reading-weight }-Ton Capture Success| ) )
           TO reported-weightitem.

    " camera only when the image count of the items matches the header
    DATA(lv_imagecount) = REDUCE i( INIT n = 0 FOR itm IN lt_item NEXT n = n + itm-Itemimagecount ).
    IF ls_head-Imagecount = lv_imagecount.
      DATA(ls_launch) = lcl_camera=>launch( iv_is_draft = ls_head-%is_draft
                                            iv_uuid     = ls_head-Uuid
                                            iv_mcno     = ls_param-Weighmentmcno
                                            iv_stage    = lcl_camera=>c_gross ).
      APPEND VALUE #( %tky = ls_first-%tky
                      %msg = new_message_with_text( severity = lcl_camera=>severity( ls_launch )
                                                    text     = ls_launch-message ) )
             TO reported-weightitem.
    ENDIF.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightItem ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD ManualFetchTWt.
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightItem
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item)
      ENTITY WeightItem BY \_Head
        FIELDS ( Gateentrytype Imagecount ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_head).

    DATA(ls_head)  = VALUE #( lt_head[ 1 ] OPTIONAL ).
    DATA(ls_param) = VALUE #( keys[ 1 ]-%param OPTIONAL ).

    IF ls_param-Weight IS INITIAL OR ls_param-Unit IS INITIAL.
      LOOP AT lt_item INTO DATA(ls_err).
        APPEND VALUE #( %tky = ls_err-%tky ) TO failed-weightitem.
        APPEND VALUE #( %tky        = ls_err-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = 'Weighment is empty' ) )
               TO reported-weightitem.
      ENDLOOP.
      RETURN.
    ENDIF.

    SORT lt_item BY Salesdocument Salesitem.
    DATA lt_update TYPE TABLE FOR UPDATE zsd_ih_weight\\WeightItem.
    LOOP AT lt_item INTO DATA(ls_item).
      DATA(lv_net) = COND decfloat34( WHEN ls_head-Gateentrytype = 'SD2'
                                      THEN ls_item-Tareweight - ls_param-Weight
                                      ELSE ls_param-Weight - ls_item-Tareweight ).
      IF lv_net <= 0.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-weightitem.
        APPEND VALUE #( %tky        = ls_item-%tky
                        %state_area = 'Validate_Head'
                        %msg        = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text     = |Net Weight { lv_net } is Wrong| ) )
               TO reported-weightitem.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky        = ls_item-%tky
                      Netweight   = split_share( it_items = lt_item is_item = ls_item ) * lv_net
                      Grossweight = ls_param-Weight ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zsd_ih_weight IN LOCAL MODE
        ENTITY WeightItem
          UPDATE FIELDS ( Netweight Grossweight )
          WITH lt_update.
    ENDIF.

    " camera as in AutoFetchTWt: every item weighed and the image count matches
    DATA(lv_imagecount) = REDUCE i( INIT n = 0 FOR itm IN lt_item NEXT n = n + itm-Itemimagecount ).
    IF lt_item IS NOT INITIAL AND lines( lt_update ) = lines( lt_item ) AND ls_head-Imagecount = lv_imagecount.
      DATA(ls_launch) = lcl_camera=>launch( iv_is_draft = ls_head-%is_draft
                                            iv_uuid     = ls_head-Uuid
                                            iv_mcno     = ls_param-Weighmentmcno
                                            iv_stage    = lcl_camera=>c_gross ).
      APPEND VALUE #( %tky = lt_item[ 1 ]-%tky
                      %msg = new_message_with_text( severity = lcl_camera=>severity( ls_launch )
                                                    text     = ls_launch-message ) )
             TO reported-weightitem.
    ENDIF.

    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightItem ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD ImgCapture.
    " empty in S/4 as well (the button is commented out in the UI)
    READ ENTITIES OF zsd_ih_weight IN LOCAL MODE
      ENTITY WeightItem ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

ENDCLASS.

