@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Outgoing Gate Exit Head - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZSD_CH_GEXIT
  provider contract transactional_query
  as projection on ZSD_IH_GEXIT
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
      @ObjectModel.text.element: [ 'Transportname' ]
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
      Weigmentindicator,
      Weighmentindicator,
      @ObjectModel.text.element: [ 'Weighmentmcndes' ]
      Weighmentmcno,
      Weighmentmcndes,
      Weighmentdate,
      Weighmenttime,
      Weighuom,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      Tarewt,
      Transferexit,
      Gateexitdate,
      Gateexittime,
      Billingdocument,
      Billingdocumentdate,
      Einvoiceno,
      Einvoicedate,
      Ewaybillno,
      Ewaybilldate,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _Item : redirected to composition child ZSD_CI_GEXIT
}
