@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Draft Query View'
//@Metadata.ignorePropagatedAnnotations: true

define view entity ZASSET_TRACK_QUERY_01 as select from zasset_dfc
{
 key uuid as Uuid,
 assettagnumber as Assettagnumber,
 assetdescription as Assetdescription,
 companycode as Companycode,
 mainassetnumber as Mainassetnumber,
 assetsubnumber as Assetsubnumber,
 status as Status,
 creationdate as Creationdate,
 changeddate as Changeddate,
 localcreatedby as Localcreatedby,
 localcreatedat as Localcreatedat,
 locallastchangedby as Locallastchangedby,
 locallastchangedat as Locallastchangedat,
 lastchangedat as Lastchangedat,
 draftentitycreationdatetime as Draftentitycreationdatetime,
 draftentitylastchangedatetime as Draftentitylastchangedatetime,
 draftadministrativedatauuid as Draftadministrativedatauuid,
 draftentityoperationcode as Draftentityoperationcode,
 hasactiveentity as Hasactiveentity,
 draftfieldchanges as Draftfieldchanges
}
