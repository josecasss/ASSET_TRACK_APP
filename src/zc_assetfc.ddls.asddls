@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText: { label: 'Consumption Entity - Tracking Asset'}
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_ASSETFC
  provider contract transactional_query
  as projection on ZR_ASSETFC
{
  key UUID,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @ObjectModel.text.element: ['AssetDescription']
      AssetTagNumber,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      AssetDescription,

      @ObjectModel.text.element: ['CompanyName']
      CompanyCode,
      _CompanyCode.CompanyName      as CompanyName,

      MainAssetNumber,
      AssetSubNumber,

      @ObjectModel.text.element: ['AssetStatusDescription']
      Status,
      _AssetStatusCodes.StatusDescription  as AssetStatusDescription,
      _StatusCriticality.Criticality       as StatusCriticality,

      CreationDate,
      ChangedDate,

      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,

      _AssetHistory : redirected to composition child ZC_ASSETHISTORYFC,
      _Attachment   : redirected to composition child ZC_AssetAttachmentTP
}
