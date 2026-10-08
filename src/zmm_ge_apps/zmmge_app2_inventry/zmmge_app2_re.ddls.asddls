@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root entity - Inventory Entry App'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMMGE_APP2_RE
  as select from zmmge_hdr_t01  as a
  association [1..1] to ZGATE_VETYPE_VH as _Vhtype on $projection.Vehicletype = _Vhtype.value_low  
  composition [0..*] of ZMMGE_APP2_IV1 as _Item
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
      _Vhtype.text as   vehicletypedescription,
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
      a.weighmentmcndes      as weighmentmcndes,
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
      a.materialdocument     as Materialdocument,
      a.materialdocumentyear as Materialdocumentyear,
      a.entryslipattcmt      as Entryslipattcmt,
      a.entrymimetype        as Entrymimetype,
      a.entryfilename        as Entryfilename,
      @Semantics.user.createdBy: true
      a.createdby            as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat            as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby        as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat        as Lastchangedat,
      case
        when a.gateentryno is not initial then 'CheckIn Completed'
        else 'CheckIn Not Completed'
      end                    as CheckInStatus,
      case
        when a.gateentryno is not initial then 'Gate Entry No'
        else 'Gate Entry No'
      end                    as GateEntryStatus,
      case
        when a.materialdocument is not initial then 'MIGO Posted'
        else 'MIGO Not Posted'
      end                    as MigoStatus,
      _Item
}
