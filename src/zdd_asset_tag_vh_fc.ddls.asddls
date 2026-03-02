@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Incident Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'AssetTagNumber'
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.usageType.dataClass: #CUSTOMIZING
@VDM.viewType: #COMPOSITE
@Search.searchable: true
define view entity ZDD_ASSET_TAG_VH_FC
  as select from zassetfc
{
      @ObjectModel.text.element:['AssetTagNumber']
  key asset_tag_number  as AssetTagNumber,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text:true
      asset_description as AssetDescription

}
