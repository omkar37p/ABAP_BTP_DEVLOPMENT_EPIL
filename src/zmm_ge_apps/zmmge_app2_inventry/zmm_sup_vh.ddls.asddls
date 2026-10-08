@EndUserText.label: 'Supplier Value Help (S/4)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MM_S4_VH_QUERY'
@Search.searchable: true
define custom entity ZMM_SUP_VH
{
      @EndUserText.label: 'Vendor'
      @ObjectModel.text.element: [ 'SupplierName' ]
      @Search.defaultSearchElement: true
  key Vendor       : abap.char(10);

      @EndUserText.label: 'Supplier Name'
      @Search.defaultSearchElement: true
      @Semantics.text: true
      SupplierName : abap.char(80);
}
