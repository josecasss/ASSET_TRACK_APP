@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Asset Tracker - Inventory Number Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_ASSET_INVNUM
  as select from zasset_invnum
  association of many to one ZR_ASSET_INVNUM as _ParentNode
    on  $projection.CompanyCode   = _ParentNode.CompanyCode
    and $projection.ParentInvNum  = _ParentNode.InventoryNumber
{
  key company_code      as CompanyCode,
  key inventory_number  as InventoryNumber,
      parent_inv_num    as ParentInvNum,
      cost_center       as CostCenter,
      inv_description   as InvDescription,
      _ParentNode
}
