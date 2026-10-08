"! <p class="shorttext synchronized">Consumption model for client proxy - generated</p>
"! This class has been generated based on the metadata with namespace
"! <em>cds_zsd_sd_bp_ztrp</em>
CLASS zsd_s4_bpztrp_scm DEFINITION
  PUBLIC
  INHERITING FROM /iwbep/cl_v4_abs_pm_model_prov
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      "! <p class="shorttext synchronized">TransporterType</p>
      BEGIN OF tys_transporter_type,
        "! <em>Key property</em> Transporterid
        transporterid   TYPE c LENGTH 10,
        "! Transportername
        transportername TYPE c LENGTH 81,
      END OF tys_transporter_type,
      "! <p class="shorttext synchronized">List of TransporterType</p>
      tyt_transporter_type TYPE STANDARD TABLE OF tys_transporter_type WITH DEFAULT KEY.


    CONSTANTS:
      "! <p class="shorttext synchronized">Internal Names of the entity sets</p>
      BEGIN OF gcs_entity_set,
        "! Transporter
        "! <br/> Collection of type 'TransporterType'
        transporter TYPE /iwbep/if_cp_runtime_types=>ty_entity_set_name VALUE 'TRANSPORTER',
      END OF gcs_entity_set .

    CONSTANTS:
      "! <p class="shorttext synchronized">Internal names for entity types</p>
      BEGIN OF gcs_entity_type,
        "! <p class="shorttext synchronized">Internal names for TransporterType</p>
        "! See also structure type {@link ..tys_transporter_type}
        BEGIN OF transporter_type,
          "! <p class="shorttext synchronized">Navigation properties</p>
          BEGIN OF navigation,
            "! Dummy field - Structure must not be empty
            dummy TYPE int1 VALUE 0,
          END OF navigation,
        END OF transporter_type,
      END OF gcs_entity_type.


    METHODS /iwbep/if_v4_mp_basic_pm~define REDEFINITION.


  PRIVATE SECTION.

    "! <p class="shorttext synchronized">Model</p>
    DATA mo_model TYPE REF TO /iwbep/if_v4_pm_model.


    "! <p class="shorttext synchronized">Define TransporterType</p>
    "! @raising /iwbep/cx_gateway | <p class="shorttext synchronized">Gateway Exception</p>
    METHODS def_transporter_type RAISING /iwbep/cx_gateway.

ENDCLASS.



CLASS ZSD_S4_BPZTRP_SCM IMPLEMENTATION.


  METHOD /iwbep/if_v4_mp_basic_pm~define.

    mo_model = io_model.
    mo_model->set_schema_namespace( 'cds_zsd_sd_bp_ztrp' ) ##NO_TEXT.

    def_transporter_type( ).

  ENDMETHOD.


  METHOD def_transporter_type.

    DATA:
      lo_complex_property    TYPE REF TO /iwbep/if_v4_pm_cplx_prop,
      lo_entity_type         TYPE REF TO /iwbep/if_v4_pm_entity_type,
      lo_entity_set          TYPE REF TO /iwbep/if_v4_pm_entity_set,
      lo_navigation_property TYPE REF TO /iwbep/if_v4_pm_nav_prop,
      lo_primitive_property  TYPE REF TO /iwbep/if_v4_pm_prim_prop.


    lo_entity_type = mo_model->create_entity_type_by_struct(
                                    iv_entity_type_name       = 'TRANSPORTER_TYPE'
                                    is_structure              = VALUE tys_transporter_type( )
                                    iv_do_gen_prim_props         = abap_true
                                    iv_do_gen_prim_prop_colls    = abap_true
                                    iv_do_add_conv_to_prim_props = abap_true ).

    lo_entity_type->set_edm_name( 'TransporterType' ) ##NO_TEXT.


    lo_entity_set = lo_entity_type->create_entity_set( 'TRANSPORTER' ).
    lo_entity_set->set_edm_name( 'Transporter' ) ##NO_TEXT.


    lo_primitive_property = lo_entity_type->get_primitive_property( 'TRANSPORTERID' ).
    lo_primitive_property->set_edm_name( 'Transporterid' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 10 ) ##NUMBER_OK.
    lo_primitive_property->set_is_key( ).

    lo_primitive_property = lo_entity_type->get_primitive_property( 'TRANSPORTERNAME' ).
    lo_primitive_property->set_edm_name( 'Transportername' ) ##NO_TEXT.
    lo_primitive_property->set_edm_type( 'String' ) ##NO_TEXT.
    lo_primitive_property->set_max_length( 81 ) ##NUMBER_OK.
    lo_primitive_property->set_is_nullable( ).

  ENDMETHOD.
ENDCLASS.
