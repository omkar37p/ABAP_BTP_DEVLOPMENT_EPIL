@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry Apps - Dispatch'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_IH_GATE
  as select from zsdge_sentry_ht1 as a
  composition [0..*] of ZSD_II_GATE as _Item
{
  key a.uuid                                                     as Uuid,
      a.gateno                                                   as Gateno,
      a.gatenodes                                                as Gatenodes,
      a.plant                                                    as Plant,
      a.plantname                                                as Plantname,
      a.gateentryid                                              as Gateentryid,
      a.gateentryiddate                                          as Gateentryiddate,
      a.gateentryidtime                                          as Gateentryidtime,
      a.gateentrytype                                            as Gateentrytype,
      a.gateentrytypetext                                        as Gateentrytypetext,
      a.gateentryno                                              as Gateentryno,
      a.gateentrysequence                                        as Gateentrysequence,
      a.gateentrydate                                            as Gateentrydate,
      a.gateentrytime                                            as Gateentrytime,
      a.transportid                                              as Transportid,
      a.transportname                                            as Transportname,
      a.vehicleno                                                as Vehicleno,
      a.packingdetails                                           as Packingdetails,
      a.dispinstrdetails                                         as Dispinstrdetails,
      a.contactdetails                                           as Contactdetails,
      a.drivername                                               as Drivername,
      a.driveraddress                                            as Driveraddress,
      a.driverlicensenumber                                      as Driverlicensenumber,
      a.drivermobile                                             as Drivermobile,
      a.remarks                                                  as Remarks,
      a.customer                                                 as Customer,
      a.customername                                             as Customername,
      a.fromplace                                                as Fromplace,
      a.billingfrom                                              as Billingfrom,
      a.consignee                                                as Consignee,
      a.billto                                                   as Billto,
      a.broker                                                   as Broker,
      a.doremark                                                 as Doremark,
      a.division                                                 as Division,
      a.attachment                                               as Attachment,
      @Semantics.mimeType: true
      a.mimetype                                                 as Mimetype,
      a.filename                                                 as Filename,
      a.weigmentindicator                                        as Weigmentindicator,
      a.modeoftransport                                          as Modeoftransport,
      a.modeoftransporttext                                      as Modeoftransporttext,
      a.trandocno                                                as Trandocno,
      a.trandocdate                                              as Trandocdate,
      a.vehicletype                                              as Vehicletype,
      a.vehicleengno                                             as Vehicleengno,
      a.vehiclecapqty                                            as Vehiclecapqty,
      a.chassisno                                                as Chassisno,
      a.insuranceno                                              as Insuranceno,
      a.fitcertificate                                           as Fitcertificate,
      a.attachmentload                                           as Attachmentload,
      a.filenameload                                             as Filenameload,
      @Semantics.mimeType: true
      a.mimetypeload                                             as Mimetypeload,
      a.quality                                                  as Quality,
      a.cancelgateentry                                          as Cancelgateentry,
      @Semantics.user.createdBy: true
      a.createdby                                                as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat                                                as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby                                            as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat                                            as Lastchangedat,

      cast( case when a.cancelgateentry = 'X' then 'Gate Entry Cancelled'
                 else 'Gate Entry Active' end as abap.char(20) ) as Gateentrystatus,

      cast( case when a.cancelgateentry = 'X' then 1
                 else 3 end as abap.int1 )                       as Criticality,

      _Item
}
where
  a.gateentryid is not initial
