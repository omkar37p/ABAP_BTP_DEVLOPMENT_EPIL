@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Team Gate Entry Item - Apps'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZMMGE_APP2_PV1
  as projection on ZMMGE_APP2_IV1
{
  key     Uuid,
  key     Purchaseorder,
  key     Purchaseorderitem,
          @ObjectModel.text.element: [ 'Suppliername' ]
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
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_INV_PENQTY_CALC'
          @Semantics.quantity.unitOfMeasure: 'Baseunit'
  virtual Pendqty : abap.quan( 13, 3 ),
          @Semantics.quantity.unitOfMeasure: 'Weiuom'
          Tareweight,
          @Semantics.quantity.unitOfMeasure: 'Weiuom'
          Grossweight,
          @Semantics.quantity.unitOfMeasure: 'Weiuom'
          Netweight,
          Storagelocation,
          Chbaseunit,
          Challanno,
          Challandate,
          @Semantics.quantity.unitOfMeasure: 'Chbaseunit'
          Challangrossweight,
          @Semantics.quantity.unitOfMeasure: 'Chbaseunit'
          Challantareweight,
          @Semantics.quantity.unitOfMeasure: 'Chbaseunit'
          Challannetweight,
          Chqtyunit,
          @Semantics.quantity.unitOfMeasure: 'Chqtyunit'
          Challanqty,
          Materialgroup,
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
          Grnqty,
          Inbounddelivery,
          @ObjectModel.text.element: [ 'Trasportername' ]
          Trasporterid,
          Trasportername,
          Lrno,
          Lrdate,
          Tpdocumt,
          Createdby,
          Createdat,
          Lastchangedby,
          Lastchangedat,
          /* Associations */
          _Head : redirected to parent ZMMGE_APP2_PE
}
