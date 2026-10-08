@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Unloading Yard - Apps'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMM_IH_UNLOAD
  as select from zmmge_hdr_t01 as a
  composition [0..*] of ZMM_II_UNLOAD as _Item
{
  key a.uuid                 as Uuid,
      a.gateno               as Gateno,
      a.gatenodes            as Gatenodes,
      a.gateentryno          as Gateentryno,
      a.gateentryseqno       as Gateentryseqno,
      a.gateentrydate        as Gateentrydate,
      a.gateentrytime        as Gateentrytime,
      a.gateentryid          as Gateentryid,
      a.gateentryiddate      as Gateentryiddate,
      a.plant                as Plant,
      a.plantname            as Plantname,
      a.gateentryseries      as Gateentryseries,
      a.gateentryseriesdes   as Gateentryseriesdes,
      a.permitno             as Permitno,
      a.tokenentryno         as Tokenentryno,
      a.erpreferenceno       as Erpreferenceno,
      a.trasporterid         as Trasporterid,
      a.trasportername       as Trasportername,
      a.vehicleno            as Vehicleno,
      a.vehicletype          as Vehicletype,
      a.drivername           as Drivername,
      a.mobile               as Mobile,
      a.licenseno            as Licenseno,
      a.experiredt           as Experiredt,
      a.chaseno              as Chaseno,
      a.address              as Address,
      a.challanno            as Challanno,
      a.challandate          as Challandate,
      a.lrno                 as Lrno,
      a.lrdate               as Lrdate,
      a.securityremarks      as Securityremarks,
      a.referno              as Referno,
      a.referdate            as Referdate,
      a.fromplace            as Fromplace,
      a.toplace              as Toplace,
      a.freightorderno       as Freightorderno,
      a.helpername           as Helpername,
      a.minepassno           as Minepassno,
      a.forestpassno         as Forestpassno,
      a.rakecontno           as Rakecontno,
      a.createdname          as Createdname,
      a.weighmentindicator   as Weighmentindicator,
      a.weighmentmcno        as Weighmentmcno,
      a.weighmentmcndes      as Weighmentmcndes,
      a.weighuom             as Weighuom,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      a.grosswt              as Grosswt,
      a.weighmentdate        as Weighmentdate,
      a.weighmenttime        as Weighmenttime,
      a.imagevaldindicator   as Imagevaldindicator,
      a.exitindicator        as Exitindicator,
      a.gateexitdate         as Gateexitdate,
      a.gateexittime         as Gateexittime,
      a.gateexitindicator    as Gateexitindicator,
      a.gateidstatus         as Gateidstatus,
      a.gateidname           as Gateidname,
      a.materialdocument     as Materialdocument,
      a.materialdocumentyear as Materialdocumentyear,
      a.unloadstdate         as Unloadstdate,
      a.unloadsttime         as Unloadsttime,
      a.unloadstindi         as Unloadstindi,
      a.unloadenddate        as Unloadenddate,
      a.unloadendtime        as Unloadendtime,
      a.unloadendindi        as Unloadendindi,
      @Semantics.user.createdBy: true
      a.createdby            as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat            as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby        as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat        as Lastchangedat,
      _Item
}
where
      a.grosswt   is not initial
  and a.vehicleno is not initial
