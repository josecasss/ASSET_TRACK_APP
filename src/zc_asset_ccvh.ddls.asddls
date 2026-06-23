@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Asset Tracker - Company Code VH '
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.supportedCapabilities: [ #VALUE_HELP_PROVIDER ]
@Metadata.allowExtensions: true
@UI.presentationVariant: [{
  recursiveHierarchyQualifier: 'ZR_ASSET_CC_HRVH',
  initialExpansionLevel: 1,
  qualifier: 'HIERARCHY'
}]
@OData.hierarchy.recursiveHierarchy: [{ entity.name: 'ZR_ASSET_CC_HRVH' }]
define root view entity ZC_ASSET_CCVH
  provider contract transactional_query
  as projection on ZR_ASSET_COMPCODE
  association of many to one ZC_ASSET_CCVH as _ParentNode
    on $projection.ParentCompanyCode = _ParentNode.CompanyCode
{
      @UI.lineItem: [{ position: 10 }]
  key CompanyCode,
      ParentCompanyCode,
      
      @UI.lineItem: [{ position: 30 }]
      CompanyName,
      @UI.lineItem: [{ position: 40 }]
      CountryKey,
      _ParentNode
}
