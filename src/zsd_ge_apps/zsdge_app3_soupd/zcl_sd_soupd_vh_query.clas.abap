CLASS zcl_sd_soupd_vh_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PRIVATE SECTION.
    "! Reads one S/4 entity set with the filter/search/paging/sort of the request
    METHODS read_remote
      IMPORTING io_request    TYPE REF TO if_rap_query_request
                iv_entity_set TYPE string
                it_search     TYPE string_table
      EXPORTING et_data       TYPE STANDARD TABLE
                ev_count      TYPE int8
      RAISING   cx_static_check.

    "! Maps a custom entity element name to the remote OData property
    METHODS map_element
      IMPORTING iv_element         TYPE string
      RETURNING VALUE(rv_property) TYPE string.
ENDCLASS.


CLASS zcl_sd_soupd_vh_query IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    DATA lt_cust_r  TYPE STANDARD TABLE OF zsd_s4_soupd_scm=>tys_customer_type WITH EMPTY KEY.
    DATA lt_order_r TYPE STANDARD TABLE OF zsd_s4_soupd_scm=>tys_sales_order_vhtype WITH EMPTY KEY.
    DATA lt_item_r  TYPE STANDARD TABLE OF zsd_s4_soupd_scm=>tys_sales_order_item_vhtype WITH EMPTY KEY.
    DATA lt_cust    TYPE STANDARD TABLE OF zsd_soupd_custvh WITH EMPTY KEY.
    DATA lt_order   TYPE STANDARD TABLE OF zsd_order_vh WITH EMPTY KEY.
    DATA lt_item    TYPE STANDARD TABLE OF zsd_orderitem_vh WITH EMPTY KEY.
    DATA lv_count   TYPE int8.

    TRY.
        CASE io_request->get_entity_id( ).

          WHEN 'ZSD_SOUPD_CUSTVH'.
            read_remote( EXPORTING io_request    = io_request
                                   iv_entity_set = `CUSTOMER`
                                   it_search     = VALUE #( ( `CUSTOMER` ) ( `CUSTOMER_NAME` ) )
                         IMPORTING et_data       = lt_cust_r
                                   ev_count      = lv_count ).
            IF io_request->is_data_requested( ).
              lt_cust = VALUE #( FOR ls_c IN lt_cust_r
                                 ( Customer     = ls_c-customer
                                   CustomerName = ls_c-customer_name ) ).
              io_response->set_data( lt_cust ).
            ENDIF.

          WHEN 'ZSD_ORDER_VH'.
            read_remote( EXPORTING io_request    = io_request
                                   iv_entity_set = `SALES_ORDER_VH`
                                   it_search     = VALUE #( ( `SALES_DOCUMENT` ) ( `CUSTOMER_NAME` ) )
                         IMPORTING et_data       = lt_order_r
                                   ev_count      = lv_count ).
            IF io_request->is_data_requested( ).
              lt_order = VALUE #( FOR ls_o IN lt_order_r
                                  ( SalesDocument = ls_o-sales_document
                                    Customer      = ls_o-customer
                                    CustomerName  = ls_o-customer_name ) ).
              io_response->set_data( lt_order ).
            ENDIF.

          WHEN 'ZSD_ORDERITEM_VH'.
            read_remote( EXPORTING io_request    = io_request
                                   iv_entity_set = `SALES_ORDER_ITEM_VH`
                                   it_search     = VALUE #( ( `SALES_DOCUMENT_ITEM` ) ( `PRODUCT_DESCRIPTION` ) )
                         IMPORTING et_data       = lt_item_r
                                   ev_count      = lv_count ).
            IF io_request->is_data_requested( ).
              lt_item = VALUE #( FOR ls_i IN lt_item_r
                                 ( SalesDocument      = ls_i-sales_document
                                   SalesDocumentItem  = ls_i-sales_document_item
                                   Customer           = ls_i-customer
                                   ProductDescription = ls_i-product_description ) ).
              io_response->set_data( lt_item ).
            ENDIF.

        ENDCASE.

        IF io_request->is_total_numb_of_rec_requested( ).
          io_response->set_total_number_of_records( lv_count ).
        ENDIF.

      CATCH cx_static_check INTO DATA(lx_error).
        RAISE EXCEPTION NEW lcx_soupd_vh( previous = lx_error ).
    ENDTRY.
  ENDMETHOD.


  METHOD read_remote.
    DATA lt_ranges  TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA lt_orderby TYPE /iwbep/if_cp_runtime_types=>ty_t_sort_order.
    DATA lo_filter  TYPE REF TO /iwbep/if_cp_filter_node.

    CLEAR: et_data, ev_count.

    DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                             comm_scenario = 'ZMMGE_S4_PLANT_CS'
                             service_id    = 'ZMMGE_S4_PLANT_REST' ).

    DATA(lo_proxy) = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
                       is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                           proxy_model_id      = 'ZSD_S4_SOUPD_SCM'
                                                           proxy_model_version = '0001' )
                       io_http_client           = cl_web_http_client_manager=>create_by_http_destination( lo_destination )
                       iv_relative_service_root = '/sap/opu/odata/sap/ZSD_API_SD_SOUPD_O2/' ).

    DATA(lo_read) = lo_proxy->create_resource_for_entity_set(
                      CONV /iwbep/if_cp_runtime_types=>ty_entity_set_name( iv_entity_set ) )->create_request_for_read( ).
    DATA(lo_filter_factory) = lo_read->create_filter_factory( ).

    " --- $filter (also from additionalBinding, e.g. Customer -> Sales Order) ---
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
      DATA(lt_pattern) = VALUE if_rap_query_filter=>tt_range_option(
                           ( sign = 'I' option = 'CP' low = |*{ lv_search }*| ) ).
      DATA lo_search TYPE REF TO /iwbep/if_cp_filter_node.
      LOOP AT it_search INTO DATA(lv_prop).
        DATA(lo_one) = lo_filter_factory->create_by_range( iv_property_path = lv_prop
                                                           it_range         = lt_pattern ).
        lo_search = COND #( WHEN lo_search IS BOUND THEN lo_search->or( lo_one ) ELSE lo_one ).
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
      lo_response->get_business_data( IMPORTING et_business_data = et_data ).
    ENDIF.
    IF io_request->is_total_numb_of_rec_requested( ).
      ev_count = lo_response->get_count( ).
    ENDIF.
  ENDMETHOD.


  METHOD map_element.
    rv_property = SWITCH #( iv_element
                            WHEN 'CUSTOMER'           THEN `CUSTOMER`
                            WHEN 'CUSTOMERNAME'       THEN `CUSTOMER_NAME`
                            WHEN 'SALESDOCUMENT'      THEN `SALES_DOCUMENT`
                            WHEN 'SALESDOCUMENTITEM'  THEN `SALES_DOCUMENT_ITEM`
                            WHEN 'PRODUCTDESCRIPTION' THEN `PRODUCT_DESCRIPTION`
                            ELSE iv_element ).
  ENDMETHOD.

ENDCLASS.
