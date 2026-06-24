@AccessControl.authorizationCheck: #NOT_ALLOWED
@EndUserText.label: 'Asset Tracker - Attachments Projection'
@Metadata.allowExtensions: true

define view entity ZC_AssetAttachmentTP
  as projection on ZI_AssetAttachmentTP

{
  key AttachUUID,
      UUID,

      @EndUserText.label: 'File'
      @Semantics.largeObject: {
        mimeType                    : 'MimeType',
        fileName                    : 'FileName',
        acceptableMimeTypes         : [ 'application/pdf',
                                        'image/png',
                                        'image/jpeg',
                                        'text/plain',
                                        'application/vnd.ms-excel',
                                        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
        contentDispositionPreference: #ATTACHMENT
      }
      FileContent,

      @Semantics.mimeType: true
      MimeType,
      FileName,
      FileSize,

      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LastChangedAt,

      _Asset: redirected to parent ZC_ASSETFC
}
