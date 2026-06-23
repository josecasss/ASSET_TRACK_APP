@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Asset Tracker - Attachments'
@Metadata.allowExtensions: true

define view entity ZI_AssetAttachmentTP
  as select from zasset_attachm as Attachment

  association to parent ZR_ASSETFC as _Asset
    on $projection.UUID = _Asset.UUID

{
  key attach_uuid           as AttachUUID,
      parent_uuid           as UUID,
      file_content          as FileContent,
      mime_type             as MimeType,
      file_name             as FileName,
      file_size             as FileSize,

      @Semantics.user.createdBy: true
      local_created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Asset
}
