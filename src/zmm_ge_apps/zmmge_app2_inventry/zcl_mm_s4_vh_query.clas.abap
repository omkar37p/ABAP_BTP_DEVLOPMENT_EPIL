CLASS zcl_mm_s4_vh_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PRIVATE SECTION.
    "! Maps a custom entity element name to the remote OData property
    METHODS map_element
      IMPORTING iv_element         TYPE string
      RETURNING VALUE(rv_property) TYPE string.
ENDCLASS.


CLASS zcl_mm_s4_vh_query IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    DATA lv_entity_set   TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name.
    DATA lt_search_props TYPE string_table.
    DATA lt_ranges       TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA lt_orderby      TYPE /iwbep/if_cp_runtime_types=>ty_t_sort_order.
    DATA lo_filter       TYPE REF TO /iwbep/if_cp_filter_node.

    DATA(lv_entity) = io_request->get_entity_id( ).

    CASE lv_entity.
      WHEN 'ZMM_SUP_VH'.
        lv_entity_set   = 'SUPPLIER_VH'.
        lt_search_props = VALUE #( ( `VENDOR` ) ( `SUPPLIER_NAME` ) ).
      WHEN 'ZMM_POHDVH'.
        lv_entity_set   = 'PO_HEADER_VH'.
        lt_search_props = VALUE #( ( `PURCHASE_ORDER` ) ( `VENDOR` ) ( `SUPPLIER_NAME` ) ).
      WHEN 'ZMM_POITVH'.
        lv_entity_set   = 'PO_ITEM_VH'.
        lt_search_props = VALUE #( ( `PURCHASE_ORDER` ) ( `MATERIAL` ) ( `PURCHASE_ORDER_ITEM_TEXT` ) ).
      WHEN OTHERS.
        RETURN.
    ENDCASE.

    TRY.
        DATA(lo_read) = zcl_mm_s4_penqty=>create_proxy(
                          )->create_resource_for_entity_set( lv_entity_set
                          )->create_request_for_read( ).
        DATA(lo_filter_factory) = lo_read->create_filter_factory( ).

        " --- $filter (Vendor / PurchaseOrder from the popup, typed input) ---
        TRY.
            lt_ranges = io_request->get_filter( )->get_as_ranges( ).
          CATCH cx_rap_query_filter_no_range.
            CLEAR lt_ranges.
        ENDTRY.

        LOOP AT lt_ranges INTO DATA(ls_range).
          DATA(lo_node) = lo_filter_factory->create_by_range( iv_property_path = map_element( ls_range-name )
                                                              it_range         = ls_range-range ).
          lo_filter = COND #( WHEN lo_filter IS BOUND THEN lo_filter->and( lo_node ) ELSE lo_node ).
        ENDLOOP.

        " --- search field in the value-help dialog ---
        DATA(lv_search) = io_request->get_search_expression( ).
        IF lv_search IS NOT INITIAL.
          lv_search = replace( val = lv_search sub = `"` with = `` occ = 0 ).
          DATA(lt_search) = VALUE if_rap_query_filter=>tt_range_option(
                              ( sign = 'I' option = 'CP' low = |*{ lv_search }*| ) ).
          DATA lo_search TYPE REF TO /iwbep/if_cp_filter_node.
          LOOP AT lt_search_props INTO DATA(lv_prop).
            DATA(lo_search_node) = lo_filter_factory->create_by_range( iv_property_path = lv_prop
                                                                       it_range         = lt_search ).
            lo_search = COND #( WHEN lo_search IS BOUND THEN lo_search->or( lo_search_node ) ELSE lo_search_node ).
          ENDLOOP.
          lo_filter = COND #( WHEN lo_filter IS BOUND THEN lo_filter->and( lo_search ) ELSE lo_search ).
        ENDIF.

        IF lo_filter IS BOUND.
          lo_read->set_filter( lo_filter ).
        ENDIF.

        " --- $skip / $top ---
        DATA(lo_paging) = io_request->get_paging( ).
        IF lo_paging->get_offset( ) > 0.
          lo_read->set_skip( lo_paging->get_offset( ) ).
        ENDIF.
        IF lo_paging->get_page_size( ) <> if_rap_query_paging=>page_size_unlimited.
          lo_read->set_top( lo_paging->get_page_size( ) ).
        ENDIF.

        " --- $orderby ---
        LOOP AT io_request->get_sort_elements( ) INTO DATA(ls_sort).
          APPEND VALUE #( property_path = map_element( CONV #( ls_sort-element_name ) )
                          descending    = ls_sort-descending ) TO lt_orderby.
        ENDLOOP.
        IF lt_orderby IS NOT INITIAL.
          lo_read->set_orderby( lt_orderby ).
        ENDIF.

        " --- $count ---
        IF io_request->is_total_numb_of_rec_requested( ).
          lo_read->request_count( ).
        ENDIF.

        DATA(lo_response) = lo_read->execute( ).

        IF io_request->is_data_requested( ).
          CASE lv_entity.
            WHEN 'ZMM_SUP_VH'.
              DATA lt_sup TYPE STANDARD TABLE OF zmm_s4_penqty_scm=>tys_supplier_vhtype WITH EMPTY KEY.
              DATA lt_sup_out TYPE STANDARD TABLE OF zmm_sup_vh WITH EMPTY KEY.
              lo_response->get_business_data( IMPORTING et_business_data = lt_sup ).
              lt_sup_out = VALUE #( FOR ls_sup IN lt_sup
                                    ( vendor       = ls_sup-vendor
                                      suppliername = ls_sup-supplier_name ) ).
              io_response->set_data( lt_sup_out ).

            WHEN 'ZMM_POHDVH'.
              DATA lt_pohd TYPE STANDARD TABLE OF zmm_s4_penqty_scm=>tys_po_header_vhtype WITH EMPTY KEY.
              DATA lt_pohd_out TYPE STANDARD TABLE OF zmm_pohdvh WITH EMPTY KEY.
              lo_response->get_business_data( IMPORTING et_business_data = lt_pohd ).
              lt_pohd_out = VALUE #( FOR ls_pohd IN lt_pohd
                                     ( purchaseorder = ls_pohd-purchase_order
                                       vendor        = ls_pohd-vendor
                                       suppliername  = ls_pohd-supplier_name ) ).
              io_response->set_data( lt_pohd_out ).

            WHEN 'ZMM_POITVH'.
              DATA lt_poit TYPE STANDARD TABLE OF zmm_s4_penqty_scm=>tys_po_item_vhtype WITH EMPTY KEY.
              DATA lt_poit_out TYPE STANDARD TABLE OF zmm_poitvh WITH EMPTY KEY.
              lo_response->get_business_data( IMPORTING et_business_data = lt_poit ).
              lt_poit_out = VALUE #( FOR ls_poit IN lt_poit
                                     ( purchaseorder         = ls_poit-purchase_order
                                       purchaseorderitem     = ls_poit-purchase_order_item
                                       material              = ls_poit-material
                                       purchaseorderitemtext = ls_poit-purchase_order_item_text
                                       vendor                = ls_poit-vendor ) ).
              io_response->set_data( lt_poit_out ).
          ENDCASE.
        ENDIF.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lo_response->get_count( ) ).
        ENDIF.

      CATCH cx_http_dest_provider_error
            cx_web_http_client_error
            /iwbep/cx_gateway INTO DATA(lx_error).
        RAISE EXCEPTION NEW lcx_vh( previous = lx_error ).
    ENDTRY.
  ENDMETHOD.


  METHOD map_element.
    rv_property = SWITCH #( iv_element
                            WHEN 'VENDOR'                THEN `VENDOR`
                            WHEN 'SUPPLIERNAME'          THEN `SUPPLIER_NAME`
                            WHEN 'PURCHASEORDER'         THEN `PURCHASE_ORDER`
                            WHEN 'PURCHASEORDERITEM'     THEN `PURCHASE_ORDER_ITEM`
                            WHEN 'MATERIAL'              THEN `MATERIAL`
                            WHEN 'PURCHASEORDERITEMTEXT' THEN `PURCHASE_ORDER_ITEM_TEXT`
                            ELSE iv_element ).
  ENDMETHOD.

ENDCLASS.
