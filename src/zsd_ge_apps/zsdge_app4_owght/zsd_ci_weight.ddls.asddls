@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Outgoing Weighment Recording - Item Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSD_CI_WEIGHT
  as projection on ZSD_II_WEIGHT
{
  key     Uuid,
  key     Salesdocument,
  key     Salesitem,
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
          Ordertype,
          Distributionchannel,
          Shippingpoint,
          OpenQty,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SD_SOUPD_OPENQTY_CALC'
  virtual OpenQtyLive : abap.dec(15,3),
          @ObjectModel.text.element: [ 'Weighmentmcndes' ]
          Weighmentmcno,
          Weighmentmcndes,
          Independentrequirementtype,
          Itemimagecount,
          Createdby,
          Createdat,
          Lastchangedby,
          Lastchangedat,
          /* Associations */
          _Head : redirected to parent ZSD_CH_WEIGHT
}
