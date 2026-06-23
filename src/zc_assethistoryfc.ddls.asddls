@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Consumption Entity - Tracking Asset'
}
@AccessControl.authorizationCheck: #NOT_ALLOWED
define view entity ZC_ASSETHISTORYFC
  as projection on ZR_ASSETHISTORYFC
{
  key UUID,
  ParentUUID,
  HisID,
  PreviousStatus,
  NewStatus,
  Text000,
  _Asset : redirected to parent ZC_ASSETFC
}
