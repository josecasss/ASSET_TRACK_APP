@AccessControl.authorizationCheck: #MANDATORY
@EndUserText: { label: 'Consumption Entity - Tracking Asset'}
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel: { sapObjectNodeType.name: 'ZAsset_FCFC'}

@Search.searchable: true //Activa busqueda avanzada (Es ese campo que busca todo, que esta al inicio)
@Metadata.allowExtensions: true

define root view entity ZC_ASSETFC
  provider contract transactional_query
  as projection on ZR_ASSETFC
  association [1..1] to ZR_ASSETFC as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
      @Search.defaultSearchElement: true          //Para busqueda
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH                      //Importancia para la busqueda avanzada
      @ObjectModel.text.element: ['AssetDescription']  //Concatenar texto, con campos (Se pueden concatenar mas con comas) como se ve      
      AssetTagNumber,
      
 
      

//      ZR_ASSETFC.AssetTagNumber as AssetTagNumberD,
      
      
      @Search.defaultSearchElement: true          //Para busqueda
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH                      //Importancia para la busqueda avanzada
      AssetDescription,
      
      CompanyCode,
      MainAssetNumber,
      AssetSubNumber,
      
      @ObjectModel.text.element: ['AssetStatusDescription']  //Concatenar texto, con campos (Se pueden concatenar mas con comas) como se ve      
      Status,
      _AssetStatusCodes.StatusDescription as AssetStatusDescription,
      
      CreationDate,
      ChangedDate,
      @Semantics: { user.createdBy: true}
      LocalCreatedBy,
      @Semantics: { systemDateTime.createdAt: true }
      LocalCreatedAt,
      @Semantics: { user.localInstanceLastChangedBy: true}
      LocalLastChangedBy,
      @Semantics: { systemDateTime.localInstanceLastChangedAt: true }
      LocalLastChangedAt,
      @Semantics: { systemDateTime.lastChangedAt: true}
      LastChangedAt,
      _AssetHistory : redirected to composition child ZC_ASSETHISTORYFC,
      _BaseEntity
}
