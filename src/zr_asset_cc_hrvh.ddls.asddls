@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Asset Tracker - Company Code Hierarchy'
define hierarchy ZR_ASSET_CC_HRVH
  as parent child hierarchy(
    source ZR_ASSET_COMPCODE
    child to parent association _ParentNode
    start where
      ParentCompanyCode is initial
    siblings order by
      CompanyCode
    multiple parents not allowed
  )
{
  key CompanyCode,
  
      ParentCompanyCode,
      CompanyName,
      CountryKey
}
