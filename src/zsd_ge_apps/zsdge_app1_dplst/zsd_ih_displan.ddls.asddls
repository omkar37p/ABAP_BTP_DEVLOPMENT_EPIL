@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Dispatch Planning Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_IH_DISPLAN
  as select from    zsdge_dplst_ht1     as a
    left outer join I_BusinessUserBasic as b on b.UserID = a.createdby
  composition [0..*] of ZSD_II_DISPLAN as _SalesItem
{
  key a.uuid                      as Uuid,
      @EndUserText.label: 'Attachments'
      @Semantics.largeObject:{ fileName: 'Filename',
                               acceptableMimeTypes: [ 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
                               mimeType: 'Minetype',
                               contentDispositionPreference: #INLINE }
      a.attachment                as Attachment,
      @Semantics.mimeType: true
      a.minetype                  as Minetype,
      a.filename                  as Filename,
      a.status                    as Status,
      @Semantics.user.createdBy: true
      a.createdby                 as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat                 as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby             as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat             as Lastchangedat,
      b.PersonFullName            as PersonFullName,
      cast( case
              when a.status = 'X' then 'Active'
              else 'Inactive'
            end as abap.char(8) ) as UploadStatus,

      _SalesItem
}
