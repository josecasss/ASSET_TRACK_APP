    @AccessControl.authorizationCheck: #NOT_REQUIRED
    @EndUserText.label: 'Asset Tracker - Company Code Root View'
    @Metadata.ignorePropagatedAnnotations: true
    define root view entity ZR_ASSET_COMPCODE
      as select from zasset_compcode
      association of many to one ZR_ASSET_COMPCODE as _ParentNode
        on $projection.ParentCompanyCode = _ParentNode.CompanyCode
    {
      key company_code        as CompanyCode,
          parent_company_code as ParentCompanyCode,
          company_name        as CompanyName,
          country_key         as CountryKey,
          currency            as Currency,
          _ParentNode
    }
