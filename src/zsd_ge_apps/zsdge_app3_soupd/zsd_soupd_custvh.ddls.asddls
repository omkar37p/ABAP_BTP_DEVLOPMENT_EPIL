@EndUserText.label: 'Customer Value Help (S/4)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SD_SOUPD_VH_QUERY'
@Search.searchable: true
define custom entity ZSD_SOUPD_CUSTVH
{
      @EndUserText.label: 'Customer'
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Search.defaultSearchElement: true
  key Customer     : abap.char(10);

      @EndUserText.label: 'Customer Name'
      @Search.defaultSearchElement: true
      @Semantics.text: true
      CustomerName : abap.char(80);
}
