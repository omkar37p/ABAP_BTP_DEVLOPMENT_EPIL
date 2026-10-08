@EndUserText.label: 'Weighment Input Parameter'
define abstract entity ZSD_WEIGHT_INP
{
  @EndUserText.label: 'Weighment Machine'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZSD_WEIGHT_VH', element: 'value_low' } }]
  Weighmentmcno : abap.char(10);

  @EndUserText.label: 'Weight Reading'
  @Semantics.quantity.unitOfMeasure: 'Unit'
  Weight        : menge_d;

  @EndUserText.label: 'Unit'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasureStdVH', element: 'UnitOfMeasure' } }]
  Unit          : abap.unit(3);
}
