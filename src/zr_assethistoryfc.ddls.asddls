@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@EndUserText.label: 'Root Entity - Tracking Asset History'
define view entity ZR_ASSETHISTORYFC
  as select from zassethistoryfc as AssetHistory
  association to parent ZR_ASSETFC as _Asset on $projection.ParentUUID = _Asset.UUID
{
  key uuid as UUID,
  parent_uuid as ParentUUID,
  his_id as HisID,
  previous_status as PreviousStatus,
  new_status as NewStatus,
  text000 as Text000,
  _Asset
}
