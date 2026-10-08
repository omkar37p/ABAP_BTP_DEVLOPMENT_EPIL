    @AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Root entity - Security Entry App'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.compositionRoot: true
//@ObjectModel.semanticKey: 'GateNo'
define root view entity ZMMGE_APP1_RE
  as select from zmmge_hdr_t01
  association [1..1] to ZGATE_VETYPE_VH as _Vhtype on $projection.VehicleType = _Vhtype.value_low
{
  key uuid                 as Uuid,
      @ObjectModel.text.element: [ 'Gatenodes' ]
      gateno               as GateNo,
      gatenodes            as Gatenodes,
      gateentryno          as GateEntryNo,
      gateentryseqno       as GateEntrySequenceNo,
      gateentrydate        as GateEntryDate,
      gateentrytime        as GateEntryTime,
      gateentryid          as GateEntryId,
      gateentryiddate      as GateEntryIdDate,
      @ObjectModel.text.element: [ 'PlantName' ]
      plant                as Plant,
      plantname            as PlantName,
      @ObjectModel.text.element: [ 'Gateentryseriesdes' ]
      gateentryseries      as GateEntrySeries,
      gateentryseriesdes   as Gateentryseriesdes,
      permitno             as PermitNo,
      tokenentryno         as TokenEntryNo,
      erpreferenceno       as ErpReferenceNo,
      @ObjectModel.text.element: [ 'Transportname' ]
      trasporterid         as Trasporterid,
      trasportername       as Transportname,
      vehicleno            as VehicleNo,
      @ObjectModel.text.element: [ 'VehicleTypeDescription' ]
      vehicletype          as VehicleType,
      _Vhtype.text       as VehicleTypeDescription,
      drivername           as DriverName,
      mobile               as Mobile,
      licenseno            as LicenseNo,
      experiredt           as Experiredt,
      chaseno              as Chaseno,
      address              as Address,
      challanno            as ChallanNo,
      challandate          as ChallanDate,
      lrno                 as LrNo,
      lrdate               as LrDate,
      securityremarks      as SecurityRemarks,
      referno              as ReferenceNo,
      referdate            as ReferenceDate,
      fromplace            as FromPlace,
      toplace              as ToPlace,
      freightorderno       as FreightOrderNo,
      helpername           as HelperName,
      minepassno           as MinePassNo,
      forestpassno         as ForestPassNo,
      rakecontno           as RakeContainerNo,
      createdname          as Createdname,

      weighmentindicator   as WeighmentIndicator,
      weighmentmcno        as WeighmentMachineNo,
      weighmentmcndes      as WeighmentMachineDescription,
      weighuom             as WeightUnit,

      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      grosswt              as GrossWeight,

      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      tarewt               as TareWeight,

      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      netwt                as NetWeight,

      weighmentdate        as WeighmentDate,
      weighmenttime        as WeighmentTime,
      imagevaldindicator   as ImageValidationIndicator,
      exitindicator        as ExitIndicator,
      gateexitdate         as GateExitDate,
      gateexittime         as GateExitTime,
      gateexitindicator    as GateExitIndicator,
//      gateidstatus         as GateIdStatus,
      gateidname           as GateIdName,
      materialdocument     as MaterialDocument,
      materialdocumentyear as MaterialDocumentYear,
      unloadstdate         as UnloadStartDate,
      unloadsttime         as UnloadStartTime,
      unloadstindi         as UnloadStartIndicator,
      unloadenddate        as UnloadEndDate,
      unloadendtime        as UnloadEndTime,
      unloadendindi        as UnloadEndIndicator,
      entryslipattcmt      as EntrySlipAttachment,
      entrymimetype        as EntrySlipMimeType,
      entryfilename        as EntrySlipFileName,
      weighslipattcmt      as WeighSlipAttachment,
      weighmimetype        as WeighSlipMimeType,
      weighfilename        as WeighSlipFileName,
      unldstartsts         as UnloadStartStatus,
      unldendsts           as UnloadEndStatus,
      checkinstatus        as CheckInStatus,
      gateentrystatus      as GateEntryStatus,
      migostatus           as MigoStatus,
      imagevalstatus       as ImageValidationStatus,
      exitstatus           as ExitStatus,
      decnetwt             as NetWeightDecimal,
      dectarewt            as TareWeightDecimal,
      engineno             as Engineno,
      @Semantics.user.createdBy: true
      createdby            as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      createdat            as CreatedAt,

      @Semantics.user.lastChangedBy: true
      lastchangedby        as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat        as LastChangedAt,
      case
        when gateentryid is not initial then 'Gate ID Created'
        else 'Gate ID Not Created'
        end as GateIDStatus

}
