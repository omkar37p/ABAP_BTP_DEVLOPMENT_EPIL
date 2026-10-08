@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Outgoing Gate Exit Item - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSD_CI_GEXIT
  as projection on ZSD_II_GEXIT
{
  key Uuid,
  key Salesdocument,
  key Salesitem,
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
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _Head : redirected to parent ZSD_CH_GEXIT
}
