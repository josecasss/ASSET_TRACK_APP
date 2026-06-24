@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Asset Tracker - Cost Center VH'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.supportedCapabilities: [ #VALUE_HELP_PROVIDER ]
@Metadata.allowExtensions: true
@UI.presentationVariant: [{
  recursiveHierarchyQualifier: 'ZR_ASSET_CCENTER_HRVH',
  initialExpansionLevel: 1,
  qualifier: 'HIERARCHY'
}]
@OData.hierarchy.recursiveHierarchy: [{ entity.name: 'ZR_ASSET_CCENTER_HRVH' }]
define root view entity ZC_ASSET_CENTERVH
  provider contract transactional_query
  as projection on ZR_ASSET_CCENTER
  association of many to one ZC_ASSET_CENTERVH as _ParentNode
    on  $projection.CompanyCode      = _ParentNode.CompanyCode
    and $projection.ParentCostCenter = _ParentNode.CostCenter
{
      @UI.lineItem: [{ position: 10 }]
  key CompanyCode,
      @UI.lineItem: [{ position: 20 }]
  key CostCenter,
      ParentCostCenter,
      @UI.lineItem: [{ position: 30 }]
      CostCenterName,
      _ParentNode
}
