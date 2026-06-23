CLASS lhc_asset DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR asset
      RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR asset RESULT result.
    METHODS flag_as_damage        FOR MODIFY IMPORTING keys FOR ACTION asset~flagAsDamage       RESULT result.
    METHODS not_match_cc          FOR MODIFY IMPORTING keys FOR ACTION asset~notMatchCostCenter RESULT result.
    METHODS propose_write_off     FOR MODIFY IMPORTING keys FOR ACTION asset~proposeWriteOff    RESULT result.
    METHODS flag_as_sold          FOR MODIFY IMPORTING keys FOR ACTION asset~flagAsSold         RESULT result.
    METHODS reset_to_normal       FOR MODIFY IMPORTING keys FOR ACTION asset~resetToNormal      RESULT result.
    METHODS set_initial_status    FOR DETERMINE ON MODIFY IMPORTING keys FOR asset~setinitialstatus.
    METHODS set_creation_date     FOR DETERMINE ON MODIFY IMPORTING keys FOR asset~setcreationdate.
    METHODS set_changed_date      FOR DETERMINE ON MODIFY IMPORTING keys FOR asset~setchangeddate.
    METHODS validate_company_code FOR VALIDATE ON SAVE      IMPORTING keys FOR asset~validatecompanycode.
    METHODS validate_description  FOR VALIDATE ON SAVE      IMPORTING keys FOR asset~validateassetdescription.
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
        %features-%action-flagAsDamage       = COND #( WHEN <a>-Status = '01'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
        %features-%action-notMatchCostCenter = COND #( WHEN <a>-Status = '02'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
        %features-%action-proposeWriteOff    = COND #( WHEN <a>-Status = '03'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
        %features-%action-flagAsSold         = COND #( WHEN <a>-Status = '04'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
        %features-%action-resetToNormal      = COND #( WHEN <a>-Status = '00'
                                               THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled )
        %features-%field-AssetTagNumber      = COND #( WHEN <a>-Status <> '00'
                                               THEN if_abap_behv=>fc-f-read_only
                                               ELSE if_abap_behv=>fc-f-unrestricted )
      ) ).
  ENDMETHOD.

  METHOD flag_as_damage.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-Status = '01'.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Asset is already flagged as Damaged' )
                      ) TO reported-asset.
        CONTINUE.
      ENDIF.
      APPEND VALUE #( %tky = asset-%tky Status = '01' ) TO update_table.
    ENDLOOP.
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
        ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD not_match_cc.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-Status = '02'.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Asset already reported as Cost Center Mismatch' )
                      ) TO reported-asset.
        CONTINUE.
      ENDIF.
      APPEND VALUE #( %tky = asset-%tky Status = '02' ) TO update_table.
    ENDLOOP.
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
        ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD propose_write_off.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-Status = '03'.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Asset is already proposed for Write-Off' )
                      ) TO reported-asset.
        CONTINUE.
      ENDIF.
      APPEND VALUE #( %tky = asset-%tky Status = '03' ) TO update_table.
    ENDLOOP.
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
        ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD flag_as_sold.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-Status = '04'.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Asset is already marked as Sold' )
                      ) TO reported-asset.
        CONTINUE.
      ENDIF.
      APPEND VALUE #( %tky = asset-%tky Status = '04' ) TO update_table.
    ENDLOOP.
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
        ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD reset_to_normal.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).
    LOOP AT lt_assets INTO DATA(asset).
      IF asset-Status = '00'.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky = asset-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Asset status is already Normal' )
                      ) TO reported-asset.
        CONTINUE.
      ENDIF.
      APPEND VALUE #( %tky = asset-%tky Status = '00' ) TO update_table.
    ENDLOOP.
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
        ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).
    result = VALUE #( FOR r IN lt_result ( %tky = r-%tky %param = r ) ).
  ENDMETHOD.

  METHOD set_initial_status.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( Status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).
    update_table = VALUE #( FOR a IN lt_assets WHERE ( Status IS INITIAL )
                            ( %tky = a-%tky Status = '00' ) ).
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
        ENTITY asset UPDATE FIELDS ( Status ) WITH update_table.
    ENDIF.
  ENDMETHOD.

  METHOD set_creation_date.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( CreationDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).
    update_table = VALUE #( FOR a IN lt_assets WHERE ( CreationDate IS INITIAL )
                            ( %tky = a-%tky CreationDate = lv_today ) ).
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
        ENTITY asset UPDATE FIELDS ( CreationDate ) WITH update_table.
    ENDIF.
  ENDMETHOD.

  METHOD set_changed_date.
    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\asset.
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( ChangedDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).
    update_table = VALUE #( FOR a IN lt_assets WHERE ( ChangedDate <> lv_today )
                            ( %tky = a-%tky ChangedDate = lv_today ) ).
    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
        ENTITY asset UPDATE FIELDS ( ChangedDate ) WITH update_table.
    ENDIF.
  ENDMETHOD.

  METHOD validate_company_code.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( CompanyCode ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).

    LOOP AT lt_assets ASSIGNING FIELD-SYMBOL(<a>).
      APPEND VALUE #( %tky        = <a>-%tky
                      %state_area = 'VALIDATE_COMPANY_CODE' ) TO reported-asset.
    ENDLOOP.

    TYPES: BEGIN OF ty_cc,
             company_code TYPE zasset_compcode-company_code,
           END OF ty_cc.
    DATA cc_check  TYPE SORTED TABLE OF ty_cc WITH UNIQUE KEY company_code.
    DATA valid_ccs TYPE SORTED TABLE OF ty_cc WITH UNIQUE KEY company_code.

    cc_check = CORRESPONDING #( lt_assets DISCARDING DUPLICATES
                                MAPPING company_code = CompanyCode EXCEPT * ).
    DELETE cc_check WHERE company_code IS INITIAL.

    IF cc_check IS NOT INITIAL.
      SELECT db~company_code FROM zasset_compcode AS db
        INNER JOIN @cc_check AS req ON db~company_code = req~company_code
        INTO TABLE @valid_ccs.
    ENDIF.

    LOOP AT lt_assets INTO DATA(asset).
      IF asset-CompanyCode IS INITIAL.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky                 = asset-%tky
                        %state_area          = 'VALIDATE_COMPANY_CODE'
                        %msg                 = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Company Code is required' )
                        %element-CompanyCode = if_abap_behv=>mk-on ) TO reported-asset.
      ELSEIF NOT line_exists( valid_ccs[ company_code = asset-CompanyCode ] ).
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky                 = asset-%tky
                        %state_area          = 'VALIDATE_COMPANY_CODE'
                        %msg                 = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = |Company Code { asset-CompanyCode } does not exist| )
                        %element-CompanyCode = if_abap_behv=>mk-on ) TO reported-asset.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_description.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY asset FIELDS ( AssetDescription ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_assets).

    LOOP AT lt_assets ASSIGNING FIELD-SYMBOL(<a>).
      APPEND VALUE #( %tky        = <a>-%tky
                      %state_area = 'VALIDATE_DESCRIPTION' ) TO reported-asset.
    ENDLOOP.

    LOOP AT lt_assets INTO DATA(asset).
      IF asset-AssetDescription IS INITIAL.
        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
        APPEND VALUE #( %tky                      = asset-%tky
                        %state_area               = 'VALIDATE_DESCRIPTION'
                        %msg                      = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Asset Description is required' )
                        %element-AssetDescription = if_abap_behv=>mk-on ) TO reported-asset.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
