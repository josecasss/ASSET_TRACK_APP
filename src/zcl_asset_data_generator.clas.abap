CLASS zcl_asset_data_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_asset_seed,
             tag    TYPE c LENGTH 11,
             descr  TYPE c LENGTH 40,
             cc     TYPE bukrs,
             main   TYPE anln1,
             sub    TYPE anln2,
             status TYPE zde_asset_status,
           END OF ty_asset_seed.
    TYPES tt_asset_seed TYPE TABLE OF ty_asset_seed WITH EMPTY KEY.

    METHODS generate_statuses
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS generate_company_codes
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS generate_assets
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.

CLASS zcl_asset_data_generator IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== Asset Tracker Data Generator ===' ).
    generate_statuses( out ).
    generate_company_codes( out ).
    generate_assets( out ).
    out->write( '=== Done ===' ).
  ENDMETHOD.

  METHOD generate_statuses.
    DATA lt_status TYPE TABLE OF zasset_status WITH EMPTY KEY.
    lt_status = VALUE #(
      ( client = sy-mandt status_code = '00' status_description = 'Normal'                 )
      ( client = sy-mandt status_code = '01' status_description = 'Damaged'                )
      ( client = sy-mandt status_code = '02' status_description = 'Cost Center Mismatch'   )
      ( client = sy-mandt status_code = '03' status_description = 'Proposed for Write-Off' )
      ( client = sy-mandt status_code = '04' status_description = 'Sold'                   )
    ).
    DELETE FROM zasset_status.
    INSERT zasset_status FROM TABLE @lt_status.
    io_out->write( |Status codes: { sy-dbcnt } inserted| ).
  ENDMETHOD.

  METHOD generate_company_codes.
 " ── Company Codes ──────────────────────────────────────────
  DATA lt_cc TYPE TABLE OF zasset_compcode.
  lt_cc = VALUE #(
    " ==============================================================================
    " GRUPO 1: CORPORACIÓN ANDINA (Tu holding original)
    " ==============================================================================
    " Raíz — Holding
    ( company_code = '1000' parent_company_code = ''     company_name = 'Corporación Andina SAC'          country_key = 'PE' currency = 'PEN' )
    " Level 2 — Países
    ( company_code = '1100' parent_company_code = '1000' company_name = 'Operaciones Perú'                country_key = 'PE' currency = 'PEN' )
    ( company_code = '1200' parent_company_code = '1000' company_name = 'Andina Chile SpA'                country_key = 'CL' currency = 'CLP' )
    ( company_code = '1300' parent_company_code = '1000' company_name = 'Andina Colombia SAS'             country_key = 'CO' currency = 'COP' )
    " Level 3 — Regiones Perú
    ( company_code = '1110' parent_company_code = '1100' company_name = 'Sede Lima Metropolitana'         country_key = 'PE' currency = 'PEN' )
    ( company_code = '1120' parent_company_code = '1100' company_name = 'Sede Norte - Trujillo'           country_key = 'PE' currency = 'PEN' )
    ( company_code = '1130' parent_company_code = '1100' company_name = 'Sede Sur - Arequipa'             country_key = 'PE' currency = 'PEN' )
    ( company_code = '1140' parent_company_code = '1100' company_name = 'Sede Oriente - Iquitos'          country_key = 'PE' currency = 'PEN' )
    " Level 3 — Filiales regionales
    ( company_code = '1210' parent_company_code = '1200' company_name = 'Andina Chile - Santiago'         country_key = 'CL' currency = 'CLP' )
    ( company_code = '1310' parent_company_code = '1300' company_name = 'Andina Colombia - Bogotá'        country_key = 'CO' currency = 'COP' )

    " ==============================================================================
    " GRUPO 2: EUROATLANTIC HOLDINGS (Nuevo - Multi-moneda internacional)
    " ==============================================================================
    " Raíz — Holding EuroAtlantic (Basado en España/Europa pero opera en LATAM)
    ( company_code = '2000' parent_company_code = ''     company_name = 'EuroAtlantic Group SL'           country_key = 'ES' currency = 'EUR' )
    " Level 2 — Subsidiarias en Latinoamérica
    ( company_code = '2100' parent_company_code = '2000' company_name = 'EuroAtlantic Chile'               country_key = 'CL' currency = 'CLP' )
    ( company_code = '2200' parent_company_code = '2000' company_name = 'EuroAtlantic Perú'                country_key = 'PE' currency = 'PEN' )
    " Level 3 — Centros logísticos / Sedes operativas
    ( company_code = '2110' parent_company_code = '2100' company_name = 'EA Logística - Valparaíso'        country_key = 'CL' currency = 'CLP' )
    ( company_code = '2210' parent_company_code = '2200' company_name = 'EA Planta - Callao'               country_key = 'PE' currency = 'PEN' )

    " ==============================================================================
    " GRUPO 3: ATLÁNTICA INDUSTRIAL (Nuevo - Enfoque industrial brasileño)
    " ==============================================================================
    " Raíz — Holding Atlántica (Brasil)
    ( company_code = '3000' parent_company_code = ''     company_name = 'Atlántica Industrias S.A.'        country_key = 'BR' currency = 'BRL' )
    " Level 2 — Expansión Pacífico
    ( company_code = '3100' parent_company_code = '3000' company_name = 'Atlántica del Pacífico Ltda'      country_key = 'CL' currency = 'CLP' )
    ( company_code = '3200' parent_company_code = '3000' company_name = 'Atlántica Colombia Op.'          country_key = 'CO' currency = 'COP' )
    " Level 3 — Plantas de Manufactura
    ( company_code = '3110' parent_company_code = '3100' company_name = 'Planta Metalúrgica Concepción'    country_key = 'CL' currency = 'CLP' )
    ( company_code = '3210' parent_company_code = '3200' company_name = 'Complejo Industrial Medellín'    country_key = 'CO' currency = 'COP' )
  ).

  DELETE FROM zasset_compcode.
  INSERT zasset_compcode FROM TABLE @lt_cc.
    io_out->write( |Company codes: { sy-dbcnt } inserted| ).
  ENDMETHOD.

  METHOD generate_assets.
    DATA lt_assets  TYPE TABLE OF zassetfc        WITH EMPTY KEY.
    DATA lt_history TYPE TABLE OF zassethistoryfc WITH EMPTY KEY.
    DATA lt_seed    TYPE tt_asset_seed.
    DATA ls_asset   TYPE zassetfc.
    DATA ls_history TYPE zassethistoryfc.
    DATA lv_now     TYPE timestampl.

    GET TIME STAMP FIELD lv_now.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    lt_seed = VALUE #(
      ( tag = 'TAG-0000001' descr = 'Laptop Dell XPS 15'           cc = '2100' main = '000001' sub = '0000' status = '00' )
      ( tag = 'TAG-0000002' descr = 'HP LaserJet Printer'           cc = '2100' main = '000002' sub = '0000' status = '00' )
      ( tag = 'TAG-0000003' descr = 'Cisco Network Switch 48P'      cc = '2100' main = '000003' sub = '0000' status = '01' )
      ( tag = 'TAG-0000004' descr = 'iPhone 14 Pro - IT Mgr'        cc = '2100' main = '000004' sub = '0000' status = '00' )
      ( tag = 'TAG-0000005' descr = 'Office Desk 180cm Oak'         cc = '2200' main = '000005' sub = '0000' status = '00' )
      ( tag = 'TAG-0000006' descr = 'Ergonomic Chair Herman Miller'  cc = '2200' main = '000006' sub = '0000' status = '02' )
      ( tag = 'TAG-0000007' descr = 'Dell PowerEdge Server R750'    cc = '2200' main = '000007' sub = '0000' status = '00' )
      ( tag = 'TAG-0000008' descr = 'Forklift Toyota 3T'            cc = '2300' main = '000008' sub = '0000' status = '03' )
      ( tag = 'TAG-0000009' descr = 'IP Security Camera System'     cc = '2300' main = '000009' sub = '0000' status = '00' )
      ( tag = 'TAG-0000010' descr = 'Conference Display 86in 4K'    cc = '1100' main = '000010' sub = '0000' status = '04' )
    ).

    LOOP AT lt_seed ASSIGNING FIELD-SYMBOL(<s>).
      TRY.
          DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
          CONTINUE.
      ENDTRY.

      CLEAR ls_asset.
      ls_asset-client                = sy-mandt.
      ls_asset-uuid                  = lv_uuid.
      ls_asset-asset_tag_number      = <s>-tag.
      ls_asset-asset_description     = <s>-descr.
      ls_asset-company_code          = <s>-cc.
      ls_asset-main_asset_number     = <s>-main.
      ls_asset-asset_sub_number      = <s>-sub.
      ls_asset-status                = <s>-status.
      ls_asset-creation_date         = lv_date.
      ls_asset-changed_date          = lv_date.
      ls_asset-local_created_by      = lv_user.
      ls_asset-local_created_at      = lv_now.
      ls_asset-local_last_changed_by = lv_user.
      ls_asset-local_last_changed_at = lv_now.
      ls_asset-last_changed_at       = lv_now.
      APPEND ls_asset TO lt_assets.

      IF <s>-status <> '00'.
        CLEAR ls_history.
        TRY.
            ls_history-uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            CONTINUE.
        ENDTRY.
        ls_history-client          = sy-mandt.
        ls_history-parent_uuid     = lv_uuid.
        ls_history-his_id          = '00000001'.
        ls_history-previous_status = '00'.
        ls_history-new_status      = <s>-status.
        ls_history-text000         = 'Seeded by data generator'.
        APPEND ls_history TO lt_history.
      ENDIF.
    ENDLOOP.

    DELETE FROM zassethistoryfc.
    DELETE FROM zassetfc.
    INSERT zassetfc        FROM TABLE @lt_assets.
    io_out->write( |Assets:  { sy-dbcnt } inserted| ).
    INSERT zassethistoryfc FROM TABLE @lt_history.
    io_out->write( |History: { sy-dbcnt } inserted| ).
  ENDMETHOD.

ENDCLASS.
