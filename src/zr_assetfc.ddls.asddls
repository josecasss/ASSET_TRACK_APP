@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZAsset_FCFC'
@EndUserText.label: 'Root Entity - Tracking Asset'
define root view entity ZR_ASSETFC
  as select from zassetfc as Asset
  composition [0..*] of ZR_ASSETHISTORYFC as _AssetHistory
  association [1..1] to zdd_status_vh_fc  as _AssetStatusCodes on Asset.status = _AssetStatusCodes.StatusCode
  association [1..1] to ZDD_ASSET_TAG_VH_FC as _AssetTagCodes on Asset.asset_tag_number = _AssetTagCodes.AssetTagNumber
{
  key uuid                  as UUID,
      asset_tag_number      as AssetTagNumber,
      asset_description     as AssetDescription,
      company_code          as CompanyCode,
      main_asset_number     as MainAssetNumber,
      asset_sub_number      as AssetSubNumber,
      status                as Status,
      creation_date         as CreationDate,
      changed_date          as ChangedDate,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _AssetHistory, // Association to asset history
      _AssetStatusCodes, // Association to asset status codes
      _AssetTagCodes
}
