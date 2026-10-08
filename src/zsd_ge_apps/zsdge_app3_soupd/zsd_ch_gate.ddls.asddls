@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gate Entry Apps - Dispatch'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSD_CH_GATE
  provider contract transactional_query
  as projection on ZSD_IH_GATE
{
  key Uuid,
      @ObjectModel.text.element: [ 'Gatenodes' ]
      Gateno,
      Gatenodes,
      @ObjectModel.text.element: [ 'Plantname' ]
      Plant,
      Plantname,
      Gateentryid,
      Gateentryiddate,
      Gateentryidtime,
      @ObjectModel.text.element: [ 'Gateentrytypetext' ]
      Gateentrytype,
      Gateentrytypetext,
      Gateentryno,
      Gateentrysequence,
      Gateentrydate,
      Gateentrytime,
      Transportid,
      Transportname,
      Vehicleno,
      Packingdetails,
      Dispinstrdetails,
      Contactdetails,
      Drivername,
      Driveraddress,
      Driverlicensenumber,
      Drivermobile,
      Remarks,
      @ObjectModel.text.element: [ 'Customername' ]
      Customer,
      Customername,
      Fromplace,
      Billingfrom,
      Consignee,
      Billto,
      Broker,
      Doremark,
      Division,
      Attachment,
      Mimetype,
      Filename,
      @ObjectModel.text.element: [ 'Modeoftransporttext' ]
      Modeoftransport,
      Modeoftransporttext,
      Trandocno,
      Trandocdate,
      Vehicletype,
      Vehicleengno,
      Vehiclecapqty,
      Chassisno,
      Insuranceno,
      Fitcertificate,
      @Semantics.largeObject: { mimeType: 'Mimetypeload',
                                fileName: 'Filenameload',
                                contentDispositionPreference: #INLINE }
      Attachmentload,
      Filenameload,
      Mimetypeload,
      Quality,
      Cancelgateentry,
      Gateentrystatus,
      Criticality,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _Item : redirected to composition child ZSD_CI_GATE
}
