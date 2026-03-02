@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Asset Status Code CDS'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZDD_ASSET_STATUS_CODES_FC as select from zasset_status
{
    key status_code as StatusCode,
    status_description as StatusDescription
}
