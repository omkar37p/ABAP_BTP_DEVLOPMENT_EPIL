@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incoming Gate Unloading Yard - Apps'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_II_UNLOAD
  as select from zmmge_itm_t01 as a
  association to parent ZMM_IH_UNLOAD as _Head on $projection.Uuid = _Head.Uuid
{
  key a.uuid              as Uuid,
  key a.purchaseorder     as Purchaseorder,
  key a.purchaseorderitem as Purchaseorderitem,
      a.vendor            as Vendor,
      a.suppliername      as Suppliername,
      a.gateentryno       as Gateentryno,
      a.material          as Material,
      a.materialtext      as Materialtext,
      a.plant             as Plant,
      a.plantname         as Plantname,
      a.baseunit          as Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.quantity          as Quantity,
      a.remark            as Remark,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.tareweight        as Tareweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.grossweight       as Grossweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.netweight         as Netweight,
      a.unloadind         as Unloadind,
      @Semantics.user.createdBy: true
      a.createdby         as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat         as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby     as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat     as Lastchangedat,
      _Head
}
