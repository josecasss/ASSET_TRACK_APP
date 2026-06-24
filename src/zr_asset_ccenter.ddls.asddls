@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Asset Tracker - Cost Center Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_ASSET_CCENTER
  as select from zasset_ccenter
  association of many to one ZR_ASSET_CCENTER as _ParentNode
    on  $projection.CompanyCode      = _ParentNode.CompanyCode
    and $projection.ParentCostCenter = _ParentNode.CostCenter
{
  key company_code        as CompanyCode,
  key cost_center         as CostCenter,
      parent_cost_center  as ParentCostCenter,
      cost_center_name    as CostCenterName,
      _ParentNode
}
