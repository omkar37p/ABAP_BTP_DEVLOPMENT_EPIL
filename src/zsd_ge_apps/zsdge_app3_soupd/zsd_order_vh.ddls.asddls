@EndUserText.label: 'Sales Order Value Help (S/4)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SD_SOUPD_VH_QUERY'
@Search.searchable: true
define custom entity ZSD_ORDER_VH
{
      @EndUserText.label: 'Sales Order'
      @Search.defaultSearchElement: true
  key SalesDocument : abap.char(10);

      @EndUserText.label: 'Customer'
      @ObjectModel.text.element: [ 'CustomerName' ]
      Customer      : abap.char(10);

      @EndUserText.label: 'Customer Name'
      @Search.defaultSearchElement: true
      @Semantics.text:true
      CustomerName  : abap.char(80);
}
