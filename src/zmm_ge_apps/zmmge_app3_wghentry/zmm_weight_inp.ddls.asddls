@EndUserText.label: 'Inventory Weighment Input Parameter'
define abstract entity ZMM_WEIGHT_INP
  //  with parameters parameter_name : parameter_type
{
  @EndUserText.label: 'Weighment Machine'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMM_WEIGHMENT_VH',
   element      : 'value_low' } }]

  Weighmentmcno : abap.char(10);
  ////  @Semantics.quantity.unitOfMeasure: 'Unit'
  @EndUserText.label: 'Gross Weight'

  Weight        : menge_d;
  //  @UI.hidden: true
  @Semantics.unitOfMeasure: true
  //  @Consumption.defaultValue: 'TO'
  @Consumption.valueHelpDefault.display: true
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasureStdVH',
  element       : 'UnitOfMeasure' } }]

  Unit          : abap.unit(3);
}
