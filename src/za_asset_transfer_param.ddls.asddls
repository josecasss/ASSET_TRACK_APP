@EndUserText.label: 'Transfer Asset - Action Parameters'
  define abstract entity ZA_ASSET_TRANSFER_PARAM {
    @EndUserText.label: 'New Company Code'
    @Consumption.valueHelpDefinition: [{ entity:                      { name: 'ZC_ASSET_CCVH', element: 'CompanyCode' },
                                          presentationVariantQualifier: 'HIERARCHY',
                                          label:                        'Company Code' }]
    NewCompanyCode : bukrs;

    @EndUserText.label: 'Transfer Note'
    TransferNote   : abap.char(40);
  }
