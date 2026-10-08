@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Dispatch Planning Header'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSD_CH_DISPLAN
  provider contract transactional_query
  as projection on ZSD_IH_DISPLAN
{
  key Uuid,
      @EndUserText.label: 'Attachments'
      @Semantics.largeObject:{ fileName: 'Filename',
                               acceptableMimeTypes: [ 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
                               mimeType: 'Minetype',
                               contentDispositionPreference: #INLINE }
      Attachment,
      @Semantics.mimeType: true
      Minetype,
      Filename,
      Status,
      @ObjectModel.text.element: [ 'PersonFullName' ]
      Createdby,
      PersonFullName,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      UploadStatus,
      /* Associations */
      _SalesItem : redirected to composition child ZSD_CI_DISPLAN
}
