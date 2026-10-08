@EndUserText.label: 'Inventory Item Weighment Inp'
define abstract entity ZMM_WGHT_INP
{
  @EndUserText.label: 'Tare Weight'
  Weight : menge_d;
  @Semantics.unitOfMeasure: true
  //  @Consumption.defaultValue: 'TO'
  @Consumption.valueHelpDefault.display: true
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasureStdVH',
  element: 'UnitOfMeasure' } }]

  Unit   : abap.unit(3);
}
