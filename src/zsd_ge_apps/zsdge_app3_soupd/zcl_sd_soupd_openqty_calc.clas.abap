CLASS zcl_sd_soupd_openqty_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.

  PRIVATE SECTION.
    CONSTANTS c_chunk_size TYPE i VALUE 40.
    CONSTANTS c_entity_set TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'OPEN_QTY'.

    TYPES tt_open TYPE STANDARD TABLE OF zsd_s4_soupd_oq_scm=>tys_open_qty_type WITH EMPTY KEY.

    TYPES ty_doc  TYPE c LENGTH 10.
    TYPES ty_item TYPE n LENGTH 6.

    "! open quantity per order item, keys normalized
    TYPES: BEGIN OF ty_open_norm,
             salesdocument TYPE ty_doc,
             salesitem     TYPE ty_item,
             open_qty      TYPE zsd_s4_soupd_oq_scm=>tys_open_qty_type-open_qty,
           END OF ty_open_norm,
           tt_open_norm TYPE SORTED TABLE OF ty_open_norm WITH UNIQUE KEY salesdocument salesitem.

    "! Open qty from S/4 for the given orders, one OData call per 40 orders
    METHODS read_open_qty
      IMPORTING it_orders      TYPE string_table
      RETURNING VALUE(rt_open) TYPE tt_open
      RAISING   cx_static_check.

    "! '1200' / '0000001200' -> '0000001200'
    METHODS norm_doc
      IMPORTING iv_doc        TYPE clike
      RETURNING VALUE(rv_doc) TYPE ty_doc.

    "! '10' / '000010' -> '000010'
    METHODS norm_item
      IMPORTING iv_item        TYPE clike
      RETURNING VALUE(rv_item) TYPE ty_item.
ENDCLASS.


CLASS zcl_sd_soupd_openqty_calc IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF line_exists( it_requested_calc_elements[ table_line = `OPENQTYLIVE` ] ).
      INSERT `SALESDOCUMENT` INTO TABLE et_requested_orig_elements.
      INSERT `SALESITEM`     INTO TABLE et_requested_orig_elements.
    ENDIF.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_items  TYPE STANDARD TABLE OF zsd_ci_gate WITH DEFAULT KEY.
    DATA lt_orders TYPE string_table.
    DATA lt_open   TYPE tt_open.
    DATA lt_norm   TYPE tt_open_norm.

    lt_items = CORRESPONDING #( it_original_data ).

    LOOP AT lt_items INTO DATA(ls_item) WHERE Salesdocument IS NOT INITIAL.
      APPEND CONV string( ls_item-Salesdocument ) TO lt_orders.
    ENDLOOP.
    SORT lt_orders.
    DELETE ADJACENT DUPLICATES FROM lt_orders.

    TRY.
        lt_open = read_open_qty( lt_orders ).
      CATCH cx_static_check.
        " S/4 not reachable: Open Qty stays blank, the page still loads
        CLEAR lt_open.
    ENDTRY.

    " S/4 keys come back in external format ('1200' / '10')
    LOOP AT lt_open INTO DATA(ls_open).
      INSERT VALUE #( salesdocument = norm_doc( ls_open-sales_document )
                      salesitem     = norm_item( ls_open-sales_document_item )
                      open_qty      = ls_open-open_qty ) INTO TABLE lt_norm.
    ENDLOOP.

    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).
      <ls_item>-OpenQtyLive = VALUE #( lt_norm[ salesdocument = norm_doc( <ls_item>-Salesdocument )
                                                salesitem     = norm_item( <ls_item>-Salesitem ) ]-open_qty OPTIONAL ).
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_items ).
  ENDMETHOD.


  METHOD norm_doc.
    rv_doc = condense( CONV string( iv_doc ) ).
    IF rv_doc CO '0123456789 '.
      rv_doc = |{ rv_doc ALPHA = IN }|.
    ENDIF.
  ENDMETHOD.


  METHOD norm_item.
    DATA(lv_text) = condense( CONV string( iv_item ) ).
    IF lv_text CO '0123456789' AND lv_text IS NOT INITIAL.
      rv_item = lv_text.
    ENDIF.
  ENDMETHOD.


  METHOD read_open_qty.
    DATA lt_range  TYPE RANGE OF zsd_s4_soupd_oq_scm=>tys_open_qty_type-sales_document.
    DATA lt_remote TYPE STANDARD TABLE OF zsd_s4_soupd_oq_scm=>tys_open_qty_type WITH EMPTY KEY.

    IF it_orders IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                             comm_scenario = 'ZMMGE_S4_PLANT_CS'
                             service_id    = 'ZMMGE_S4_PLANT_REST' ).

    DATA(lo_proxy) = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
                       is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                           proxy_model_id      = 'ZSD_S4_SOUPD_OQ_SCM'
                                                           proxy_model_version = '0001' )
                       io_http_client           = cl_web_http_client_manager=>create_by_http_destination( lo_destination )
                       iv_relative_service_root = '/sap/opu/odata/sap/ZSD_API_SD_SOUPD_O2/' ).

    LOOP AT it_orders INTO DATA(lv_order).
      APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_order ) TO lt_range.

      IF lines( lt_range ) < c_chunk_size AND sy-tabix < lines( it_orders ).
        CONTINUE.
      ENDIF.

      " --- one call per chunk: $filter=SalesDocument eq ... or ... ---
      DATA(lo_read) = lo_proxy->create_resource_for_entity_set( c_entity_set )->create_request_for_read( ).
      lo_read->set_filter( lo_read->create_filter_factory( )->create_by_range(
                             iv_property_path = 'SALES_DOCUMENT'
                             it_range         = lt_range ) ).
      lo_read->set_top( 5000 ).

      CLEAR lt_remote.
      lo_read->execute( )->get_business_data( IMPORTING et_business_data = lt_remote ).
      APPEND LINES OF lt_remote TO rt_open.

      CLEAR lt_range.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

