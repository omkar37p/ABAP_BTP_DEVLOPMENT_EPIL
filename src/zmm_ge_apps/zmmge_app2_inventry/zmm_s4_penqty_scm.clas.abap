"! <p class="shorttext synchronized">Consumption model for client proxy - generated</p>
"! This class has been generated based on the metadata with namespace
"! <em>com.sap.gateway.srvd_a2x.zmm_sd_po_penqty.v0001</em>
CLASS zmm_s4_penqty_scm DEFINITION
  PUBLIC
  INHERITING FROM /iwbep/cl_v4_abs_pm_model_prov
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      "! <p class="shorttext synchronized">PoHeaderVHType</p>
      BEGIN OF tys_po_header_vhtype,
        "! <em>Key property</em> PurchaseOrder
        purchase_order TYPE c LENGTH 10,
        "! Vendor
        vendor         TYPE c LENGTH 10,
        "! SupplierName
        supplier_name  TYPE c LENGTH 35,
      END OF tys_po_header_vhtype,
      "! <p class="shorttext synchronized">List of PoHeaderVHType</p>
      tyt_po_header_vhtype TYPE STANDARD TABLE OF tys_po_header_vhtype WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">PoItemVHType</p>
      BEGIN OF tys_po_item_vhtype,
        "! <em>Key property</em> PurchaseOrder
        purchase_order           TYPE c LENGTH 10,
        "! <em>Key property</em> PurchaseOrderItem
        purchase_order_item      TYPE c LENGTH 5,
        "! Material
        material                 TYPE c LENGTH 18,
        "! PurchaseOrderItemText
        purchase_order_item_text TYPE c LENGTH 40,
        "! Vendor
        vendor                   TYPE c LENGTH 10,
      END OF tys_po_item_vhtype,
      "! <p class="shorttext synchronized">List of PoItemVHType</p>
      tyt_po_item_vhtype TYPE STANDARD TABLE OF tys_po_item_vhtype WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">PoPendingQtyType</p>
      BEGIN OF tys_po_pending_qty_type,
        "! <em>Key property</em> PurchaseOrder
        purchase_order      TYPE c LENGTH 10,
        "! <em>Key property</em> PurchaseOrderItem
        purchase_order_item TYPE c LENGTH 5,
        "! PoQty
        po_qty              TYPE p LENGTH 7 DECIMALS 3,
        "! DelQty
        del_qty             TYPE p LENGTH 7 DECIMALS 3,
        "! Pendqty
        pendqty             TYPE p LENGTH 7 DECIMALS 3,
      END OF tys_po_pending_qty_type,
      "! <p class="shorttext synchronized">List of PoPendingQtyType</p>
      tyt_po_pending_qty_type TYPE STANDARD TABLE OF tys_po_pending_qty_type WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">SupplierVHType</p>
      BEGIN OF tys_supplier_vhtype,
        "! <em>Key property</em> Vendor
        vendor        TYPE c LENGTH 10,
        "! SupplierName
        supplier_name TYPE c LENGTH 35,
      END OF tys_supplier_vhtype,
      "! <p class="shorttext synchronized">List of SupplierVHType</p>
      tyt_supplier_vhtype TYPE STANDARD TABLE OF tys_supplier_vhtype WITH DEFAULT KEY.


    CONSTANTS:
      "! <p class="shorttext synchronized">Internal Names of the entity sets</p>
      BEGIN OF gcs_entity_set,
        "! PoHeaderVH
        "! <br/> Collection of type 'PoHeaderVHType'
        po_header_vh   TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'PO_HEADER_VH',
        "! PoItemVH
        "! <br/> Collection of type 'PoItemVHType'
        po_item_vh     TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'PO_ITEM_VH',
        "! PoPendingQty
        "! <br/> Collection of type 'PoPendingQtyType'
        po_pending_qty TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'PO_PENDING_QTY',
        "! SupplierVH
        "! <br/> Collection of type 'SupplierVHType'
        supplier_vh    TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'SUPPLIER_VH',
      END OF gcs_entity_set .

    CONSTANTS:
      "! <p class="shorttext synchronized">Internal names for entity types</p>
      BEGIN OF gcs_entity_type,
        "! <p class="shorttext synchronized">Internal names for PoHeaderVHType</p>
        "! See also structure type {@link ..tys_po_header_vhtype}
        BEGIN OF po_header_vhtype,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF po_header_vhtype,
        "! <p class="shorttext synchronized">Internal names for PoItemVHType</p>
        "! See also structure type {@link ..tys_po_item_vhtype}
        BEGIN OF po_item_vhtype,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF po_item_vhtype,
        "! <p class="shorttext synchronized">Internal names for PoPendingQtyType</p>
        "! See also structure type {@link ..tys_po_pending_qty_type}
        BEGIN OF po_pending_qty_type,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF po_pending_qty_type,
        "! <p class="shorttext synchronized">Internal names for SupplierVHType</p>
        "! See also structure type {@link ..tys_supplier_vhtype}
        BEGIN OF supplier_vhtype,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF supplier_vhtype,
      END OF gcs_entity_type.


    METHODS /iwbep/if_v4_mp_basic_pm~define REDEFINITION.


  PRIVATE SECTION.

    "! <p class="shorttext synchronized">Model</p>
    DATA mo_model TYPE REF TO /iwbep/if_v4_pm_model.


    "! <p class="shorttext synchronized">Define PoHeaderVHType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_po_header_vhtype RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define PoItemVHType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_po_item_vhtype RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define PoPendingQtyType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_po_pending_qty_type RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define SupplierVHType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_supplier_vhtype RAISING /iwbep/cx_gateway.

ENDCLASS.



CLASS ZMM_S4_PENQTY_SCM IMPLEMENTATION.


  METHOD /iwbep/if_v4_mp_basic_pm~define.

    mo_model = io_model.
    mo_model->set_schema_namespace( 'com.sap.gateway.srvd_a2x.zmm_sd_po_penqty.v0001' ) ##NO_TEXT.

    def_po_header_vhtype( ).
    def_po_item_vhtype( ).
    def_po_pending_qty_type( ).
    def_supplier_vhtype( ).

  ENDMETHOD.


  METHOD def_po_header_vhtype.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'PO_HEADER_VHTYPE'
                                    is_structure              = VALUE tys_po_header_vhtype( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'PoHeaderVHType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'PO_HEADER_VH' ).
    lo_entity_set->set_edm_name( 'PoHeaderVH' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'PURCHASE_ORDER' ).
    lo_primitive_property->set_edm_name( 'PurchaseOrder' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'VENDOR' ).
    lo_primitive_property->set_edm_name( 'Vendor' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SUPPLIER_NAME' ).
    lo_primitive_property->set_edm_name( 'SupplierName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 35 ) ##NUMBER_OK.

  ENDMETHOD.


  METHOD def_po_item_vhtype.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'PO_ITEM_VHTYPE'
                                    is_structure              = VALUE tys_po_item_vhtype( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'PoItemVHType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'PO_ITEM_VH' ).
    lo_entity_set->set_edm_name( 'PoItemVH' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'PURCHASE_ORDER' ).
    lo_primitive_property->set_edm_name( 'PurchaseOrder' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PURCHASE_ORDER_ITEM' ).
    lo_primitive_property->set_edm_name( 'PurchaseOrderItem' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 5 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'MATERIAL' ).
    lo_primitive_property->set_edm_name( 'Material' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 18 ) ##NUMBER_OK.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PURCHASE_ORDER_ITEM_TEXT' ).
    lo_primitive_property->set_edm_name( 'PurchaseOrderItemText' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 40 ) ##NUMBER_OK.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'VENDOR' ).
    lo_primitive_property->set_edm_name( 'Vendor' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.

  ENDMETHOD.


  METHOD def_po_pending_qty_type.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'PO_PENDING_QTY_TYPE'
                                    is_structure              = VALUE tys_po_pending_qty_type( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'PoPendingQtyType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'PO_PENDING_QTY' ).
    lo_entity_set->set_edm_name( 'PoPendingQty' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'PURCHASE_ORDER' ).
    lo_primitive_property->set_edm_name( 'PurchaseOrder' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PURCHASE_ORDER_ITEM' ).
    lo_primitive_property->set_edm_name( 'PurchaseOrderItem' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 5 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PO_QTY' ).
    lo_primitive_property->set_edm_name( 'PoQty' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 13 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'DEL_QTY' ).
    lo_primitive_property->set_edm_name( 'DelQty' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 13 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PENDQTY' ).
    lo_primitive_property->set_edm_name( 'Pendqty' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 13 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.

  ENDMETHOD.


  METHOD def_supplier_vhtype.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'SUPPLIER_VHTYPE'
                                    is_structure              = VALUE tys_supplier_vhtype( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'SupplierVHType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'SUPPLIER_VH' ).
    lo_entity_set->set_edm_name( 'SupplierVH' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'VENDOR' ).
    lo_primitive_property->set_edm_name( 'Vendor' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SUPPLIER_NAME' ).
    lo_primitive_property->set_edm_name( 'SupplierName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 35 ) ##NUMBER_OK.

  ENDMETHOD.
ENDCLASS.
