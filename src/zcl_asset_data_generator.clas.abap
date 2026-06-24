CLASS zcl_asset_data_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_asset_seed,
             descr   TYPE c LENGTH 40,
             cc      TYPE bukrs,
             main    TYPE anln1,
             sub     TYPE anln2,
             cst_ctr TYPE kostl,
             inv_num TYPE c LENGTH 25,
             status  TYPE zde_asset_status,
           END OF ty_asset_seed.
    TYPES tt_asset_seed TYPE TABLE OF ty_asset_seed WITH EMPTY KEY.

    METHODS generate_statuses       IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS generate_company_codes  IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS generate_cost_centers   IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS generate_inv_numbers    IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS generate_assets         IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.
ENDCLASS.

CLASS zcl_asset_data_generator IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== Asset Tracker Data Generator ===' ).
    generate_statuses(      out ).
    generate_company_codes( out ).
    generate_cost_centers(  out ).
    generate_inv_numbers(   out ).
    generate_assets(        out ).
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
    io_out->write( |Statuses:      { sy-dbcnt } inserted| ).
  ENDMETHOD.

  METHOD generate_company_codes.
    DATA lt_cc TYPE TABLE OF zasset_compcode.
    lt_cc = VALUE #(
      ( company_code = '1000' parent_company_code = ''     company_name = 'Corporación Andina SAC'          country_key = 'PE' currency = 'PEN' )
      ( company_code = '1100' parent_company_code = '1000' company_name = 'Operaciones Perú'                country_key = 'PE' currency = 'PEN' )
      ( company_code = '1200' parent_company_code = '1000' company_name = 'Andina Chile SpA'                country_key = 'CL' currency = 'CLP' )
      ( company_code = '1300' parent_company_code = '1000' company_name = 'Andina Colombia SAS'             country_key = 'CO' currency = 'COP' )
      ( company_code = '1110' parent_company_code = '1100' company_name = 'Sede Lima Metropolitana'         country_key = 'PE' currency = 'PEN' )
      ( company_code = '1120' parent_company_code = '1100' company_name = 'Sede Norte - Trujillo'           country_key = 'PE' currency = 'PEN' )
      ( company_code = '1130' parent_company_code = '1100' company_name = 'Sede Sur - Arequipa'             country_key = 'PE' currency = 'PEN' )
      ( company_code = '1210' parent_company_code = '1200' company_name = 'Andina Chile - Santiago'         country_key = 'CL' currency = 'CLP' )
      ( company_code = '1310' parent_company_code = '1300' company_name = 'Andina Colombia - Bogotá'        country_key = 'CO' currency = 'COP' )
      ( company_code = '2000' parent_company_code = ''     company_name = 'EuroAtlantic Group SL'           country_key = 'ES' currency = 'EUR' )
      ( company_code = '2100' parent_company_code = '2000' company_name = 'EuroAtlantic Chile'               country_key = 'CL' currency = 'CLP' )
      ( company_code = '2200' parent_company_code = '2000' company_name = 'EuroAtlantic Perú'                country_key = 'PE' currency = 'PEN' )
      ( company_code = '2110' parent_company_code = '2100' company_name = 'EA Logística - Valparaíso'        country_key = 'CL' currency = 'CLP' )
      ( company_code = '2210' parent_company_code = '2200' company_name = 'EA Planta - Callao'               country_key = 'PE' currency = 'PEN' )
      ( company_code = '3000' parent_company_code = ''     company_name = 'Atlántica Industrias S.A.'        country_key = 'BR' currency = 'BRL' )
      ( company_code = '3100' parent_company_code = '3000' company_name = 'Atlántica del Pacífico Ltda'      country_key = 'CL' currency = 'CLP' )
      ( company_code = '3110' parent_company_code = '3100' company_name = 'Planta Metalúrgica Concepción'    country_key = 'CL' currency = 'CLP' )
    ).
    DELETE FROM zasset_compcode.
    INSERT zasset_compcode FROM TABLE @lt_cc.
    io_out->write( |Company codes: { sy-dbcnt } inserted| ).
  ENDMETHOD.

  METHOD generate_cost_centers.
    DATA lt_cc TYPE TABLE OF zasset_ccenter WITH EMPTY KEY.
    lt_cc = VALUE #(
      "── 1310 Andina Colombia - Bogotá ──────────────────────────────
      ( client = sy-mandt company_code = '1310' cost_center = '1000' parent_cost_center = ''     cost_center_name = 'Operations Division'       )
      ( client = sy-mandt company_code = '1310' cost_center = '1010' parent_cost_center = '1000' cost_center_name = 'IT & Technology'            )
      ( client = sy-mandt company_code = '1310' cost_center = '1020' parent_cost_center = '1000' cost_center_name = 'Human Resources'            )
      ( client = sy-mandt company_code = '1310' cost_center = '1030' parent_cost_center = '1000' cost_center_name = 'Finance & Accounting'       )
      ( client = sy-mandt company_code = '1310' cost_center = '2000' parent_cost_center = ''     cost_center_name = 'Commercial Division'        )
      ( client = sy-mandt company_code = '1310' cost_center = '2010' parent_cost_center = '2000' cost_center_name = 'Sales & Marketing'          )
      ( client = sy-mandt company_code = '1310' cost_center = '2020' parent_cost_center = '2000' cost_center_name = 'Customer Service'           )
      "── 1110 Sede Lima Metropolitana ───────────────────────────────
      ( client = sy-mandt company_code = '1110' cost_center = '1000' parent_cost_center = ''     cost_center_name = 'Operations Division'        )
      ( client = sy-mandt company_code = '1110' cost_center = '1010' parent_cost_center = '1000' cost_center_name = 'IT & Technology'            )
      ( client = sy-mandt company_code = '1110' cost_center = '1020' parent_cost_center = '1000' cost_center_name = 'Human Resources'            )
      ( client = sy-mandt company_code = '1110' cost_center = '3000' parent_cost_center = ''     cost_center_name = 'Logistics Division'         )
      ( client = sy-mandt company_code = '1110' cost_center = '3010' parent_cost_center = '3000' cost_center_name = 'Warehouse & Inventory'      )
      ( client = sy-mandt company_code = '1110' cost_center = '3020' parent_cost_center = '3000' cost_center_name = 'Transport & Delivery'       )
      "── 2110 EA Logística - Valparaíso ─────────────────────────────
      ( client = sy-mandt company_code = '2110' cost_center = '1000' parent_cost_center = ''     cost_center_name = 'Port Operations'            )
      ( client = sy-mandt company_code = '2110' cost_center = '1010' parent_cost_center = '1000' cost_center_name = 'IT & Technology'            )
      ( client = sy-mandt company_code = '2110' cost_center = '2010' parent_cost_center = '1000' cost_center_name = 'Logistics & Freight'        )
      "── 3110 Planta Metalúrgica Concepción ─────────────────────────
      ( client = sy-mandt company_code = '3110' cost_center = '1000' parent_cost_center = ''     cost_center_name = 'Plant Operations'           )
      ( client = sy-mandt company_code = '3110' cost_center = '4010' parent_cost_center = '1000' cost_center_name = 'Production Line A'          )
      ( client = sy-mandt company_code = '3110' cost_center = '4020' parent_cost_center = '1000' cost_center_name = 'Quality Control'            )
      ( client = sy-mandt company_code = '3110' cost_center = '4030' parent_cost_center = '1000' cost_center_name = 'Maintenance & Engineering'  )
    ).
    DELETE FROM zasset_ccenter.
    INSERT zasset_ccenter FROM TABLE @lt_cc.
    io_out->write( |Cost centers:  { sy-dbcnt } inserted| ).
  ENDMETHOD.

  METHOD generate_inv_numbers.
    DATA lt_inv TYPE TABLE OF zasset_invnum WITH EMPTY KEY.
    lt_inv = VALUE #(
      "── 1310 / CC 1010 IT ───────────────────────────────────────────
      ( client = sy-mandt company_code = '1310' inventory_number = 'GRP-1310-IT'    parent_inv_num = ''             cost_center = '1010' inv_description = 'IT Assets - Bogotá'              )
      ( client = sy-mandt company_code = '1310' inventory_number = '12345678LK'     parent_inv_num = 'GRP-1310-IT'  cost_center = '1010' inv_description = 'Dell Latitude 5540 Laptop'       )
      ( client = sy-mandt company_code = '1310' inventory_number = 'INV-IT-B001'    parent_inv_num = 'GRP-1310-IT'  cost_center = '1010' inv_description = 'HP EliteDesk 800 PC'             )
      ( client = sy-mandt company_code = '1310' inventory_number = 'INV-IT-B002'    parent_inv_num = 'GRP-1310-IT'  cost_center = '1010' inv_description = 'Cisco Catalyst 2960 Switch'      )
      ( client = sy-mandt company_code = '1310' inventory_number = 'INV-IT-B003'    parent_inv_num = 'GRP-1310-IT'  cost_center = '1010' inv_description = 'Dell PowerEdge R650 Server'      )
      "── 1310 / CC 1020 HR ───────────────────────────────────────────
      ( client = sy-mandt company_code = '1310' inventory_number = 'GRP-1310-HR'    parent_inv_num = ''             cost_center = '1020' inv_description = 'HR Assets - Bogotá'              )
      ( client = sy-mandt company_code = '1310' inventory_number = 'INV-HR-B001'    parent_inv_num = 'GRP-1310-HR'  cost_center = '1020' inv_description = 'Herman Miller Aeron Chair'       )
      ( client = sy-mandt company_code = '1310' inventory_number = 'INV-HR-B002'    parent_inv_num = 'GRP-1310-HR'  cost_center = '1020' inv_description = 'Standing Desk Flexispot E7'      )
      "── 1310 / CC 1030 Finance ──────────────────────────────────────
      ( client = sy-mandt company_code = '1310' inventory_number = 'GRP-1310-FI'    parent_inv_num = ''             cost_center = '1030' inv_description = 'Finance Assets - Bogotá'         )
      ( client = sy-mandt company_code = '1310' inventory_number = 'INV-FI-B001'    parent_inv_num = 'GRP-1310-FI'  cost_center = '1030' inv_description = 'HP LaserJet Pro MFP M428'        )
      ( client = sy-mandt company_code = '1310' inventory_number = 'INV-FI-B002'    parent_inv_num = 'GRP-1310-FI'  cost_center = '1030' inv_description = 'Lenovo ThinkCentre M90q PC'      )
      "── 1110 / CC 1010 IT Lima ──────────────────────────────────────
      ( client = sy-mandt company_code = '1110' inventory_number = 'GRP-1110-IT'    parent_inv_num = ''             cost_center = '1010' inv_description = 'IT Assets - Lima'                )
      ( client = sy-mandt company_code = '1110' inventory_number = 'INV-IT-L001'    parent_inv_num = 'GRP-1110-IT'  cost_center = '1010' inv_description = 'Lenovo ThinkPad X1 Carbon'       )
      ( client = sy-mandt company_code = '1110' inventory_number = 'INV-IT-L002'    parent_inv_num = 'GRP-1110-IT'  cost_center = '1010' inv_description = 'Epson WorkForce Pro WF-7840'     )
      ( client = sy-mandt company_code = '1110' inventory_number = 'INV-IT-L003'    parent_inv_num = 'GRP-1110-IT'  cost_center = '1010' inv_description = 'Ubiquiti UniFi AP WiFi6'         )
      "── 1110 / CC 1020 HR Lima ──────────────────────────────────────
      ( client = sy-mandt company_code = '1110' inventory_number = 'GRP-1110-HR'    parent_inv_num = ''             cost_center = '1020' inv_description = 'HR Assets - Lima'                )
      ( client = sy-mandt company_code = '1110' inventory_number = 'INV-HR-L001'    parent_inv_num = 'GRP-1110-HR'  cost_center = '1020' inv_description = 'Polycom VVX 601 IP Phone'        )
      ( client = sy-mandt company_code = '1110' inventory_number = 'INV-HR-L002'    parent_inv_num = 'GRP-1110-HR'  cost_center = '1020' inv_description = 'Samsung 27in Curved Monitor'     )
      "── 1110 / CC 3010 Warehouse ────────────────────────────────────
      ( client = sy-mandt company_code = '1110' inventory_number = 'GRP-1110-WH'    parent_inv_num = ''             cost_center = '3010' inv_description = 'Warehouse Assets - Lima'         )
      ( client = sy-mandt company_code = '1110' inventory_number = 'INV-WH-L001'    parent_inv_num = 'GRP-1110-WH'  cost_center = '3010' inv_description = 'Zebra ZT420 Label Printer'       )
      ( client = sy-mandt company_code = '1110' inventory_number = 'INV-WH-L002'    parent_inv_num = 'GRP-1110-WH'  cost_center = '3010' inv_description = 'Handheld Barcode Scanner MC3300' )
      "── 2110 / CC 1010 IT Valparaíso ────────────────────────────────
      ( client = sy-mandt company_code = '2110' inventory_number = 'GRP-2110-IT'    parent_inv_num = ''             cost_center = '1010' inv_description = 'IT Assets - Valparaíso'          )
      ( client = sy-mandt company_code = '2110' inventory_number = 'INV-IT-V001'    parent_inv_num = 'GRP-2110-IT'  cost_center = '1010' inv_description = 'Apple MacBook Pro 14 M3'         )
      ( client = sy-mandt company_code = '2110' inventory_number = 'INV-IT-V002'    parent_inv_num = 'GRP-2110-IT'  cost_center = '1010' inv_description = 'Logitech MX Keys Keyboard'       )
      "── 2110 / CC 2010 Logistics ────────────────────────────────────
      ( client = sy-mandt company_code = '2110' inventory_number = 'GRP-2110-LG'    parent_inv_num = ''             cost_center = '2010' inv_description = 'Logistics Assets - Valparaíso'   )
      ( client = sy-mandt company_code = '2110' inventory_number = 'INV-LG-V001'    parent_inv_num = 'GRP-2110-LG'  cost_center = '2010' inv_description = 'Toyota Forklift 3T FB18'         )
      ( client = sy-mandt company_code = '2110' inventory_number = 'INV-LG-V002'    parent_inv_num = 'GRP-2110-LG'  cost_center = '2010' inv_description = 'Pallet Jack Hyster J2.5XN'       )
      "── 3110 / CC 4010 Production ───────────────────────────────────
      ( client = sy-mandt company_code = '3110' inventory_number = 'GRP-3110-PR'    parent_inv_num = ''             cost_center = '4010' inv_description = 'Production Assets - Concepción'  )
      ( client = sy-mandt company_code = '3110' inventory_number = 'INV-PR-C001'    parent_inv_num = 'GRP-3110-PR'  cost_center = '4010' inv_description = 'CNC Milling Machine Haas VF-2'   )
      ( client = sy-mandt company_code = '3110' inventory_number = 'INV-PR-C002'    parent_inv_num = 'GRP-3110-PR'  cost_center = '4010' inv_description = 'Welding Robot KUKA KR 6 R900'    )
      "── 3110 / CC 4030 Maintenance ──────────────────────────────────
      ( client = sy-mandt company_code = '3110' inventory_number = 'GRP-3110-MT'    parent_inv_num = ''             cost_center = '4030' inv_description = 'Maintenance Assets - Concepción' )
      ( client = sy-mandt company_code = '3110' inventory_number = 'INV-MT-C001'    parent_inv_num = 'GRP-3110-MT'  cost_center = '4030' inv_description = 'Fluke 435-II Power Analyzer'      )
      ( client = sy-mandt company_code = '3110' inventory_number = 'INV-MT-C002'    parent_inv_num = 'GRP-3110-MT'  cost_center = '4030' inv_description = 'Milwaukee M18 FUEL Drill Kit'     )
    ).
    DELETE FROM zasset_invnum.
    INSERT zasset_invnum FROM TABLE @lt_inv.
    io_out->write( |Inv. numbers:  { sy-dbcnt } inserted| ).
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
      ( descr = 'Dell Latitude 5540 Laptop'         cc = '1310' main = '00021000008' sub = '0007' cst_ctr = '1010' inv_num = '12345678LK'  status = '04' )
      ( descr = 'Logitech MX Keys Keyboard'         cc = '2110' main = '00021000008' sub = '0009' cst_ctr = '1010' inv_num = 'INV-IT-V002' status = '00' )
      ( descr = 'HP EliteDesk 800 PC'               cc = '1310' main = '00021000009' sub = '0001' cst_ctr = '1010' inv_num = 'INV-IT-B001' status = '00' )
      ( descr = 'Cisco Catalyst 2960 Switch'         cc = '1310' main = '00021000009' sub = '0002' cst_ctr = '1010' inv_num = 'INV-IT-B002' status = '01' )
      ( descr = 'Herman Miller Aeron Chair'          cc = '1310' main = '00021000010' sub = '0001' cst_ctr = '1020' inv_num = 'INV-HR-B001' status = '00' )
      ( descr = 'Standing Desk Flexispot E7'         cc = '1310' main = '00021000010' sub = '0002' cst_ctr = '1020' inv_num = 'INV-HR-B002' status = '02' )
      ( descr = 'Lenovo ThinkPad X1 Carbon'          cc = '1110' main = '00021000011' sub = '0001' cst_ctr = '1010' inv_num = 'INV-IT-L001' status = '00' )
      ( descr = 'Epson WorkForce Pro WF-7840'        cc = '1110' main = '00021000011' sub = '0002' cst_ctr = '1010' inv_num = 'INV-IT-L002' status = '00' )
      ( descr = 'HP LaserJet Pro MFP M428'           cc = '1310' main = '00021000012' sub = '0001' cst_ctr = '1030' inv_num = 'INV-FI-B001' status = '03' )
      ( descr = 'Toyota Forklift 3T FB18'            cc = '2110' main = '00021000013' sub = '0001' cst_ctr = '2010' inv_num = 'INV-LG-V001' status = '00' )
      ( descr = 'Zebra ZT420 Label Printer'          cc = '1110' main = '00021000014' sub = '0001' cst_ctr = '3010' inv_num = 'INV-WH-L001' status = '00' )
      ( descr = 'CNC Milling Machine Haas VF-2'      cc = '3110' main = '00021000015' sub = '0001' cst_ctr = '4010' inv_num = 'INV-PR-C001' status = '00' )
      ( descr = 'Welding Robot KUKA KR 6 R900'       cc = '3110' main = '00021000015' sub = '0002' cst_ctr = '4010' inv_num = 'INV-PR-C002' status = '01' )
      ( descr = 'Polycom VVX 601 IP Phone'           cc = '1110' main = '00021000016' sub = '0001' cst_ctr = '1020' inv_num = 'INV-HR-L001' status = '00' )
      ( descr = 'Apple MacBook Pro 14 M3'            cc = '2110' main = '00021000017' sub = '0001' cst_ctr = '1010' inv_num = 'INV-IT-V001' status = '00' )
      ( descr = 'Fluke 435-II Power Analyzer'        cc = '3110' main = '00021000018' sub = '0001' cst_ctr = '4030' inv_num = 'INV-MT-C001' status = '00' )
      ( descr = 'Dell PowerEdge R650 Server'         cc = '1310' main = '00021000019' sub = '0001' cst_ctr = '1010' inv_num = 'INV-IT-B003' status = '00' )
      ( descr = 'Pallet Jack Hyster J2.5XN'          cc = '2110' main = '00021000020' sub = '0001' cst_ctr = '2010' inv_num = 'INV-LG-V002' status = '04' )
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
      ls_asset-asset_description     = <s>-descr.
      ls_asset-company_code          = <s>-cc.
      ls_asset-main_asset_number     = <s>-main.
      ls_asset-asset_sub_number      = <s>-sub.
      ls_asset-cost_center           = <s>-cst_ctr.
      ls_asset-inventory_number      = <s>-inv_num.
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
        ls_history-text000         = 'Initial status set by data generator'.
        APPEND ls_history TO lt_history.
      ENDIF.
    ENDLOOP.

    DELETE FROM zassethistoryfc.
    DELETE FROM zassetfc.
    INSERT zassetfc        FROM TABLE @lt_assets.
    io_out->write( |Assets:        { sy-dbcnt } inserted| ).
    INSERT zassethistoryfc FROM TABLE @lt_history.
    io_out->write( |History:       { sy-dbcnt } inserted| ).
  ENDMETHOD.

ENDCLASS.
