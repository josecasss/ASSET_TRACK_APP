@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Asset Tracker - Inventory Number VH'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.supportedCapabilities: [ #VALUE_HELP_PROVIDER ]
@Metadata.allowExtensions: true
@UI.presentationVariant: [{
  recursiveHierarchyQualifier: 'ZR_ASSET_INVNUM_HRVH',
  initialExpansionLevel: 1,
  qualifier: 'HIERARCHY'
}]
@OData.hierarchy.recursiveHierarchy: [{ entity.name: 'ZR_ASSET_INVNUM_HRVH' }]
define root view entity ZC_ASSET_INVNUMVH
  provider contract transactional_query
  as projection on ZR_ASSET_INVNUM
  association of many to one ZC_ASSET_INVNUMVH as _ParentNode
    on  $projection.CompanyCode  = _ParentNode.CompanyCode
    and $projection.ParentInvNum = _ParentNode.InventoryNumber
{
      @UI.lineItem: [{ position: 10 }]
  key CompanyCode,
      @UI.lineItem: [{ position: 20 }]
  key InventoryNumber,
      ParentInvNum,
      @UI.lineItem: [{ position: 30 }]
      CostCenter,
      @UI.lineItem: [{ position: 40 }]
      InvDescription,
      _ParentNode
}
