@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Weight Recording Head - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMM_CH_WEIGHT
  provider contract transactional_query
  as projection on ZMM_IH_WEIGHT
{
  key Uuid,
      @ObjectModel.text.element: [ 'Gatenodes' ]
      Gateno,
      Gatenodes,
      Gateentryno,
      Gateentryseqno,
      Gateentrydate,
      Gateentrytime,
      Gateentryid,
      Gateentryiddate,
      @ObjectModel.text.element: [ 'Plantname' ]
      Plant,
      Plantname,
      @ObjectModel.text.element: [ 'Gateentryseriesdes' ]
      Gateentryseries,
      Gateentryseriesdes,
      Permitno,
      Tokenentryno,
      Erpreferenceno,
      Trasporterid,
      Trasportername,
      Vehicleno,
      @ObjectModel.text.element: [ 'vehicletypedescription' ]
      Vehicletype,
      vehicletypedescription,
      Drivername,
      Mobile,
      Licenseno,
      Experiredt,
      Chaseno,
      Address,
      Challanno,
      Challandate,
      Lrno,
      Lrdate,
      Securityremarks,
      Referno,
      Referdate,
      Fromplace,
      Toplace,
      Freightorderno,
      Helpername,
      Minepassno,
      Forestpassno,
      Rakecontno,
      Createdname,
      Weighmentindicator,
      @ObjectModel.text.element: [ 'weighmentmcndes' ]
      Weighmentmcno,
      weighmentmcndes,
      Weighuom,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      Grosswt,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      Tarewt,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      Netwt,
      Weighmentdate,
      Weighmenttime,
      Imagevaldindicator,
      @Semantics.largeObject: { mimeType: 'Weighmimetype',
                                fileName: 'Weighfilename',
                                contentDispositionPreference: #INLINE }
      Weighslipattcmt,
      Weighfilename,
      Weighmimetype,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      GateEntryStatus,
      ImageValStatus,
      Unldstartsts,
      Unldendsts,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      DecTareWt,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      DecNetWt,
      /* Associations */
      _Item : redirected to composition child ZMM_CI_WEIGHT
}
