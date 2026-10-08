*----------------------------------------------------------------*
* SYSTEM: BTP ABAP Environment   Package: ZSDGE_APP4_OWGHT
* ADT object: ABAP Class
* Object name: ZCL_SD_S4_OWGHT_API
*
* Calls the S/4 HTTP service ZSD_OWGHT_POST (handler
* ZCL_SD_OWGHT_POST_HTTP) with a JSON body. Used by the behavior pool
* ZBP_SD_IH_WEIGHT for CrtDelivery (CRTDLV), PickingQty (PICK),
* DeliveryPG (PGICHECK, MATDOC) and TransExit (BILLING).
*
* Connection: communication arrangement for scenario
* ZSD_S4_OWGHTPOST_CS / outbound service ZSD_S4_OWGHTPOST_REST
* (path prefix /sap/bc/http/sap/zsd_owght_post) on S4HC_BTP with
* outbound user BTP_APPS_USER.
*
* The types below are the JSON contract. They must stay identical to
* ZCL_SD_OWGHT_POST_HTTP in S/4.
*----------------------------------------------------------------*
CLASS zcl_sd_s4_owght_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty TYPE p LENGTH 8 DECIMALS 3.

    TYPES: BEGIN OF ty_req_item,
             salesdocument              TYPE c LENGTH 10,
             salesitem                  TYPE n LENGTH 6,
             material                   TYPE c LENGTH 40,
             plant                      TYPE c LENGTH 4,
             storagelocation            TYPE c LENGTH 4,
             netweight                  TYPE ty_qty,
             unit                       TYPE c LENGTH 3,
             independentrequirementtype TYPE c LENGTH 4,
             shippingpoint              TYPE c LENGTH 4,
             deliveryno                 TYPE c LENGTH 10,
             deliveritem                TYPE n LENGTH 6,
           END OF ty_req_item,
           tt_req_item TYPE STANDARD TABLE OF ty_req_item WITH EMPTY KEY.

    TYPES: BEGIN OF ty_request,
             operation     TYPE c LENGTH 10,
             gateentrytype TYPE c LENGTH 4,
             deliveryno    TYPE c LENGTH 10,
             items         TYPE tt_req_item,
           END OF ty_request.

    TYPES: BEGIN OF ty_resp_item,
             salesdocument TYPE c LENGTH 10,
             salesitem     TYPE n LENGTH 6,
             deliveryno    TYPE c LENGTH 10,
             deliveritem   TYPE n LENGTH 6,
           END OF ty_resp_item,
           tt_resp_item TYPE STANDARD TABLE OF ty_resp_item WITH EMPTY KEY.

    TYPES: BEGIN OF ty_response,
             success              TYPE abap_bool,
             message              TYPE string,
             deliveryno           TYPE c LENGTH 10,
             items                TYPE tt_resp_item,
             billingdocument      TYPE c LENGTH 10,
             billingdocumentdate  TYPE d,
             einvoiceno           TYPE string,
             einvoicedate         TYPE d,
             ewaybillno           TYPE string,
             ewaybilldate         TYPE d,
             materialdocument     TYPE c LENGTH 10,
             materialdocumentyear TYPE n LENGTH 4,
           END OF ty_response.

    "! Sends one request to S/4. Business errors come back in rs_response-message
    "! with success = false; only connection problems raise an exception.
    CLASS-METHODS call
      IMPORTING is_request         TYPE ty_request
      RETURNING VALUE(rs_response) TYPE ty_response
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error.
ENDCLASS.


CLASS zcl_sd_s4_owght_api IMPLEMENTATION.

  METHOD call.
    DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                             comm_scenario = 'ZSD_S4_OWGHTPOST_CS'
                             service_id    = 'ZSD_S4_OWGHTPOST_REST' ).
    DATA(lo_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

    DATA(lo_request) = lo_client->get_http_request( ).
    lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
    lo_request->set_text( /ui2/cl_json=>serialize( data        = is_request
                                                   pretty_name = /ui2/cl_json=>pretty_mode-low_case ) ).

    DATA(lo_response) = lo_client->execute( if_web_http_client=>post ).
    DATA(ls_status) = lo_response->get_status( ).

    IF ls_status-code = 200.
      /ui2/cl_json=>deserialize( EXPORTING json        = lo_response->get_text( )
                                           pretty_name = /ui2/cl_json=>pretty_mode-low_case
                                 CHANGING  data        = rs_response ).
    ELSE.
      rs_response-message = |S/4 returned HTTP { ls_status-code } { ls_status-reason }|.
    ENDIF.

    lo_client->close( ).
  ENDMETHOD.

ENDCLASS.

