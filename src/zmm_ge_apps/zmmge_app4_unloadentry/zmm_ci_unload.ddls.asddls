@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Unloading Yard - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_CI_UNLOAD
  as projection on ZMM_II_UNLOAD
{
  key Uuid,
  key Purchaseorder,
  key Purchaseorderitem,
      Vendor,
      Suppliername,
      Gateentryno,
      Material,
      Materialtext,
      Plant,
      Plantname,
      Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Quantity,
      Remark,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Tareweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Grossweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Netweight,
      Unloadind,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _Head : redirected to parent ZMM_CH_UNLOAD
}
