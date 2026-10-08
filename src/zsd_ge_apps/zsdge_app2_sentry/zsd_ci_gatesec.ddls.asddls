@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Outgoing Gate Security Item - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSD_CI_GATESEC
  as projection on ZSD_II_GATESEC
{
  key Uuid,
  key Salesdocument,
  key Salesitem,
      @ObjectModel.text.element: [ 'Customername' ]
      Customer,
      Customername,
      Gateentryno,
      @ObjectModel.text.element: [ 'Plantname' ]
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
      Ordertype,
      Distributionchannel,
      Openqty,
      Shippingpoint,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _Header : redirected to parent ZSD_CH_GATESEC
}
