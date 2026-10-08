@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Security Exit - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMM_CH_GEXIT
  provider contract transactional_query
  as projection on ZMM_IH_GEXIT
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
      @ObjectModel.text.element: [ 'Trasportername' ]
      Trasporterid,
      Trasportername,
      Vehicleno,
      Vehicletype,
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
      @ObjectModel.text.element: [ 'Weighmentmcndes' ]
      Weighmentmcno,
      Weighmentmcndes,
      Weighuom,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      Grosswt,
      Weighmentdate,
      Weighmenttime,
      Imagevaldindicator,
      Gateexitdate,
      Gateexittime,
      Gateexitindicator,
      Exitindicator,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      GateEntryStatus,
      ExitStatus,
      ImageValStatus,
      /* Associations */
      _Item : redirected to composition child ZMM_CI_GEXIT
}
