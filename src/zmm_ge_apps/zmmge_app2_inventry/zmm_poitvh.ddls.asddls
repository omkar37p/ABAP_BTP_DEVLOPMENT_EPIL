@EndUserText.label: 'Purchase Order Item Value Help (S/4)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MM_S4_VH_QUERY'
@Search.searchable: true
define custom entity ZMM_POITVH
{
      @EndUserText.label: 'Purchase Order'
      @Search.defaultSearchElement: true
  key PurchaseOrder         : abap.char(10);

      @EndUserText.label: 'Order Item'
      @Search.defaultSearchElement: true
  key PurchaseOrderItem     : abap.numc(5);

      @EndUserText.label: 'Material'
      @Search.defaultSearchElement: true
      Material              : abap.char(40);

      @EndUserText.label: 'Material Description'
      @Search.defaultSearchElement: true
      PurchaseOrderItemText : abap.char(40);

      @EndUserText.label: 'Vendor'
      Vendor                : abap.char(10);
}
