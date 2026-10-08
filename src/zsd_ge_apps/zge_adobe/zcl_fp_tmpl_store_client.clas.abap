CLASS zcl_fp_tmpl_store_client DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA:
      mo_http_destination TYPE REF TO if_http_destination,
      mv_client           TYPE REF TO if_web_http_client.
    TYPES :
      BEGIN OF ty_schema_body,
        xsd_Schema  TYPE xstring,
        schema_Name TYPE c LENGTH 30,
        note        TYPE c LENGTH 280,
      END OF ty_schema_body,
      BEGIN OF ty_schema_body_in,
        xsd_Schema  TYPE string,
        schema_Name TYPE c LENGTH 30,
        note        TYPE c LENGTH 280,
      END OF ty_schema_body_in,
      BEGIN OF ty_template_body,
        xdp_Template        TYPE xstring,
        template_Name       TYPE c LENGTH 30,
        description         TYPE c LENGTH 280,
        note                TYPE c LENGTH 280,
        locale              TYPE c LENGTH 6,
        language            TYPE c LENGTH 280,
        master_Language     TYPE c LENGTH 280,
        business_Area       TYPE c LENGTH 280,
        business_Department TYPE c LENGTH 280,
      END OF ty_template_body,
      BEGIN OF ty_template_body_in,
        xdp_Template        TYPE string,
        template_Name       TYPE c LENGTH 30,
        description         TYPE c LENGTH 280,
        note                TYPE c LENGTH 280,
        locale              TYPE c LENGTH 6,
        language            TYPE c LENGTH 280,
        master_Language     TYPE c LENGTH 280,
        business_Area       TYPE c LENGTH 280,
        business_Department TYPE c LENGTH 280,
      END OF ty_template_body_in,
      tt_templates TYPE STANDARD TABLE OF ty_template_body WITH KEY template_Name,
      BEGIN OF ty_form_body,
        form_Name   TYPE c LENGTH 30,
        description TYPE c LENGTH 280,
        note        TYPE c LENGTH 30,
      END OF ty_form_body,
      tt_forms TYPE STANDARD TABLE OF ty_form_body WITH KEY form_Name,
      BEGIN OF ty_version_history,
        version_Object_Id      TYPE string,
        version_Number         TYPE string,
        is_Latest_Version      TYPE abap_boolean,
        last_Modification_Date TYPE string,
      END OF ty_version_history,
      tt_versions TYPE STANDARD TABLE OF ty_version_history WITH KEY version_object_id.
    METHODS:
      constructor
        IMPORTING
          iv_name                  TYPE string
          iv_service_instance_name TYPE string
        RAISING
          zcx_fp_tmpl_store_error,
      list_forms
        IMPORTING
                  iv_limit        TYPE i DEFAULT 10
                  iv_offset       TYPE i DEFAULT 0
        RETURNING VALUE(rt_forms) TYPE tt_forms
        RAISING
                  zcx_fp_tmpl_store_error,
      get_form_by_name
        IMPORTING
                  iv_name        TYPE string
        RETURNING VALUE(rs_form) TYPE ty_form_body
        RAISING
                  zcx_fp_tmpl_store_error,
      list_templates
        IMPORTING
                  iv_form_name           TYPE string
                  iv_locale              TYPE string OPTIONAL
                  iv_language            TYPE string OPTIONAL
                  iv_template_name       TYPE string OPTIONAL
                  iv_master_language     TYPE string OPTIONAL
                  iv_business_area       TYPE string OPTIONAL
                  iv_business_department TYPE string OPTIONAL
                  iv_limit               TYPE i DEFAULT 10
                  iv_offset              TYPE i DEFAULT 0
        RETURNING VALUE(rt_templates)    TYPE tt_templates
        RAISING
                  zcx_fp_tmpl_store_error,
      get_template_history_by_name
        IMPORTING
                  iv_form_name       TYPE string
                  iv_template_name   TYPE string
        RETURNING VALUE(rt_versions) TYPE tt_versions
        RAISING
                  zcx_fp_tmpl_store_error,
      get_template_by_name
        IMPORTING
                  iv_get_binary      TYPE abap_boolean DEFAULT abap_false
                  iv_form_name       TYPE string
                  iv_template_name   TYPE string
        RETURNING VALUE(rs_template) TYPE ty_template_body
        RAISING
                  zcx_fp_tmpl_store_error,
      get_template_by_id
        IMPORTING
                  iv_form_name       TYPE string
                  iv_object_id       TYPE string
        RETURNING VALUE(rs_template) TYPE ty_template_body
        RAISING
                  zcx_fp_tmpl_store_error,
      get_schema_history_by_name
        IMPORTING
                  iv_form_name       TYPE string
        RETURNING VALUE(rt_versions) TYPE tt_versions
        RAISING
                  zcx_fp_tmpl_store_error,
      get_schema_by_name
        IMPORTING
                  iv_get_binary    TYPE abap_boolean DEFAULT abap_false
                  iv_form_name     TYPE string
        RETURNING VALUE(rs_schema) TYPE ty_schema_body
        RAISING
                  zcx_fp_tmpl_store_error,
      get_schema_by_id
        IMPORTING
                  iv_form_name     TYPE string
                  iv_object_id     TYPE string
        RETURNING VALUE(rs_schema) TYPE ty_schema_body
        RAISING
                  zcx_fp_tmpl_store_error,
      set_form
        IMPORTING
          iv_form_name TYPE string
          is_form      TYPE ty_form_body
        RAISING
          zcx_fp_tmpl_store_error,
      set_template
        IMPORTING
          iv_template_name TYPE string
          iv_form_name     TYPE string
          is_template      TYPE ty_template_body
        RAISING
          zcx_fp_tmpl_store_error,
      set_schema
        IMPORTING
          iv_form_name TYPE string
          is_data      TYPE ty_schema_body
        RAISING
          zcx_fp_tmpl_store_error,
      delete_form
        IMPORTING
          iv_form_name TYPE string
        RAISING
          zcx_fp_tmpl_store_error,
      delete_template_in_form
        IMPORTING
          iv_form_name     TYPE string
          iv_template_name TYPE string
        RAISING
          zcx_fp_tmpl_store_error,
      delete_schema_in_form
        IMPORTING
          iv_form_name TYPE string
        RAISING
          zcx_fp_tmpl_store_error.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      __get_request
        RETURNING VALUE(ro_request) TYPE REF TO if_web_http_request,
      __json2abap
        IMPORTING
          ir_input_data TYPE data
        CHANGING
          cr_abap_data  TYPE data,
      __execute
        IMPORTING
                  i_method           TYPE if_web_http_client=>method
                  i_expect           TYPE i DEFAULT 200
        RETURNING VALUE(ro_response) TYPE REF TO if_web_http_response
        RAISING
                  zcx_fp_tmpl_store_error.
ENDCLASS.



CLASS ZCL_FP_TMPL_STORE_CLIENT IMPLEMENTATION.


  METHOD constructor.
    TRY.
        mo_http_destination = cl_http_destination_provider=>create_by_comm_arrangement(
                                    comm_scenario  = 'ZADS_CS'
                                    service_id     = 'ZADS_OUT_REST'
                                  ).
        mv_client = cl_web_http_client_manager=>create_by_http_destination( mo_http_destination ).

        " BTP: the FIRST request of a new client is always refused (403),
        " whatever it asks for; every later request works (tested
        " 2026-10-08: same template OK as 2nd call, 403 as 1st call).
        " So send one throw-away request here; its result is ignored.
        TRY.
            mv_client->get_http_request( )->set_uri_path( |/v1/forms/ZZ_PRIME| ).
            mv_client->execute( if_web_http_client=>get ).
          CATCH cx_web_http_client_error.
            " ignore: only primes the connection
        ENDTRY.
      CATCH
        cx_web_http_client_error
        cx_http_dest_provider_error .
        RAISE EXCEPTION TYPE zcx_fp_tmpl_store_error
          EXPORTING
            textid = zcx_fp_tmpl_store_error=>setup_not_complete.
    ENDTRY.
  ENDMETHOD.


  METHOD delete_form.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms/{ iv_form_name }| ).
    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>delete
      i_expect = 200
    ).
  ENDMETHOD.


  METHOD delete_schema_in_form.
    DATA(ls_schema) = me->get_schema_by_name(
      iv_form_name = iv_form_name
      iv_get_binary = abap_false
    ).

    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/schema/{ ls_schema-schema_name }| ).
    lo_request->set_query( |allVersions=true| ).
    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>delete
      i_expect = 200
    ).
  ENDMETHOD.


  METHOD delete_template_in_form.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms/{ iv_form_name }| ).
    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>delete
      i_expect = 200
    ).
  ENDMETHOD.


  METHOD get_form_by_name.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms/{ iv_name }| ).
    lo_request->set_query( |formData| ).
    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA lr_data TYPE REF TO data.
    lr_data = /ui2/cl_json=>generate(
      json = lo_response->get_text( )
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    IF lr_data IS BOUND.
      ASSIGN lr_data->* TO FIELD-SYMBOL(<data>).
      __json2abap(
        EXPORTING
          ir_input_data = <data>
        CHANGING
          cr_abap_data = rs_form
      ).

    ENDIF.
  ENDMETHOD.


  METHOD get_schema_by_id.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/schema/{ iv_object_id }| ).
    lo_request->set_query( |select=xsdSchema,schemaData&isObjectId=true| ).

    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data TYPE REF TO data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    IF lr_data IS BOUND.
      ASSIGN lr_data->* TO FIELD-SYMBOL(<data>).
      __json2abap(
        EXPORTING
          ir_input_data = <data>
        CHANGING
          cr_abap_data = rs_schema
      ).
    ENDIF.
  ENDMETHOD.


  METHOD get_schema_by_name.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms/{ iv_form_name }| ).
    IF iv_get_binary = abap_true.
      lo_request->set_query( |select=schemaData,xsdSchema| ).
    ELSE.
      lo_request->set_query( |select=schemaData| ).
    ENDIF.

    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data TYPE REF TO data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    IF lr_data IS BOUND.
      ASSIGN lr_data->* TO FIELD-SYMBOL(<data>).

      ASSIGN COMPONENT 'SCHEMA' OF STRUCTURE <data> TO FIELD-SYMBOL(<schema>).

      IF <schema> IS ASSIGNED.
        __json2abap(
          EXPORTING
            ir_input_data = <schema>->*
          CHANGING
            cr_abap_data = rs_schema
        ).
      ELSE.
        RAISE EXCEPTION TYPE zcx_fp_tmpl_store_error
          EXPORTING
            mv_http_status_code = 404
            mv_http_reason      = 'No schema maintained for form'
            textid              = zcx_fp_tmpl_store_error=>data_error.
      ENDIF.

    ENDIF.
  ENDMETHOD.


  METHOD get_schema_history_by_name.
    DATA(ls_schema) = me->get_schema_by_name(
      iv_form_name = iv_form_name
      iv_get_binary = abap_false
    ).
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/schema/{ ls_schema-schema_name }| ).
    lo_request->set_query( |select=schemaData,schemaVersions| ).

    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data TYPE REF TO data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    IF lr_data IS BOUND.
      FIELD-SYMBOLS: <versions> TYPE STANDARD TABLE.

      ASSIGN lr_data->* TO FIELD-SYMBOL(<data>).
      ASSIGN COMPONENT `VERSIONS` OF STRUCTURE <data> TO <versions>.

      LOOP AT <versions> ASSIGNING FIELD-SYMBOL(<version>).
        DATA ls_version TYPE ty_version_history.

        __json2abap(
          EXPORTING
            ir_input_data = <version>->*
          CHANGING
            cr_abap_data = ls_version
        ).

        APPEND ls_version TO rt_versions.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.


  METHOD get_template_by_id.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/templates/{ iv_object_id }| ).
    lo_request->set_query( |select=xdpTemplate,templateData&isObjectId=true| ).

    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data TYPE REF TO data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    IF lr_data IS BOUND.
      ASSIGN lr_data->* TO FIELD-SYMBOL(<data>).
      __json2abap(
          EXPORTING
            ir_input_data = <data>->*
          CHANGING
            cr_abap_data = rs_template
      ).
    ENDIF.
  ENDMETHOD.


  METHOD get_template_by_name.

    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/templates/{ iv_template_name }| ).
    IF iv_get_binary = abap_true.
      lo_request->set_query( |select=xdpTemplate,templateData| ).
    ELSE.
      lo_request->set_query( |select=templateData| ).
    ENDIF.
    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data TYPE REF TO data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    IF lr_data IS BOUND.
      ASSIGN lr_data->* TO FIELD-SYMBOL(<data>).
      __json2abap(
          EXPORTING
            ir_input_data = <data>
          CHANGING
            cr_abap_data = rs_template
      ).
    ENDIF.

  ENDMETHOD.


  METHOD get_template_history_by_name.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/templates/{ iv_template_name }| ).
    lo_request->set_query( |select=templateData,templateVersions| ).

    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data TYPE REF TO data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    IF lr_data IS BOUND.
      FIELD-SYMBOLS: <versions> TYPE STANDARD TABLE.

      ASSIGN lr_data->* TO FIELD-SYMBOL(<data>).
      ASSIGN COMPONENT `VERSIONS` OF STRUCTURE <data> TO <versions>.

      LOOP AT <versions> ASSIGNING FIELD-SYMBOL(<version>).
        DATA ls_version TYPE ty_version_history.

        __json2abap(
          EXPORTING
            ir_input_data = <version>->*
          CHANGING
            cr_abap_data = ls_version
        ).

        APPEND ls_version TO rt_versions.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.


  METHOD list_forms.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( |/v1/forms| ).
    lo_request->set_query( |limit={ iv_limit }&offset={ iv_offset }&select=formData| ).

    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data TYPE REF TO data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    IF lr_data IS BOUND.
      FIELD-SYMBOLS:
         <data> TYPE ANY TABLE.

      ASSIGN lr_data->* TO <data>.

      LOOP AT <data> ASSIGNING FIELD-SYMBOL(<form>).
        DATA ls_form TYPE ty_form_body.

        __json2abap(
          EXPORTING
            ir_input_data = <form>->*
          CHANGING
            cr_abap_data = ls_form
        ).

        APPEND ls_form TO rt_forms.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD list_templates.
    DATA(lo_request) = __get_request( ).
    DATA(lv_query) = |select=templateData&limit={ iv_limit }&offset={ iv_offset }|.
    IF iv_business_area IS NOT INITIAL.
      lv_query = lv_query && |&businessArea={ iv_business_area }|.
    ENDIF.

    IF iv_business_department IS NOT INITIAL.
      lv_query = lv_query && |&businessDepartment={ iv_business_department }|.
    ENDIF.

    IF iv_language IS NOT INITIAL.
      lv_query = lv_query && |&language={ iv_language }|.
    ENDIF.

    IF iv_locale IS NOT INITIAL.
      lv_query = lv_query && |&locale={ iv_locale }|.
    ENDIF.

    IF iv_master_language IS NOT INITIAL.
      lv_query = lv_query && |&masterLanguage={ iv_master_language }|.
    ENDIF.

    IF iv_template_name IS NOT INITIAL.
      lv_query = lv_query && |&templateName={ iv_template_name }|.
    ENDIF.

    lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/templates| ).
    lo_request->set_query( |limit={ iv_limit }&offset={ iv_offset }&select=formData| ).

    DATA(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data TYPE REF TO data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    IF lr_data IS BOUND.
      FIELD-SYMBOLS: <data> TYPE ANY TABLE.

      ASSIGN lr_data->* TO <data>.

      LOOP AT <data> ASSIGNING FIELD-SYMBOL(<template>).
        DATA ls_template TYPE ty_template_body.

        __json2abap(
          EXPORTING
            ir_input_data = <template>->*
          CHANGING
            cr_abap_data = ls_template
        ).

        APPEND ls_template TO rt_templates.

      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD set_form.
    DATA(lv_exists) = abap_false.

    TRY.
        me->get_form_by_name( iv_name = iv_form_name ).
        lv_exists = abap_true.
      CATCH zcx_fp_tmpl_store_error INTO DATA(lo_data_error).
        IF lo_data_error->mv_http_status_code <> 404.
          RAISE EXCEPTION lo_data_error.
        ENDIF.
    ENDTRY.

    DATA(lo_request) = __get_request( ).
    IF lv_exists = abap_true.
      lo_request->set_uri_path( |/v1/forms/{ iv_form_name }| ).
    ELSE.
      lo_request->set_uri_path( |/v1/forms| ).
    ENDIF.

    DATA(lv_json) = /ui2/cl_json=>serialize(
      data = is_form
      compress = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    lo_request->append_text(
        EXPORTING
          data   = lv_json
    ).

    IF lv_exists = abap_true.
      __execute(
        i_method = if_web_http_client=>put
      ).
    ELSE.
      __execute(
        i_method = if_web_http_client=>post
      ).
    ENDIF.
  ENDMETHOD.


  METHOD set_schema.
    DATA(lv_exists) = abap_false.

    TRY.
        DATA(ls_schema) = me->get_schema_by_name(
          iv_form_name = iv_form_name
          iv_get_binary = abap_false
        ).
        lv_exists = abap_true.
      CATCH zcx_fp_tmpl_store_error INTO DATA(lo_data_error).
        IF lo_data_error->mv_http_status_code <> 404.
          RAISE EXCEPTION lo_data_error.
        ENDIF.
    ENDTRY.

    DATA(lo_request) = __get_request( ).
    IF lv_exists = abap_true.
      lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/schema/{ ls_schema-schema_name }| ).
    ELSE.
      lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/schema| ).
    ENDIF.

    DATA(ls_body) = VALUE ty_schema_body_in(
      note = is_data-note
      schema_name = is_data-schema_name
      xsd_schema = cl_web_http_utility=>encode_base64( cl_web_http_utility=>decode_utf8( is_data-xsd_schema ) )
    ).

    DATA(lv_json) = /ui2/cl_json=>serialize(
      data = ls_body
      compress = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    lo_request->append_text(
        EXPORTING
          data   = lv_json
    ).

    IF lv_exists = abap_true.
      __execute(
        i_method = if_web_http_client=>put
      ).
    ELSE.
      __execute(
        i_method = if_web_http_client=>post
      ).
    ENDIF.
  ENDMETHOD.


  METHOD set_template.
    DATA(lv_exists) = abap_false.

    TRY.
        DATA(lv_template) = me->get_template_by_name(
          iv_form_name = iv_form_name
          iv_get_binary = abap_false
          iv_template_name = iv_template_name
        ).
        lv_exists = abap_true.
      CATCH zcx_fp_tmpl_store_error INTO DATA(lo_data_error).
        IF lo_data_error->mv_http_status_code <> 404.
          RAISE EXCEPTION lo_data_error.
        ENDIF.
    ENDTRY.

    DATA(lo_request) = __get_request( ).
    IF lv_exists = abap_true.
      lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/templates/{ iv_template_name }| ).
    ELSE.
      lo_request->set_uri_path( |/v1/forms/{ iv_form_name }/templates| ).
    ENDIF.

    DATA(ls_body) = VALUE ty_template_body_in(
      note = is_template-note
      business_area = is_template-business_area
      business_department = is_template-business_department
      description = is_template-description
      language = is_template-language
      locale = is_template-locale
      master_language = is_template-master_language
      template_name = is_template-template_name
      xdp_template = cl_web_http_utility=>encode_base64( cl_web_http_utility=>decode_utf8( is_template-xdp_template ) )
    ).

    DATA(lv_json) = /ui2/cl_json=>serialize(
      data = ls_body
      compress = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    lo_request->append_text(
        EXPORTING
          data   = lv_json
    ).

    IF lv_exists = abap_true.
      __execute(
        i_method = if_web_http_client=>put
      ).
    ELSE.
      __execute(
        i_method = if_web_http_client=>post
      ).
    ENDIF.
  ENDMETHOD.


  METHOD __execute.
    TRY.
        ro_response = mv_client->execute( i_method = i_method ).
        IF ro_response->get_status(  )-code <> i_expect.
          RAISE EXCEPTION TYPE zcx_fp_tmpl_store_error
            EXPORTING
              textid              = zcx_fp_tmpl_store_error=>data_error
              mv_http_status_code = ro_response->get_status( )-code
              mv_http_reason      = ro_response->get_status( )-reason.
        ENDIF.
      CATCH cx_web_http_client_error INTO DATA(lo_http_error).
        RAISE EXCEPTION TYPE zcx_fp_tmpl_store_error
          EXPORTING
            textid         = zcx_fp_tmpl_store_error=>http_client_error
            mv_http_reason = lo_http_error->get_longtext( ).
    ENDTRY.
  ENDMETHOD.


  METHOD __get_request.
    ro_request = mv_client->get_http_request( ).
    ro_request->set_header_fields( VALUE #(
      ( name = 'Accept' value = 'application/json, text/plain, */*'  )
      ( name = 'Content-Type' value = 'application/json;charset=utf-8'  )
    ) ).
  ENDMETHOD.


  METHOD __json2abap.
    DATA(lo_input_struct)   = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = ir_input_data ) ).
    DATA(lo_target_struct)  = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = cr_abap_data ) ).


    LOOP AT lo_input_struct->components ASSIGNING FIELD-SYMBOL(<ls_component>).
      IF line_exists( lo_target_struct->components[ name = <ls_component>-name ] ).
        ASSIGN COMPONENT <ls_component>-name OF STRUCTURE ir_input_data TO FIELD-SYMBOL(<field_in_data>).
        ASSIGN COMPONENT <ls_component>-name OF STRUCTURE cr_abap_data TO FIELD-SYMBOL(<field_out_data>).

        IF lo_target_struct->components[ name = <ls_component>-name ]-type_kind = cl_abap_typedescr=>typekind_xstring.
          <field_out_data> = cl_web_http_utility=>decode_x_base64( <field_in_data>->* ).
        ELSE.
          <field_out_data> = <field_in_data>->*.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

