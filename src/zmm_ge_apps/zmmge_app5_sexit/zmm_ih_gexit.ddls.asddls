@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Security Exit - Apps'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMM_IH_GEXIT
  as select from zmmge_hdr_t01 as a
  composition [0..*] of ZMM_II_GEXIT as _Item
{
  key a.uuid               as Uuid,
      a.gateno             as Gateno,
      a.gatenodes          as Gatenodes,
      a.gateentryno        as Gateentryno,
      a.gateentryseqno     as Gateentryseqno,
      a.gateentrydate      as Gateentrydate,
      a.gateentrytime      as Gateentrytime,
      a.gateentryid        as Gateentryid,
      a.gateentryiddate    as Gateentryiddate,
      a.plant              as Plant,
      a.plantname          as Plantname,
      a.gateentryseries    as Gateentryseries,
      a.gateentryseriesdes as Gateentryseriesdes,
      a.permitno           as Permitno,
      a.tokenentryno       as Tokenentryno,
      a.erpreferenceno     as Erpreferenceno,
      a.trasporterid       as Trasporterid,
      a.trasportername     as Trasportername,
      a.vehicleno          as Vehicleno,
      a.vehicletype        as Vehicletype,
      a.drivername         as Drivername,
      a.mobile             as Mobile,
      a.licenseno          as Licenseno,
      a.experiredt         as Experiredt,
      a.chaseno            as Chaseno,
      a.address            as Address,
      a.challanno          as Challanno,
      a.challandate        as Challandate,
      a.lrno               as Lrno,
      a.lrdate             as Lrdate,
      a.securityremarks    as Securityremarks,
      a.referno            as Referno,
      a.referdate          as Referdate,
      a.fromplace          as Fromplace,
      a.toplace            as Toplace,
      a.freightorderno     as Freightorderno,
      a.helpername         as Helpername,
      a.minepassno         as Minepassno,
      a.forestpassno       as Forestpassno,
      a.rakecontno         as Rakecontno,
      a.createdname        as Createdname,
      a.weighmentindicator as Weighmentindicator,
      a.weighmentmcno      as Weighmentmcno,
      a.weighmentmcndes    as Weighmentmcndes,
      a.weighuom           as Weighuom,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      a.grosswt            as Grosswt,
      a.weighmentdate      as Weighmentdate,
      a.weighmenttime      as Weighmenttime,
      a.imagevaldindicator as Imagevaldindicator,
      a.gateexitdate       as Gateexitdate,
      a.gateexittime       as Gateexittime,
      a.gateexitindicator  as Gateexitindicator,
      a.exitindicator      as Exitindicator,
      @Semantics.user.createdBy: true
      a.createdby          as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat          as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby      as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat      as Lastchangedat,
      case
        when a.gateentryno is not initial then 'Gate Entry No'
        else 'Gate Entry No'
      end                  as GateEntryStatus,
      case
        when a.gateexitindicator is not initial then 'Gate Exit Completed'
        else 'Gate Exit Not Completed'
      end                  as ExitStatus,
      case
        when a.exitindicator = 'X' then 'Image Validation Completed'
        else 'Image Validation Not Completed'
      end                  as ImageValStatus,
      _Item
}
where
  a.imagevaldindicator = 'X'
