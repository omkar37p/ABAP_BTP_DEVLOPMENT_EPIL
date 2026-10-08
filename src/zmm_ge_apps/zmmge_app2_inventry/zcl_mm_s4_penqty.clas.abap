CLASS zcl_mm_s4_penqty DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty TYPE p LENGTH 7 DECIMALS 3.   " = abap.dec(13,3)

    TYPES: BEGIN OF ty_key,
             purchaseorder     TYPE zmmge_itm_t01-purchaseorder,
             purchaseorderitem TYPE zmmge_itm_t01-purchaseorderitem,
           END OF ty_key,
           tt_key TYPE SORTED TABLE OF ty_key WITH UNIQUE KEY purchaseorder purchaseorderitem.

    TYPES: BEGIN OF ty_penqty,
             purchaseorder     TYPE zmmge_itm_t01-purchaseorder,
             purchaseorderitem TYPE zmmge_itm_t01-purchaseorderitem,
             poqty             TYPE ty_qty,
             delqty            TYPE ty_qty,
             pendqty           TYPE ty_qty,
           END OF ty_penqty,
           tt_penqty TYPE SORTED TABLE OF ty_penqty WITH UNIQUE KEY purchaseorder purchaseorderitem.

    "! Returns pending qty for the given PO items (items unknown in S/4 are left out)
    CLASS-METHODS get
      IMPORTING it_keys          TYPE tt_key
      RETURNING VALUE(rt_penqty) TYPE tt_penqty
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error
                /iwbep/cx_gateway.

    "! Client proxy for the S/4 Web API ZMM_API_PO_PENQTY_O2
    "! (also used by the value helps in ZCL_MM_S4_VH_QUERY)
    CLASS-METHODS create_proxy
      RETURNING VALUE(ro_proxy) TYPE REF TO /iwbep/if_cp_client_proxy
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error
                /iwbep/cx_gateway.

  PRIVATE SECTION.
    CONSTANTS c_chunk_size TYPE i VALUE 40.
    CONSTANTS c_entity_set TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'PO_PENDING_QTY'.
ENDCLASS.


CLASS zcl_mm_s4_penqty IMPLEMENTATION.

  METHOD get.
    DATA lt_po     TYPE SORTED TABLE OF zmmge_itm_t01-purchaseorder WITH UNIQUE KEY table_line.
    DATA lt_range  TYPE RANGE OF zmmge_itm_t01-purchaseorder.
    DATA lt_remote TYPE STANDARD TABLE OF zmm_s4_penqty_scm=>tys_po_pending_qty_type WITH EMPTY KEY.

    IF it_keys IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_keys INTO DATA(ls_key).
      INSERT ls_key-purchaseorder INTO TABLE lt_po.
    ENDLOOP.

    DATA(lo_proxy) = create_proxy( ).
    DATA(lv_count) = 0.

    LOOP AT lt_po INTO DATA(lv_po).
      lv_count += 1.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_po ) TO lt_range.

      IF lines( lt_range ) < c_chunk_size AND lv_count < lines( lt_po ).
        CONTINUE.
      ENDIF.

      " --- one call per chunk: $filter=PurchaseOrder eq ... or ... ---
      DATA(lo_read) = lo_proxy->create_resource_for_entity_set( c_entity_set )->create_request_for_read( ).
      lo_read->set_filter( lo_read->create_filter_factory( )->create_by_range(
                             iv_property_path = 'PURCHASE_ORDER'
                             it_range         = lt_range ) ).
      lo_read->set_top( 5000 ).

      CLEAR lt_remote.
      lo_read->execute( )->get_business_data( IMPORTING et_business_data = lt_remote ).

      LOOP AT lt_remote INTO DATA(ls_remote)
           WHERE purchase_order IS NOT INITIAL.
        IF line_exists( it_keys[ purchaseorder     = ls_remote-purchase_order
                                 purchaseorderitem = ls_remote-purchase_order_item ] ).
          INSERT VALUE #( purchaseorder     = ls_remote-purchase_order
                          purchaseorderitem = ls_remote-purchase_order_item
                          poqty             = ls_remote-po_qty
                          delqty            = ls_remote-del_qty
                          pendqty           = ls_remote-pendqty ) INTO TABLE rt_penqty.
        ENDIF.
      ENDLOOP.

      CLEAR lt_range.
    ENDLOOP.
  ENDMETHOD.


  METHOD create_proxy.
    DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                             comm_scenario = 'ZMMGE_S4_PLANT_CS'
                             service_id    = 'ZMMGE_S4_PLANT_REST' ).
    DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

    " the S/4 binding is OData V4 - Web API, so the SCM and proxy are V4
    ro_proxy = /iwbep/cl_cp_factory_remote=>create_v4_remote_proxy(
                 is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                     proxy_model_id      = 'ZMM_S4_PENQTY_SCM'
                                                     proxy_model_version = '0001' )
                 io_http_client           = lo_http_client
                 iv_relative_service_root = '/sap/opu/odata4/sap/zmm_api_po_penqty_o2/srvd_a2x/sap/zmm_sd_po_penqty/0001/' ).
  ENDMETHOD.

ENDCLASS.
