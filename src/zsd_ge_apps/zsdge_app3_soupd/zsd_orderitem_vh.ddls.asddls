@EndUserText.label: 'Sales Order Item Value Help (S/4)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SD_SOUPD_VH_QUERY'
@Search.searchable: true
define custom entity ZSD_ORDERITEM_VH
{
      @EndUserText.label: 'Sales Order'
  key SalesDocument      : abap.char(10);

      @EndUserText.label: 'Item'
      @Search.defaultSearchElement: true
  key SalesDocumentItem  : abap.numc(6);

      @EndUserText.label: 'Customer'
      Customer           : abap.char(10);

      @EndUserText.label: 'Product Description'
      @Search.defaultSearchElement: true
      ProductDescription : abap.char(40);
}
