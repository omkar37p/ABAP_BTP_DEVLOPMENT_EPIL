@EndUserText.label: 'Purchase Order Value Help (S/4)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MM_S4_VH_QUERY'
@Search.searchable: true
define custom entity ZMM_POHDVH
{
      @EndUserText.label: 'Purchase Order'
      @Search.defaultSearchElement: true
  key PurchaseOrder : abap.char(10);

      @EndUserText.label: 'Vendor'
      @ObjectModel.text.element: [ 'SupplierName' ]
      @Search.defaultSearchElement: true
      Vendor        : abap.char(10);

      @EndUserText.label: 'Supplier Name'
      @Semantics.text: true
      SupplierName  : abap.char(80);
}
