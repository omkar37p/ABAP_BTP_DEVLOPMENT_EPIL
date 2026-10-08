@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Dispatch Planning Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSD_II_DISPLAN
  as select from zsdge_dplst_it1 as a
  association to parent ZSD_IH_DISPLAN as _Head on $projection.Uuid = _Head.Uuid
{
  key a.uuid           as Uuid,
  key a.salesorder     as Salesorder,
  key a.salesorderitem as Salesorderitem,
      a.slno           as Slno,
      a.dispatchdate   as Dispatchdate,
      a.customer       as Customer,
      a.plant          as Plant,
      a.transmode      as Transmode,
      a.material       as Material,
      a.baseunit       as Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.totalorderqty  as Totalorderqty,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      a.dispplantqty   as Dispplantqty,
      a.vehicleno      as Vehicleno,
      @Semantics.user.createdBy: true
      a.createdby      as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat      as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby  as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat  as Lastchangedat,
      _Head
}
