@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection entity - Security Entry App'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMMGE_APP1_PE
  provider contract transactional_query
  as projection on ZMMGE_APP1_RE as GateEntry
{
  key Uuid,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'Gatenodes' ]            
      GateNo,

      Gatenodes,
      GateEntryNo,
      GateEntrySequenceNo,
      GateEntryDate,
      GateEntryTime,
      GateEntryId,
      GateEntryIdDate,

      @Search.defaultSearchElement: true
      Plant,

      PlantName,
      @ObjectModel.text.element: [ 'Gateentryseriesdes' ]                  
      GateEntrySeries,
      Gateentryseriesdes,
      PermitNo,
      TokenEntryNo,
      ErpReferenceNo,
      @ObjectModel.text.element: [ 'Transportname' ]                        
      Trasporterid,
      Transportname,

      @Search.defaultSearchElement: true
      VehicleNo,
      @ObjectModel.text.element: [ 'VehicleTypeDescription' ]                  
      VehicleType,
      VehicleTypeDescription,
      DriverName,
      Mobile,
      LicenseNo,
      Experiredt,
      Chaseno,
      Address,
      ChallanNo,
      ChallanDate,
      LrNo,
      LrDate,
      SecurityRemarks,
      ReferenceNo,
      ReferenceDate,
      FromPlace,
      ToPlace,
      FreightOrderNo,
      HelperName,
      MinePassNo,
      ForestPassNo,
      RakeContainerNo,
      Createdname,
      WeighmentIndicator,
      WeighmentMachineNo,
      WeighmentMachineDescription,
      WeightUnit,
      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      GrossWeight,
      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      TareWeight,
      @Semantics.quantity.unitOfMeasure: 'WeightUnit'
      NetWeight,
      WeighmentDate,
      WeighmentTime,
      ImageValidationIndicator,
      ExitIndicator,
      GateExitDate,
      GateExitTime,
      GateExitIndicator,
      GateIdStatus,
      GateIdName,
      MaterialDocument,
      MaterialDocumentYear,
      UnloadStartDate,
      UnloadStartTime,
      UnloadStartIndicator,
      UnloadEndDate,
      UnloadEndTime,
      UnloadEndIndicator,
      EntrySlipAttachment,
      EntrySlipMimeType,
      EntrySlipFileName,
      WeighSlipAttachment,
      WeighSlipMimeType,
      WeighSlipFileName,
      UnloadStartStatus,
      UnloadEndStatus,
      CheckInStatus,

      @Search.defaultSearchElement: true
      GateEntryStatus,

      MigoStatus,
      ImageValidationStatus,
      ExitStatus,
      NetWeightDecimal,
      TareWeightDecimal,
      Engineno,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt

}
