CLASS lhc_asset DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_asset_row,
             asset_description TYPE c LENGTH 50,
             company_code      TYPE c LENGTH 4,
             main_asset_number TYPE c LENGTH 12,
             asset_sub_number  TYPE c LENGTH 4,
             cost_center       TYPE c LENGTH 10,
             inventory_number  TYPE c LENGTH 25,
           END OF ty_asset_row,
           tt_asset_rows TYPE STANDARD TABLE OF ty_asset_row WITH EMPTY KEY.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR asset RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR asset RESULT result.
    METHODS flag_as_damage        FOR MODIFY IMPORTING keys FOR ACTION asset~flagAsDamage       RESULT result.
    METHODS not_match_cc          FOR MODIFY IMPORTING keys FOR ACTION asset~notMatchCostCenter RESULT result.
    METHODS propose_write_off     FOR MODIFY IMPORTING keys FOR ACTION asset~proposeWriteOff    RESULT result.
    METHODS flag_as_sold          FOR MODIFY IMPORTING keys FOR ACTION asset~flagAsSold         RESULT result.
    METHODS reset_to_normal       FOR MODIFY IMPORTING keys FOR ACTION asset~resetToNormal      RESULT result.
    METHODS transfer_asset        FOR MODIFY IMPORTING keys FOR ACTION asset~transferAsset      RESULT result.
    METHODS upload_assets         FOR MODIFY IMPORTING keys FOR ACTION asset~uploadAssets.
    METHODS download_template     FOR MODIFY IMPORTING keys FOR ACTION asset~downloadTemplate.
    METHODS set_initial_status    FOR DETERMINE ON MODIFY IMPORTING keys FOR asset~setinitialstatus.
    METHODS set_creation_date     FOR DETERMINE ON MODIFY IMPORTING keys FOR asset~setcreationdate.
    METHODS set_changed_date      FOR DETERMINE ON MODIFY IMPORTING keys FOR asset~setchangeddate.
    METHODS validate_company_code FOR VALIDATE ON SAVE IMPORTING keys FOR asset~validatecompanycode.
    METHODS validate_description  FOR VALIDATE ON SAVE IMPORTING keys FOR asset~validateassetdescription.
    METHODS validate_asset_tag    FOR VALIDATE ON SAVE IMPORTING keys FOR asset~validateassettag.
ENDCLASS.

CLASS lhc_asset IMPLEMENTATION.

  METHOD get_global_authorizations.
    result = VALUE #(
      %create = if_abap_behv=>auth-allowed
      %update = if_abap_behv=>auth-allowed
      %delete = if_abap_behv=>auth-allowed
    ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets) FAILED failed.
    result = VALUE #( FOR <a> IN lt_assets
      ( %tky                                = <a>-%tky
        %features-%action-flagAsDamage       = COND #( WHEN <a>-Status = '01' OR <a>-Status = '04'
                                               THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
        %features-%action-notMatchCostCenter = COND #( WHEN <a>-Status = '02' OR <a>-Status = '04'
                                               THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
        %features-%action-proposeWriteOff    = COND #( WHEN <a>-Status = '03' OR <a>-Status = '04'
                                               THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
        %features-%action-flagAsSold         = COND #( WHEN <a>-Status = '04'
                                               THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
        %features-%action-resetToNormal      = COND #( WHEN <a>-Status = '00' OR <a>-Status = '04'
                                               THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
        %features-%action-transferAsset      = COND #( WHEN <a>-Status = '04'
                                               THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
      ) ).
  ENDMETHOD.

  METHOD upload_assets.
    DATA lt_rows   TYPE tt_asset_rows.
    DATA lt_create TYPE TABLE FOR CREATE zr_assetfc\\asset.
    DATA lt_update TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    DATA lv_file   TYPE xstring.
    DATA lv_idx    TYPE i.

    lv_file = keys[ 1 ]-%param-file_content.
    IF lv_file IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        DATA(lo_read) = xco_cp_xlsx=>document->for_file_content( lv_file )->read_access( ).
        DATA(lo_ws)   = lo_read->get_workbook( )->worksheet->at_position( 1 ).
        DATA(lo_sel)  = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                          )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
                          )->get_pattern( ).
        lo_ws->select( lo_sel )->row_stream( )->operation->write_to( REF #( lt_rows ) )->execute( ).
      CATCH cx_root.
        RETURN.
    ENDTRY.

    DELETE lt_rows WHERE asset_description IS INITIAL
                     AND company_code      IS INITIAL
                     AND main_asset_number IS INITIAL.

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT lt_rows INTO DATA(ls_row).
      lv_idx += 1.

      " Skip rows with missing mandatory fields
      IF ls_row-asset_description IS INITIAL OR ls_row-company_code      IS INITIAL OR
         ls_row-main_asset_number IS INITIAL OR ls_row-asset_sub_number  IS INITIAL OR
         ls_row-cost_center       IS INITIAL OR ls_row-inventory_number  IS INITIAL.
        CONTINUE.
      ENDIF.

      " Pre-validate cost center — skip if not found for this company
      SELECT SINGLE cost_center FROM zasset_ccenter
        WHERE company_code = @ls_row-company_code
          AND cost_center  = @ls_row-cost_center
        INTO @DATA(lv_cc).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      " Pre-validate inventory number — skip if not found for this company
      SELECT SINGLE inventory_number FROM zasset_invnum
        WHERE company_code     = @ls_row-company_code
          AND inventory_number = @ls_row-inventory_number
        INTO @DATA(lv_inv).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      SELECT SINGLE uuid FROM zassetfc
        WHERE company_code      = @ls_row-company_code
          AND main_asset_number = @ls_row-main_asset_number
          AND asset_sub_number  = @ls_row-asset_sub_number
        INTO @DATA(lv_uuid).

      IF sy-subrc = 0.
        APPEND VALUE #(
          %tky             = VALUE #( UUID = lv_uuid )
          AssetDescription = ls_row-asset_description
          CostCenter       = ls_row-cost_center
          InventoryNumber  = ls_row-inventory_number
          ChangedDate      = lv_today
          %control         = VALUE #(
            AssetDescription = if_abap_behv=>mk-on
            CostCenter       = if_abap_behv=>mk-on
            InventoryNumber  = if_abap_behv=>mk-on
            ChangedDate      = if_abap_behv=>mk-on )
        ) TO lt_update.
      ELSE.
        " Status must be set explicitly — IN LOCAL MODE bypasses setInitialStatus
        " zassetfc.status is NOT NULL with FK constraint
        APPEND VALUE #(
          %cid             = |CID_{ lv_idx }|
          AssetDescription = ls_row-asset_description
          CompanyCode      = ls_row-company_code
          MainAssetNumber  = ls_row-main_asset_number
          AssetSubNumber   = ls_row-asset_sub_number
          CostCenter       = ls_row-cost_center
          InventoryNumber  = ls_row-inventory_number
          CreationDate     = lv_today
          Status           = '00'
          %control         = VALUE #(
            AssetDescription = if_abap_behv=>mk-on
            CompanyCode      = if_abap_behv=>mk-on
            MainAssetNumber  = if_abap_behv=>mk-on
            AssetSubNumber   = if_abap_behv=>mk-on
            CostCenter       = if_abap_behv=>mk-on
            InventoryNumber  = if_abap_behv=>mk-on
            CreationDate     = if_abap_behv=>mk-on
            Status           = if_abap_behv=>mk-on )
        ) TO lt_create.
      ENDIF.
    ENDLOOP.

    IF lt_create IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
        ENTITY asset CREATE
          FIELDS ( AssetDescription CompanyCode MainAssetNumber AssetSubNumber
                   CostCenter InventoryNumber CreationDate Status )
          WITH lt_create
        REPORTED DATA(lt_rep_c) FAILED DATA(lt_fail_c) MAPPED DATA(lt_map_c).
    ENDIF.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
        ENTITY asset UPDATE
          FIELDS ( AssetDescription CostCenter InventoryNumber ChangedDate )
          WITH lt_update
        REPORTED DATA(lt_rep_u) FAILED DATA(lt_fail_u) MAPPED DATA(lt_map_u).
    ENDIF.
  ENDMETHOD.

  METHOD download_template.
  ENDMETHOD.

  METHOD validate_company_code.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( CompanyCode MainAssetNumber AssetSubNumber ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).
    LOOP AT lt_assets ASSIGNING FIELD-SYMBOL(<a>).
      APPEND VALUE #( %tky = <a>-%tky %state_area = 'VALIDATE_ASSET_REQUIRED' ) TO reported-asset.
    ENDLOOP.
    TYPES: BEGIN OF ty_cc, company_code TYPE zasset_compcode-company_code, END OF ty_cc.
    DATA cc_check  TYPE SORTED TABLE OF ty_cc WITH UNIQUE KEY company_code.
    DATA valid_ccs TYPE SORTED TABLE OF ty_cc WITH UNIQUE KEY company_code.
    LOOP AT lt_assets INTO DATA(asset_cc).
      IF asset_cc-CompanyCode IS NOT INITIAL.
        INSERT VALUE #( company_code = asset_cc-CompanyCode ) INTO TABLE cc_check.
      ENDIF.
    ENDLOOP.
    IF cc_check IS NOT INITIAL.
      SELECT db~company_code FROM zasset_compcode AS db
        INNER JOIN @cc_check AS req ON db~company_code = req~company_code INTO TABLE @valid_ccs.
    ENDIF.
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-CompanyCode IS INITIAL.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %state_area = 'VALIDATE_ASSET_REQUIRED'
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Company Code is required' )
          %element-CompanyCode = if_abap_behv=>mk-on ) TO reported-asset.
      ELSEIF NOT line_exists( valid_ccs[ company_code = asset-CompanyCode ] ).
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %state_area = 'VALIDATE_ASSET_REQUIRED'
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                        text = |Company Code { asset-CompanyCode } does not exist| )
          %element-CompanyCode = if_abap_behv=>mk-on ) TO reported-asset.
      ENDIF.
      IF asset-MainAssetNumber IS INITIAL.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %state_area = 'VALIDATE_ASSET_REQUIRED'
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Main Asset Number is required' )
          %element-MainAssetNumber = if_abap_behv=>mk-on ) TO reported-asset.
      ENDIF.
      IF asset-AssetSubNumber IS INITIAL.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %state_area = 'VALIDATE_ASSET_REQUIRED'
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Asset Sub Number is required' )
          %element-AssetSubNumber = if_abap_behv=>mk-on ) TO reported-asset.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_description.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( AssetDescription ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).
    LOOP AT lt_assets ASSIGNING FIELD-SYMBOL(<a>).
      APPEND VALUE #( %tky = <a>-%tky %state_area = 'VALIDATE_DESCRIPTION' ) TO reported-asset.
    ENDLOOP.
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-AssetDescription IS INITIAL.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %state_area = 'VALIDATE_DESCRIPTION'
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Asset Description is required' )
          %element-AssetDescription = if_abap_behv=>mk-on ) TO reported-asset.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_asset_tag.
    DATA lv_dup TYPE zassetfc-uuid.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( AssetTagNumber UUID CompanyCode CostCenter InventoryNumber ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).
    LOOP AT lt_assets ASSIGNING FIELD-SYMBOL(<a>).
      APPEND VALUE #( %tky = <a>-%tky %state_area = 'VALIDATE_ASSET_TAG' ) TO reported-asset.
    ENDLOOP.
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-AssetTagNumber IS NOT INITIAL.
        SELECT SINGLE uuid FROM zassetfc
          WHERE asset_tag_number = @asset-AssetTagNumber AND uuid <> @asset-UUID INTO @lv_dup.
        IF sy-subrc = 0.
          APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
          APPEND VALUE #( %tky = asset-%tky %state_area = 'VALIDATE_ASSET_TAG'
            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                          text = |Asset Tag { asset-AssetTagNumber } already in use| )
            %element-AssetTagNumber = if_abap_behv=>mk-on ) TO reported-asset.
        ENDIF.
      ENDIF.
      IF asset-CostCenter IS INITIAL.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %state_area = 'VALIDATE_ASSET_TAG'
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Cost Center is required' )
          %element-CostCenter = if_abap_behv=>mk-on ) TO reported-asset.
      ELSE.
        SELECT SINGLE cost_center FROM zasset_ccenter
          WHERE company_code = @asset-CompanyCode AND cost_center = @asset-CostCenter INTO @DATA(lv_cc).
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
          APPEND VALUE #( %tky = asset-%tky %state_area = 'VALIDATE_ASSET_TAG'
            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                          text = |Cost Center { asset-CostCenter } not valid for Company Code { asset-CompanyCode }| )
            %element-CostCenter = if_abap_behv=>mk-on ) TO reported-asset.
        ENDIF.
      ENDIF.
      IF asset-InventoryNumber IS INITIAL.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %state_area = 'VALIDATE_ASSET_TAG'
          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Inventory Number is required' )
          %element-InventoryNumber = if_abap_behv=>mk-on ) TO reported-asset.
      ELSE.
        SELECT SINGLE inventory_number FROM zasset_invnum
          WHERE company_code     = @asset-CompanyCode
            AND inventory_number = @asset-InventoryNumber
          INTO @DATA(lv_inv).
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
          APPEND VALUE #( %tky = asset-%tky %state_area = 'VALIDATE_ASSET_TAG'
            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                          text = |Inventory Number { asset-InventoryNumber } not valid for Company Code { asset-CompanyCode }| )
            %element-InventoryNumber = if_abap_behv=>mk-on ) TO reported-asset.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD flag_as_damage.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    DATA lt_history   TYPE TABLE FOR CREATE zr_assetfc\_AssetHistory.
    DATA lv_max_id    TYPE zassethistoryfc-his_id.
    DATA lv_new_id    TYPE zassethistoryfc-his_id.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status UUID ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_assets).
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-Status = '01'.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error text = 'Asset is already flagged as Damaged' )
        ) TO reported-asset. CONTINUE.
      ENDIF.
      APPEND VALUE #( %tky = asset-%tky Status = '01' ) TO update_table.
      SELECT MAX( his_id ) FROM zassethistoryfc WHERE parent_uuid = @asset-UUID INTO @lv_max_id.
      lv_new_id = lv_max_id + 1.
      APPEND VALUE #( %tky = asset-%tky %target = VALUE #( (
        %cid = |HD{ asset-UUID }| HisID = lv_new_id PreviousStatus = asset-Status NewStatus = '01' Text000 = 'Flagged as Damaged'
      ) ) ) TO lt_history.
    ENDLOOP.
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
    IF lt_history IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset CREATE BY \_AssetHistory
        FIELDS ( HisID PreviousStatus NewStatus Text000 ) WITH lt_history.
    ENDIF.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD not_match_cc.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    DATA lt_history   TYPE TABLE FOR CREATE zr_assetfc\_AssetHistory.
    DATA lv_max_id    TYPE zassethistoryfc-his_id.
    DATA lv_new_id    TYPE zassethistoryfc-his_id.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status UUID ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_assets).
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-Status = '02'.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error text = 'Asset already reported as Cost Center Mismatch' )
        ) TO reported-asset. CONTINUE.
      ENDIF.
      APPEND VALUE #( %tky = asset-%tky Status = '02' ) TO update_table.
      SELECT MAX( his_id ) FROM zassethistoryfc WHERE parent_uuid = @asset-UUID INTO @lv_max_id.
      lv_new_id = lv_max_id + 1.
      APPEND VALUE #( %tky = asset-%tky %target = VALUE #( (
        %cid = |HN{ asset-UUID }| HisID = lv_new_id PreviousStatus = asset-Status NewStatus = '02' Text000 = 'Cost Center Mismatch'
      ) ) ) TO lt_history.
    ENDLOOP.
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
    IF lt_history IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset CREATE BY \_AssetHistory
        FIELDS ( HisID PreviousStatus NewStatus Text000 ) WITH lt_history.
    ENDIF.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD propose_write_off.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    DATA lt_history   TYPE TABLE FOR CREATE zr_assetfc\_AssetHistory.
    DATA lv_max_id    TYPE zassethistoryfc-his_id.
    DATA lv_new_id    TYPE zassethistoryfc-his_id.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status UUID ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_assets).
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-Status = '03'.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error text = 'Asset is already proposed for Write-Off' )
        ) TO reported-asset. CONTINUE.
      ENDIF.
      APPEND VALUE #( %tky = asset-%tky Status = '03' ) TO update_table.
      SELECT MAX( his_id ) FROM zassethistoryfc WHERE parent_uuid = @asset-UUID INTO @lv_max_id.
      lv_new_id = lv_max_id + 1.
      APPEND VALUE #( %tky = asset-%tky %target = VALUE #( (
        %cid = |HW{ asset-UUID }| HisID = lv_new_id PreviousStatus = asset-Status NewStatus = '03' Text000 = 'Proposed for Write-Off'
      ) ) ) TO lt_history.
    ENDLOOP.
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
    IF lt_history IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset CREATE BY \_AssetHistory
        FIELDS ( HisID PreviousStatus NewStatus Text000 ) WITH lt_history.
    ENDIF.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD flag_as_sold.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    DATA lt_history   TYPE TABLE FOR CREATE zr_assetfc\_AssetHistory.
    DATA lv_max_id    TYPE zassethistoryfc-his_id.
    DATA lv_new_id    TYPE zassethistoryfc-his_id.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status UUID ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_assets).
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-Status = '04'.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error text = 'Asset is already marked as Sold' )
        ) TO reported-asset. CONTINUE.
      ENDIF.
      APPEND VALUE #( %tky = asset-%tky Status = '04' ) TO update_table.
      SELECT MAX( his_id ) FROM zassethistoryfc WHERE parent_uuid = @asset-UUID INTO @lv_max_id.
      lv_new_id = lv_max_id + 1.
      APPEND VALUE #( %tky = asset-%tky %target = VALUE #( (
        %cid = |HS{ asset-UUID }| HisID = lv_new_id PreviousStatus = asset-Status NewStatus = '04' Text000 = 'Flagged as Sold'
      ) ) ) TO lt_history.
    ENDLOOP.
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
    IF lt_history IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset CREATE BY \_AssetHistory
        FIELDS ( HisID PreviousStatus NewStatus Text000 ) WITH lt_history.
    ENDIF.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD reset_to_normal.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    DATA lt_history   TYPE TABLE FOR CREATE zr_assetfc\_AssetHistory.
    DATA lv_max_id    TYPE zassethistoryfc-his_id.
    DATA lv_new_id    TYPE zassethistoryfc-his_id.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_assets).
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-Status = '00'.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error text = 'Asset status is already Normal' )
        ) TO reported-asset. CONTINUE.
      ENDIF.
      APPEND VALUE #( %tky = asset-%tky Status = '00' ) TO update_table.
      SELECT MAX( his_id ) FROM zassethistoryfc WHERE parent_uuid = @asset-UUID INTO @lv_max_id.
      lv_new_id = lv_max_id + 1.
      APPEND VALUE #( %tky = asset-%tky %target = VALUE #( (
        %cid = |HR{ asset-UUID }| HisID = lv_new_id PreviousStatus = asset-Status NewStatus = '00' Text000 = 'Reset to Normal'
      ) ) ) TO lt_history.
    ENDLOOP.
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
    IF lt_history IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset CREATE BY \_AssetHistory
        FIELDS ( HisID PreviousStatus NewStatus Text000 ) WITH lt_history.
    ENDIF.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD transfer_asset.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    DATA lt_history   TYPE TABLE FOR CREATE zr_assetfc\_AssetHistory.
    DATA lv_max_id    TYPE zassethistoryfc-his_id.
    DATA lv_new_id    TYPE zassethistoryfc-his_id.
    DATA lv_text      TYPE zassethistoryfc-text000.
    DATA lv_new_cc    TYPE zasset_compcode-company_code.
    DATA lv_exists    TYPE zasset_compcode-company_code.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( CompanyCode UUID Status ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_assets).
    LOOP AT lt_assets INTO DATA(asset).
      lv_new_cc = keys[ %tky = asset-%tky ]-%param-NewCompanyCode.
      IF asset-Status = '04'.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error text = 'Sold asset cannot be transferred' )
        ) TO reported-asset. CONTINUE.
      ENDIF.
      IF lv_new_cc = asset-CompanyCode.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error text = 'Target company code same as current' )
        ) TO reported-asset. CONTINUE.
      ENDIF.
      SELECT SINGLE company_code FROM zasset_compcode WHERE company_code = @lv_new_cc INTO @lv_exists.
      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error text = |Company Code { lv_new_cc } does not exist| )
        ) TO reported-asset. CONTINUE.
      ENDIF.
      APPEND VALUE #( %tky = asset-%tky CompanyCode = lv_new_cc ) TO update_table.
      SELECT MAX( his_id ) FROM zassethistoryfc WHERE parent_uuid = @asset-UUID INTO @lv_max_id.
      lv_new_id = lv_max_id + 1.
      lv_text = COND #( WHEN keys[ %tky = asset-%tky ]-%param-TransferNote IS NOT INITIAL
                        THEN keys[ %tky = asset-%tky ]-%param-TransferNote
                        ELSE |Transferred to CC { lv_new_cc }| ).
      APPEND VALUE #( %tky = asset-%tky %target = VALUE #( (
        %cid = |TF{ asset-UUID }| HisID = lv_new_id PreviousStatus = asset-Status NewStatus = asset-Status Text000 = lv_text
      ) ) ) TO lt_history.
    ENDLOOP.
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset UPDATE FIELDS ( CompanyCode ) WITH update_table.
    ENDIF.
    IF lt_history IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset CREATE BY \_AssetHistory
        FIELDS ( HisID PreviousStatus NewStatus Text000 ) WITH lt_history.
    ENDIF.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD set_initial_status.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_assets).
    update_table = VALUE #( FOR a IN lt_assets WHERE ( Status IS INITIAL ) ( %tky = a-%tky Status = '00' ) ).
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
  ENDMETHOD.

  METHOD set_creation_date.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( CreationDate ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_assets).
    update_table = VALUE #( FOR a IN lt_assets WHERE ( CreationDate IS INITIAL ) ( %tky = a-%tky CreationDate = lv_today ) ).
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset UPDATE FIELDS ( CreationDate ) WITH update_table.
    ENDIF.
  ENDMETHOD.

  METHOD set_changed_date.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( ChangedDate ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_assets).
    update_table = VALUE #( FOR a IN lt_assets WHERE ( ChangedDate <> lv_today ) ( %tky = a-%tky ChangedDate = lv_today ) ).
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE ENTITY asset UPDATE FIELDS ( ChangedDate ) WITH update_table.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
