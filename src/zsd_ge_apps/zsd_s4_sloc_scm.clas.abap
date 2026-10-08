"! <p class="shorttext synchronized">Consumption model for client proxy - generated</p>
"! This class has been generated based on the metadata with namespace
"! <em>com.sap.gateway.srvd_a2x.zsd_sd_sloc.v0001</em>
CLASS zsd_s4_sloc_scm DEFINITION
  PUBLIC
  INHERITING FROM /iwbep/cl_v4_abs_pm_model_prov
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      "! <p class="shorttext synchronized">StorageLocationType</p>
      BEGIN OF tys_storage_location_type,
        "! <em>Key property</em> Plant
        plant               TYPE c LENGTH 4,
        "! <em>Key property</em> Storagelocation
        storagelocation     TYPE c LENGTH 4,
        "! Storagelocationname
        storagelocationname TYPE c LENGTH 16,
      END OF tys_storage_location_type,
      "! <p class="shorttext synchronized">List of StorageLocationType</p>
      tyt_storage_location_type TYPE STANDARD TABLE OF tys_storage_location_type WITH DEFAULT KEY.


    CONSTANTS:
      "! <p class="shorttext synchronized">Internal Names of the entity sets</p>
      BEGIN OF gcs_entity_set,
        "! StorageLocation
        "! <br/> Collection of type 'StorageLocationType'
        storage_location TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'STORAGE_LOCATION',
      END OF gcs_entity_set .

    CONSTANTS:
      "! <p class="shorttext synchronized">Internal names for entity types</p>
      BEGIN OF gcs_entity_type,
        "! <p class="shorttext synchronized">Internal names for StorageLocationType</p>
        "! See also structure type {@link ..tys_storage_location_type}
        BEGIN OF storage_location_type,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF storage_location_type,
      END OF gcs_entity_type.


    METHODS /iwbep/if_v4_mp_basic_pm~define REDEFINITION.


  PRIVATE SECTION.

    "! <p class="shorttext synchronized">Model</p>
    DATA mo_model TYPE REF TO /iwbep/if_v4_pm_model.


    "! <p class="shorttext synchronized">Define StorageLocationType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_storage_location_type RAISING /iwbep/cx_gateway.

ENDCLASS.



CLASS ZSD_S4_SLOC_SCM IMPLEMENTATION.


  METHOD /iwbep/if_v4_mp_basic_pm~define.

    mo_model = io_model.
    mo_model->set_schema_namespace( 'com.sap.gateway.srvd_a2x.zsd_sd_sloc.v0001' ) ##NO_TEXT.

    def_storage_location_type( ).

  ENDMETHOD.


  METHOD def_storage_location_type.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'STORAGE_LOCATION_TYPE'
                                    is_structure              = VALUE tys_storage_location_type( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'StorageLocationType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'STORAGE_LOCATION' ).
    lo_entity_set->set_edm_name( 'StorageLocation' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT' ).
    lo_primitive_property->set_edm_name( 'Plant' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'STORAGELOCATION' ).
    lo_primitive_property->set_edm_name( 'Storagelocation' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'STORAGELOCATIONNAME' ).
    lo_primitive_property->set_edm_name( 'Storagelocationname' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 16 ) ##NUMBER_OK.

  ENDMETHOD.
ENDCLASS.
