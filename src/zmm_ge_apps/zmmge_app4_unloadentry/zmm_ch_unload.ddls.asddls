@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Unloading Yard - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZMM_CH_UNLOAD
  provider contract transactional_query
  as projection on ZMM_IH_UNLOAD
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
      Weighmentmcno,
      Weighmentmcndes,
      Weighuom,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      Grosswt,
      Weighmentdate,
      Weighmenttime,
      Imagevaldindicator,
      Exitindicator,
      Gateexitdate,
      Gateexittime,
      Gateexitindicator,
      Gateidstatus,
      Gateidname,
      Materialdocument,
      Materialdocumentyear,
      Unloadstdate,
      Unloadsttime,
      Unloadstindi,
      Unloadenddate,
      Unloadendtime,
      Unloadendindi,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _Item : redirected to composition child ZMM_CI_UNLOAD
}
