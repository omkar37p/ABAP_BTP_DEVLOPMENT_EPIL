@EndUserText.label: 'Auto Weighment Input Parameter'
define abstract entity ZSD_AUTOWT_INP
{
  @EndUserText.label: 'Weighment Machine'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_WEIGHT_VH', element: 'value_low' } }]
  Weighmentmcno : abap.char(10);
}
