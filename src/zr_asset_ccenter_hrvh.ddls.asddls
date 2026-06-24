@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Asset Tracker - Cost Center Hierarchy'
define hierarchy ZR_ASSET_CCENTER_HRVH
  as parent child hierarchy(
    source ZR_ASSET_CCENTER
    child to parent association _ParentNode
    start where
      ParentCostCenter is initial
    siblings order by
      CostCenter
    multiple parents not allowed
  )
{
  key CompanyCode,
  key CostCenter,
      ParentCostCenter,
      CostCenterName
}
