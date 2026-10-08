@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Outgoing Loading Yard - Gate Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSD_CI_LOAD
  as projection on ZSD_II_LOAD
{
  key Uuid,
  key Salesdocument,
  key Salesitem,
      Customer,
      Customername,
      Gateentryno,
      Plant,
      Plantname,
      Material,
      Materialdesc,
      Baseunit,
      Batch,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Quantity,
      Remark,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Tareweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Grossweight,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Netweight,
      Storagelocation,
      Deliveryno,
      Deliveritem,
      Itemimagecount,
      Loadcheck,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _Head : redirected to parent ZSD_CH_LOAD
}
