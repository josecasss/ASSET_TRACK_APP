CLASS LHC_ZR_ASSETFC DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Asset
        RESULT result,
      get_instance_authorizations FOR INSTANCE AUTHORIZATION
            IMPORTING keys REQUEST requested_authorizations FOR Asset RESULT result,
      get_instance_features FOR INSTANCE FEATURES
            IMPORTING keys REQUEST requested_features FOR Asset RESULT result.

          METHODS flagAsDamage FOR MODIFY
            IMPORTING keys FOR ACTION Asset~flagAsDamage RESULT result.

          METHODS flagAsSold FOR MODIFY
            IMPORTING keys FOR ACTION Asset~flagAsSold.

          METHODS notMatchCostCenter FOR MODIFY
            IMPORTING keys FOR ACTION Asset~notMatchCostCenter RESULT result.

          METHODS proposeWriteOff FOR MODIFY
            IMPORTING keys FOR ACTION Asset~proposeWriteOff.

          METHODS resetToNormal FOR MODIFY
            IMPORTING keys FOR ACTION Asset~resetToNormal.
ENDCLASS.

CLASS LHC_ZR_ASSETFC IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD flagAsDamage.
  ENDMETHOD.

  METHOD flagAsSold.
  ENDMETHOD.

  METHOD notMatchCostCenter.
  ENDMETHOD.

  METHOD proposeWriteOff.
  ENDMETHOD.

  METHOD resetToNormal.
  ENDMETHOD.

ENDCLASS.
