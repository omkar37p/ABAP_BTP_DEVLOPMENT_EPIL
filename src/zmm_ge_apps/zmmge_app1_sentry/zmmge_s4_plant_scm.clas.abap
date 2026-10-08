"! <p class="shorttext synchronized">Consumption model for client proxy - generated</p>
"! This class has been generated based on the metadata with namespace
"! <em>YY1_PLANT_VH_CDS</em>
CLASS zmmge_s4_plant_scm DEFINITION
  PUBLIC
  INHERITING FROM /iwbep/cl_v4_abs_pm_model_prov
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      "! <p class="shorttext synchronized">YY1_PLANT_VHType</p>
      BEGIN OF tys_yy_1_plant_vhtype,
        "! <em>Key property</em> Plant
        plant      TYPE c LENGTH 4,
        "! PlantName
        plant_name TYPE c LENGTH 30,
      END OF tys_yy_1_plant_vhtype,
      "! <p class="shorttext synchronized">List of YY1_PLANT_VHType</p>
      tyt_yy_1_plant_vhtype TYPE STANDARD TABLE OF tys_yy_1_plant_vhtype WITH DEFAULT KEY.


    CONSTANTS:
      "! <p class="shorttext synchronized">Internal Names of the entity sets</p>
      BEGIN OF gcs_entity_set,
        "! YY1_PLANT_VH
        "! <br/> Collection of type 'YY1_PLANT_VHType'
        yy_1_plant_vh TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'YY_1_PLANT_VH',
      END OF gcs_entity_set .

    CONSTANTS:
      "! <p class="shorttext synchronized">Internal names for entity types</p>
      BEGIN OF gcs_entity_type,
        "! <p class="shorttext synchronized">Internal names for YY1_PLANT_VHType</p>
        "! See also structure type {@link ..tys_yy_1_plant_vhtype}
        BEGIN OF yy_1_plant_vhtype,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF yy_1_plant_vhtype,
      END OF gcs_entity_type.


    METHODS /iwbep/if_v4_mp_basic_pm~define REDEFINITION.


  PRIVATE SECTION.

    "! <p class="shorttext synchronized">Model</p>
    DATA mo_model TYPE REF TO /iwbep/if_v4_pm_model.


    "! <p class="shorttext synchronized">Define YY1_PLANT_VHType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_yy_1_plant_vhtype RAISING /iwbep/cx_gateway.

ENDCLASS.



CLASS ZMMGE_S4_PLANT_SCM IMPLEMENTATION.


  METHOD /iwbep/if_v4_mp_basic_pm~define.

    mo_model = io_model.
    mo_model->set_schema_namespace( 'YY1_PLANT_VH_CDS' ) ##NO_TEXT.

    def_yy_1_plant_vhtype( ).

  ENDMETHOD.


  METHOD def_yy_1_plant_vhtype.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'YY_1_PLANT_VHTYPE'
                                    is_structure              = VALUE tys_yy_1_plant_vhtype( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'YY1_PLANT_VHType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'YY_1_PLANT_VH' ).
    lo_entity_set->set_edm_name( 'YY1_PLANT_VH' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT' ).
    lo_primitive_property->set_edm_name( 'Plant' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 4 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'PLANT_NAME' ).
    lo_primitive_property->set_edm_name( 'PlantName' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 30 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

  ENDMETHOD.
ENDCLASS.
