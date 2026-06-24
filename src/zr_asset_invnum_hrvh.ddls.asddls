@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Asset Tracker - Inventory Number Hierarchy'
define hierarchy ZR_ASSET_INVNUM_HRVH
  as parent child hierarchy(
    source ZR_ASSET_INVNUM
    child to parent association _ParentNode
    start where
      ParentInvNum is initial
    siblings order by
      InventoryNumber
    multiple parents not allowed
  )
{
  key CompanyCode,
  key InventoryNumber,
      ParentInvNum,
      CostCenter,
      InvDescription
}
