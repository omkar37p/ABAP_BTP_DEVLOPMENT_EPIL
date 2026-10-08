"! <p class="shorttext synchronized">Consumption model for client proxy - generated</p>
"! This class has been generated based on the metadata with namespace
"! <em>cds_zsd_sd_soupd</em>
CLASS zsd_s4_soupd_scm DEFINITION
  PUBLIC
  INHERITING FROM /iwbep/cl_v4_abs_pm_model_prov
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      "! <p class="shorttext synchronized">CustomerType</p>
      BEGIN OF tys_customer_type,
        "! <em>Key property</em> Customer
        customer      TYPE c LENGTH 10,
        "! CustomerName
        customer_name TYPE c LENGTH 80,
      END OF tys_customer_type,
      "! <p class="shorttext synchronized">List of CustomerType</p>
      tyt_customer_type TYPE STANDARD TABLE OF tys_customer_type WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">OrderPartnerType</p>
      BEGIN OF tys_order_partner_type,
        "! <em>Key property</em> SalesOrder
        sales_order      TYPE c LENGTH 10,
        "! <em>Key property</em> PartnerFunction
        partner_function TYPE c LENGTH 2,
        "! Customer
        customer         TYPE c LENGTH 10,
        "! StreetName
        street_name      TYPE c LENGTH 60,
        "! CityName
        city_name        TYPE c LENGTH 40,
        "! PostalCode
        postal_code      TYPE c LENGTH 10,
        "! CountryName
        country_name     TYPE c LENGTH 50,
        "! RegionName
        region_name      TYPE c LENGTH 20,
      END OF tys_order_partner_type,
      "! <p class="shorttext synchronized">List of OrderPartnerType</p>
      tyt_order_partner_type TYPE STANDARD TABLE OF tys_order_partner_type WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">ReturnItemType</p>
      BEGIN OF tys_return_item_type,
        "! <em>Key property</em> SalesDocument
        sales_document       TYPE c LENGTH 10,
        "! <em>Key property</em> SalesDocumentItem
        sales_document_item  TYPE c LENGTH 6,
        "! Plant
        plant                TYPE c LENGTH 4,
        "! Product
        product              TYPE c LENGTH 18,
        "! Batch
        batch                TYPE c LENGTH 10,
        "! OrderQuantity
        order_quantity       TYPE p LENGTH 8 DECIMALS 3,
        "! OrderQuantityUnit
        order_quantity_unit  TYPE c LENGTH 3,
        "! BaseUnit
        base_unit            TYPE c LENGTH 3,
        "! SoldToParty
        sold_to_party        TYPE c LENGTH 10,
        "! Division
        division             TYPE c LENGTH 2,
        "! SalesDocumentType
        sales_document_type  TYPE c LENGTH 4,
        "! DistributionChannel
        distribution_channel TYPE c LENGTH 2,
        "! ShippingPoint
        shipping_point       TYPE c LENGTH 4,
        "! PlantName
        plant_name           TYPE c LENGTH 30,
        "! ProductName
        product_name         TYPE c LENGTH 40,
        "! CustomerName
        customer_name        TYPE c LENGTH 80,
        "! PlantStreet
        plant_street         TYPE c LENGTH 60,
        "! PlantCity
        plant_city           TYPE c LENGTH 40,
        "! PlantPostalCode
        plant_postal_code    TYPE c LENGTH 10,
        "! PlantCountryName
        plant_country_name   TYPE c LENGTH 50,
        "! PlantRegionName
        plant_region_name    TYPE c LENGTH 20,
      END OF tys_return_item_type,
      "! <p class="shorttext synchronized">List of ReturnItemType</p>
      tyt_return_item_type TYPE STANDARD TABLE OF tys_return_item_type WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">SalesOrderItemType</p>
      BEGIN OF tys_sales_order_item_type,
        "! <em>Key property</em> SalesDocument
        sales_document             TYPE c LENGTH 10,
        "! <em>Key property</em> SalesDocumentItem
        sales_document_item        TYPE c LENGTH 6,
        "! Plant
        plant                      TYPE c LENGTH 4,
        "! Product
        product                    TYPE c LENGTH 18,
        "! Batch
        batch                      TYPE c LENGTH 10,
        "! OrderQuantity
        order_quantity             TYPE p LENGTH 8 DECIMALS 3,
        "! OrderQuantityUnit
        order_quantity_unit        TYPE c LENGTH 3,
        "! BaseUnit
        base_unit                  TYPE c LENGTH 3,
        "! SoldToParty
        sold_to_party              TYPE c LENGTH 10,
        "! Division
        division                   TYPE c LENGTH 2,
        "! SalesDocumentType
        sales_document_type        TYPE c LENGTH 4,
        "! DistributionChannel
        distribution_channel       TYPE c LENGTH 2,
        "! ShippingPoint
        shipping_point             TYPE c LENGTH 4,
        "! IndependentRequirementType
        independent_requirement_ty TYPE c LENGTH 4,
        "! SDProcessStatus
        sdprocess_status           TYPE c LENGTH 1,
        "! PlantName
        plant_name                 TYPE c LENGTH 30,
        "! ProductName
        product_name               TYPE c LENGTH 40,
        "! CustomerName
        customer_name              TYPE c LENGTH 80,
        "! PlantStreet
        plant_street               TYPE c LENGTH 60,
        "! PlantCity
        plant_city                 TYPE c LENGTH 40,
        "! PlantPostalCode
        plant_postal_code          TYPE c LENGTH 10,
        "! PlantCountryName
        plant_country_name         TYPE c LENGTH 50,
        "! PlantRegionName
        plant_region_name          TYPE c LENGTH 20,
      END OF tys_sales_order_item_type,
      "! <p class="shorttext synchronized">List of SalesOrderItemType</p>
      tyt_sales_order_item_type TYPE STANDARD TABLE OF tys_sales_order_item_type WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">SalesOrderItemVHType</p>
      BEGIN OF tys_sales_order_item_vhtype,
        "! <em>Key property</em> SalesDocument
        sales_document      TYPE c LENGTH 10,
        "! <em>Key property</em> SalesDocumentItem
        sales_document_item TYPE c LENGTH 6,
        "! Customer
        customer            TYPE c LENGTH 10,
        "! ProductDescription
        product_description TYPE c LENGTH 40,
      END OF tys_sales_order_item_vhtype,
      "! <p class="shorttext synchronized">List of SalesOrderItemVHType</p>
      tyt_sales_order_item_vhtype TYPE STANDARD TABLE OF tys_sales_order_item_vhtype WITH DEFAULT KEY.

    TYPES:
      "! <p class="shorttext synchronized">SalesOrderVHType</p>
      BEGIN OF tys_sales_order_vhtype,
        "! <em>Key property</em> SalesDocument
        sales_document TYPE c LENGTH 10,
        "! Customer
        customer       TYPE c LENGTH 10,
        "! CustomerName
        customer_name  TYPE c LENGTH 80,
      END OF tys_sales_order_vhtype,
      "! <p class="shorttext synchronized">List of SalesOrderVHType</p>
      tyt_sales_order_vhtype TYPE STANDARD TABLE OF tys_sales_order_vhtype WITH DEFAULT KEY.


    CONSTANTS:
      "! <p class="shorttext synchronized">Internal Names of the entity sets</p>
      BEGIN OF gcs_entity_set,
        "! Customer
        "! <br/> Collection of type 'CustomerType'
        customer            TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'CUSTOMER',
        "! OrderPartner
        "! <br/> Collection of type 'OrderPartnerType'
        order_partner       TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'ORDER_PARTNER',
        "! ReturnItem
        "! <br/> Collection of type 'ReturnItemType'
        return_item         TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'RETURN_ITEM',
        "! SalesOrderItem
        "! <br/> Collection of type 'SalesOrderItemType'
        sales_order_item    TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'SALES_ORDER_ITEM',
        "! SalesOrderItemVH
        "! <br/> Collection of type 'SalesOrderItemVHType'
        sales_order_item_vh TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'SALES_ORDER_ITEM_VH',
        "! SalesOrderVH
        "! <br/> Collection of type 'SalesOrderVHType'
        sales_order_vh      TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'SALES_ORDER_VH',
      END OF gcs_entity_set .

    CONSTANTS:
      "! <p class="shorttext synchronized">Internal names for entity types</p>
      BEGIN OF gcs_entity_type,
        "! <p class="shorttext synchronized">Internal names for CustomerType</p>
        "! See also structure type {@link ..tys_customer_type}
        BEGIN OF customer_type,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF customer_type,
        "! <p class="shorttext synchronized">Internal names for OrderPartnerType</p>
        "! See also structure type {@link ..tys_order_partner_type}
        BEGIN OF order_partner_type,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF order_partner_type,
        "! <p class="shorttext synchronized">Internal names for ReturnItemType</p>
        "! See also structure type {@link ..tys_return_item_type}
        BEGIN OF return_item_type,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF return_item_type,
        "! <p class="shorttext synchronized">Internal names for SalesOrderItemType</p>
        "! See also structure type {@link ..tys_sales_order_item_type}
        BEGIN OF sales_order_item_type,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF sales_order_item_type,
        "! <p class="shorttext synchronized">Internal names for SalesOrderItemVHType</p>
        "! See also structure type {@link ..tys_sales_order_item_vhtype}
        BEGIN OF sales_order_item_vhtype,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF sales_order_item_vhtype,
        "! <p class="shorttext synchronized">Internal names for SalesOrderVHType</p>
        "! See also structure type {@link ..tys_sales_order_vhtype}
        BEGIN OF sales_order_vhtype,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF sales_order_vhtype,
      END OF gcs_entity_type.


    METHODS /iwbep/if_v4_mp_basic_pm~define REDEFINITION.


  PRIVATE SECTION.

    "! <p class="shorttext synchronized">Model</p>
    DATA mo_model TYPE REF TO /iwbep/if_v4_pm_model.


    "! <p class="shorttext synchronized">Define CustomerType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_customer_type RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define OrderPartnerType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_order_partner_type RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define ReturnItemType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_return_item_type RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define SalesOrderItemType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_sales_order_item_type RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define SalesOrderItemVHType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_sales_order_item_vhtype RAISING /iwbep/cx_gateway.

    "! <p class="shorttext synchronized">Define SalesOrderVHType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_sales_order_vhtype RAISING /iwbep/cx_gateway.

ENDCLASS.



CLASS ZSD_S4_SOUPD_SCM IMPLEMENTATION.


  METHOD /iwbep/if_v4_mp_basic_pm~define.

    mo_model = io_model.
    mo_model->set_schema_namespace( 'cds_zsd_sd_soupd' ) ##NO_TEXT.

    def_customer_type( ).
    def_order_partner_type( ).
    def_return_item_type( ).
    def_sales_order_item_type( ).
    def_sales_order_item_vhtype( ).
    def_sales_order_vhtype( ).

  ENDMETHOD.


  METHOD def_customer_type.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'CUSTOMER_TYPE'
                                    is_structure              = VALUE tys_customer_type( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'CustomerType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'CUSTOMER' ).
    lo_entity_set->set_edm_name( 'Customer' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'CUSTOMER' ).
    lo_primitive_property->set_edm_name( 'Customer' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CUSTOMER_NAME' ).
    lo_primitive_property->set_edm_name( 'CustomerName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 80 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

  ENDMETHOD.


  METHOD def_order_partner_type.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'ORDER_PARTNER_TYPE'
                                    is_structure              = VALUE tys_order_partner_type( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'OrderPartnerType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'ORDER_PARTNER' ).
    lo_entity_set->set_edm_name( 'OrderPartner' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_ORDER' ).
    lo_primitive_property->set_edm_name( 'SalesOrder' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PARTNER_FUNCTION' ).
    lo_primitive_property->set_edm_name( 'PartnerFunction' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 2 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CUSTOMER' ).
    lo_primitive_property->set_edm_name( 'Customer' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'STREET_NAME' ).
    lo_primitive_property->set_edm_name( 'StreetName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 60 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CITY_NAME' ).
    lo_primitive_property->set_edm_name( 'CityName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 40 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'POSTAL_CODE' ).
    lo_primitive_property->set_edm_name( 'PostalCode' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'COUNTRY_NAME' ).
    lo_primitive_property->set_edm_name( 'CountryName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 50 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'REGION_NAME' ).
    lo_primitive_property->set_edm_name( 'RegionName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 20 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

  ENDMETHOD.


  METHOD def_return_item_type.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'RETURN_ITEM_TYPE'
                                    is_structure              = VALUE tys_return_item_type( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'ReturnItemType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'RETURN_ITEM' ).
    lo_entity_set->set_edm_name( 'ReturnItem' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_DOCUMENT' ).
    lo_primitive_property->set_edm_name( 'SalesDocument' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_DOCUMENT_ITEM' ).
    lo_primitive_property->set_edm_name( 'SalesDocumentItem' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 6 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT' ).
    lo_primitive_property->set_edm_name( 'Plant' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PRODUCT' ).
    lo_primitive_property->set_edm_name( 'Product' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 18 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'BATCH' ).
    lo_primitive_property->set_edm_name( 'Batch' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'ORDER_QUANTITY' ).
    lo_primitive_property->set_edm_name( 'OrderQuantity' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 15 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'ORDER_QUANTITY_UNIT' ).
    lo_primitive_property->set_edm_name( 'OrderQuantityUnit' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'BASE_UNIT' ).
    lo_primitive_property->set_edm_name( 'BaseUnit' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SOLD_TO_PARTY' ).
    lo_primitive_property->set_edm_name( 'SoldToParty' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'DIVISION' ).
    lo_primitive_property->set_edm_name( 'Division' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 2 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_DOCUMENT_TYPE' ).
    lo_primitive_property->set_edm_name( 'SalesDocumentType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'DISTRIBUTION_CHANNEL' ).
    lo_primitive_property->set_edm_name( 'DistributionChannel' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 2 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SHIPPING_POINT' ).
    lo_primitive_property->set_edm_name( 'ShippingPoint' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_NAME' ).
    lo_primitive_property->set_edm_name( 'PlantName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 30 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PRODUCT_NAME' ).
    lo_primitive_property->set_edm_name( 'ProductName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 40 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CUSTOMER_NAME' ).
    lo_primitive_property->set_edm_name( 'CustomerName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 80 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_STREET' ).
    lo_primitive_property->set_edm_name( 'PlantStreet' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 60 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_CITY' ).
    lo_primitive_property->set_edm_name( 'PlantCity' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 40 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_POSTAL_CODE' ).
    lo_primitive_property->set_edm_name( 'PlantPostalCode' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_COUNTRY_NAME' ).
    lo_primitive_property->set_edm_name( 'PlantCountryName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 50 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_REGION_NAME' ).
    lo_primitive_property->set_edm_name( 'PlantRegionName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 20 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

  ENDMETHOD.


  METHOD def_sales_order_item_type.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'SALES_ORDER_ITEM_TYPE'
                                    is_structure              = VALUE tys_sales_order_item_type( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'SalesOrderItemType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'SALES_ORDER_ITEM' ).
    lo_entity_set->set_edm_name( 'SalesOrderItem' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_DOCUMENT' ).
    lo_primitive_property->set_edm_name( 'SalesDocument' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_DOCUMENT_ITEM' ).
    lo_primitive_property->set_edm_name( 'SalesDocumentItem' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 6 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT' ).
    lo_primitive_property->set_edm_name( 'Plant' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PRODUCT' ).
    lo_primitive_property->set_edm_name( 'Product' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 18 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'BATCH' ).
    lo_primitive_property->set_edm_name( 'Batch' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'ORDER_QUANTITY' ).
    lo_primitive_property->set_edm_name( 'OrderQuantity' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'Decimal' ) ##NO_TEXT.
    lo_primitive_property->set_precision( 15 ) ##NUMBER_OK.
    lo_primitive_property->set_scale( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'ORDER_QUANTITY_UNIT' ).
    lo_primitive_property->set_edm_name( 'OrderQuantityUnit' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'BASE_UNIT' ).
    lo_primitive_property->set_edm_name( 'BaseUnit' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 3 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SOLD_TO_PARTY' ).
    lo_primitive_property->set_edm_name( 'SoldToParty' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'DIVISION' ).
    lo_primitive_property->set_edm_name( 'Division' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 2 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_DOCUMENT_TYPE' ).
    lo_primitive_property->set_edm_name( 'SalesDocumentType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'DISTRIBUTION_CHANNEL' ).
    lo_primitive_property->set_edm_name( 'DistributionChannel' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 2 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SHIPPING_POINT' ).
    lo_primitive_property->set_edm_name( 'ShippingPoint' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'INDEPENDENT_REQUIREMENT_TY' ).
    lo_primitive_property->set_edm_name( 'IndependentRequirementType' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SDPROCESS_STATUS' ).
    lo_primitive_property->set_edm_name( 'SDProcessStatus' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 1 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_NAME' ).
    lo_primitive_property->set_edm_name( 'PlantName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 30 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PRODUCT_NAME' ).
    lo_primitive_property->set_edm_name( 'ProductName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 40 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CUSTOMER_NAME' ).
    lo_primitive_property->set_edm_name( 'CustomerName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 80 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_STREET' ).
    lo_primitive_property->set_edm_name( 'PlantStreet' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 60 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_CITY' ).
    lo_primitive_property->set_edm_name( 'PlantCity' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 40 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_POSTAL_CODE' ).
    lo_primitive_property->set_edm_name( 'PlantPostalCode' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_COUNTRY_NAME' ).
    lo_primitive_property->set_edm_name( 'PlantCountryName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 50 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_REGION_NAME' ).
    lo_primitive_property->set_edm_name( 'PlantRegionName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 20 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

  ENDMETHOD.


  METHOD def_sales_order_item_vhtype.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'SALES_ORDER_ITEM_VHTYPE'
                                    is_structure              = VALUE tys_sales_order_item_vhtype( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'SalesOrderItemVHType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'SALES_ORDER_ITEM_VH' ).
    lo_entity_set->set_edm_name( 'SalesOrderItemVH' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_DOCUMENT' ).
    lo_primitive_property->set_edm_name( 'SalesDocument' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_DOCUMENT_ITEM' ).
    lo_primitive_property->set_edm_name( 'SalesDocumentItem' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 6 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CUSTOMER' ).
    lo_primitive_property->set_edm_name( 'Customer' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PRODUCT_DESCRIPTION' ).
    lo_primitive_property->set_edm_name( 'ProductDescription' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 40 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

  ENDMETHOD.


  METHOD def_sales_order_vhtype.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'SALES_ORDER_VHTYPE'
                                    is_structure              = VALUE tys_sales_order_vhtype( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'SalesOrderVHType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'SALES_ORDER_VH' ).
    lo_entity_set->set_edm_name( 'SalesOrderVH' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'SALES_DOCUMENT' ).
    lo_primitive_property->set_edm_name( 'SalesDocument' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CUSTOMER' ).
    lo_primitive_property->set_edm_name( 'Customer' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'CUSTOMER_NAME' ).
    lo_primitive_property->set_edm_name( 'CustomerName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 80 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

  ENDMETHOD.
ENDCLASS.
