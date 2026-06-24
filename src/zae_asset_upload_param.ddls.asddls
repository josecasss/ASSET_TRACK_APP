@EndUserText.label: 'Asset Excel Upload Parameters'
define abstract entity ZAE_ASSET_UPLOAD_PARAM
{
  mime_type    : abap.string(0);
  file_name    : abap.string(0);
  file_content : abap.rawstring(0);
}
