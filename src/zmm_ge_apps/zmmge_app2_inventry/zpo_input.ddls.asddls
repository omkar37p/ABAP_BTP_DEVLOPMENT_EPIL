@EndUserText.label: 'Inventory Ventor & PO Parameter'
define abstract entity ZPO_INPUT
{
    @EndUserText.label: 'Vendor'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMM_SUP_VH', element: 'Vendor' } }]
    Vendor : abap.char(10);
    @EndUserText.label: 'Purchase Order'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMM_POHDVH', element: 'PurchaseOrder' },
                                       additionalBinding: [
                                       { localElement: 'Vendor', element: 'Vendor' ,
                                       usage: #FILTER_AND_RESULT }]}]
    PurchaseOrder : abap.char(10);
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMM_POITVH', element: 'PurchaseOrderItem' },
                                    additionalBinding: [
                                    { localElement: 'Vendor', element: 'Vendor',usage: #FILTER_AND_RESULT },
                                    { localElement: 'PurchaseOrder', element: 'PurchaseOrder', usage: #FILTER_AND_RESULT }
                                    ] }]
    @EndUserText.label: 'Order Item'
    PurchaseOrderItem : abap.numc(5);
}
