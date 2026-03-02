@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Consumption Entity - Tracking Asset'
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZC_ASSETHISTORYFC
  as projection on ZR_ASSETHISTORYFC
  association [1..1] to ZR_ASSETHISTORYFC as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  ParentUUID,
  HisID,
  PreviousStatus,
  NewStatus,
  Text000,
  _Asset : redirected to parent ZC_ASSETFC,
  _BaseEntity
}
