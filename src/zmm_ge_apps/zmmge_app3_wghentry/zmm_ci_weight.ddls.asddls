@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Weight Recording Item - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMM_CI_WEIGHT
  as projection on ZMM_II_WEIGHT
{
  key Uuid,
  key Purchaseorder,
  key Purchaseorderitem,
      Vendor,
      Suppliername,
      Gateentryno,
      Subgateentryno,
      @ObjectModel.text.element: [ 'Materialtext' ]
      Material,
      Materialtext,
      Plant,
      Plantname,
      Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Quantity,
      Remark,
      Weiuom,
      @Semantics.quantity.unitOfMeasure: 'Weiuom'
      Tareweight,
      @Semantics.quantity.unitOfMeasure: 'Weiuom'
      Grossweight,
      @Semantics.quantity.unitOfMeasure: 'Weiuom'
      Netweight,
      Chbaseunit,
      Challanno,
      Challandate,
      @Semantics.quantity.unitOfMeasure: 'Chbaseunit'
      Challantareweight,
      @Semantics.quantity.unitOfMeasure: 'Chbaseunit'
      Challangrossweight,
      @Semantics.quantity.unitOfMeasure: 'Chbaseunit'
      Challannetweight,
      Chqtyunit,
      @Semantics.quantity.unitOfMeasure: 'Chqtyunit'
      Challanqty,
      Grnqty,
      @ObjectModel.text.element: [ 'Poordertypetext' ]
      Poordertype,
      Poordertypetext,
      Ewaybillno,
      Ewaybilldate,
      Orderdate,
      Podocumt,
      Chdocumt,
      Sidocumt,
      Qadocumt,
      Unloadind,
      Materialgroup,
      Weighmentdate,
      Weighmenttime,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _Head : redirected to parent ZMM_CH_WEIGHT
}
