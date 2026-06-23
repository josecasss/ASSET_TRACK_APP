@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status Criticality Helper'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_STATUS_CRIT_FC
  as select from zasset_status
{
  key status_code as StatusCode,
      case status_code
        when '00' then 3
        when '01' then 1
        when '02' then 2
        when '03' then 1
        when '04' then 0
        else 0
      end         as Criticality
}
