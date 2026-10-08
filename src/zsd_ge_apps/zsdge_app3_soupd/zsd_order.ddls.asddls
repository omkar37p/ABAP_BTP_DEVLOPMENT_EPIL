@EndUserText.label: 'Sales Order Parameter Input'
define abstract entity ZSD_ORDER
{
  @EndUserText.label: 'Customer'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_SOUPD_CUSTVH', element: 'Customer' } }]
  Customer          : abap.char(10);

  @EndUserText.label: 'Sales Order'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_ORDER_VH', element: 'SalesDocument' },
                                       additionalBinding: [ { localElement: 'Customer', element: 'Customer',
                                                              usage: #FILTER_AND_RESULT } ] }]
  Salesdocument     : abap.char(10);

  @EndUserText.label: 'Sales Order Item'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_ORDERITEM_VH', element: 'SalesDocumentItem' },
                                       additionalBinding: [ { localElement: 'Customer',      element: 'Customer',
                                                              usage: #FILTER_AND_RESULT },
                                                            { localElement: 'Salesdocument', element: 'SalesDocument',
                                                              usage: #FILTER_AND_RESULT } ] }]
  SalesDocumentItem : abap.numc(6);
}
