CLASS lhc_zr_assetfc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING REQUEST requested_authorizations FOR Asset RESULT result,
      get_instance_authorizations FOR INSTANCE AUTHORIZATION
        IMPORTING keys REQUEST requested_authorizations FOR Asset RESULT result,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Asset RESULT result,
      flagAsDamage FOR MODIFY
        IMPORTING keys FOR ACTION Asset~flagAsDamage RESULT result,
      notMatchCostCenter FOR MODIFY
        IMPORTING keys FOR ACTION Asset~notMatchCostCenter RESULT result,
      proposeWriteOff FOR MODIFY
        IMPORTING keys FOR ACTION Asset~proposeWriteOff RESULT result,
      flagAsSold FOR MODIFY
        IMPORTING keys FOR ACTION Asset~flagAsSold RESULT result,
      resetToNormal FOR MODIFY
        IMPORTING keys FOR ACTION Asset~resetToNormal RESULT result,
      setInitialStatus FOR DETERMINE ON MODIFY
        IMPORTING keys FOR Asset~setInitialStatus.
"      validateAssetTag FOR VALIDATE ON SAVE
"        IMPORTING keys FOR Asset~validateAssetTag.
ENDCLASS.

CLASS lhc_zr_assetfc IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(assets)
      FAILED DATA(failed_gf).

    result = VALUE #( FOR asset IN assets
      LET is_normal     = COND #( WHEN asset-Status = '00'
                                  THEN if_abap_behv=>mk-on
                                  ELSE if_abap_behv=>mk-off )
          is_not_normal = COND #( WHEN asset-Status <> '00'
                                  THEN if_abap_behv=>mk-on
                                  ELSE if_abap_behv=>mk-off )
      IN
      ( %tky                       = asset-%tky
        %field-AssetTagNumber      = if_abap_behv=>mk-off
        %action-flagAsDamage       = is_normal
        %action-notMatchCostCenter = is_normal
        %action-proposeWriteOff    = is_normal
        %action-flagAsSold         = is_normal
        %action-resetToNormal      = is_not_normal
      )
    ).
  ENDMETHOD.

  METHOD setInitialStatus.
    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(assets).

    DATA update_table TYPE TABLE FOR UPDATE zr_assetfc\\Asset.

    LOOP AT assets INTO DATA(asset).
      IF asset-Status IS INITIAL.
        APPEND VALUE #( %tky   = asset-%tky
                        Status = '00' ) TO update_table.
      ENDIF.
    ENDLOOP.

    IF update_table IS NOT INITIAL.
      MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
        ENTITY Asset
        UPDATE FIELDS ( Status )
        WITH update_table.
    ENDIF.
  ENDMETHOD.

*  METHOD validateAssetTag.
*    READ ENTITIES OF zr_assetfc IN LOCAL MODE
*      ENTITY Asset
*      FIELDS ( AssetTagNumber )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(assets).
*
*    LOOP AT assets INTO DATA(asset).
*
*      APPEND VALUE #( %tky        = asset-%tky
*                      %state_area = 'VALIDATE_ASSET_TAG' ) TO reported-asset.
*
*      IF asset-AssetTagNumber IS INITIAL.
*        APPEND VALUE #( %tky = asset-%tky ) TO failed-asset.
*        APPEND VALUE #( %tky                    = asset-%tky
*                        %state_area             = 'VALIDATE_ASSET_TAG'
*                        %msg                    = new_message_with_text(
*                          severity = if_abap_behv_message=>severity-error
*                          text     = 'Asset Tag Number is mandatory' )
*                        %element-AssetTagNumber = if_abap_behv=>mk-on
*                      ) TO reported-asset.
*      ENDIF.
*
*    ENDLOOP.
*  ENDMETHOD.

  METHOD flagAsDamage.
    MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky  Status = '01' ) ).

    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(assets).

    result = VALUE #( FOR asset IN assets ( %tky = asset-%tky  %param = asset ) ).
  ENDMETHOD.

  METHOD notMatchCostCenter.
    MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky  Status = '02' ) ).

    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(assets).

    result = VALUE #( FOR asset IN assets ( %tky = asset-%tky  %param = asset ) ).
  ENDMETHOD.

  METHOD proposeWriteOff.
    MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky  Status = '03' ) ).

    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(assets).

    result = VALUE #( FOR asset IN assets ( %tky = asset-%tky  %param = asset ) ).
  ENDMETHOD.

  METHOD flagAsSold.
    MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky  Status = '04' ) ).

    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(assets).

    result = VALUE #( FOR asset IN assets ( %tky = asset-%tky  %param = asset ) ).
  ENDMETHOD.

  METHOD resetToNormal.
    MODIFY ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky  Status = '00' ) ).

    READ ENTITIES OF zr_assetfc IN LOCAL MODE
      ENTITY Asset ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(assets).

    result = VALUE #( FOR asset IN assets ( %tky = asset-%tky  %param = asset ) ).
  ENDMETHOD.

ENDCLASS.
