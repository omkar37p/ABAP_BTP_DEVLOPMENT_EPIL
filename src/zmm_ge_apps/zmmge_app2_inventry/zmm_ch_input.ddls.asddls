@EndUserText.label: 'Challan & Invoice Details Parameter'
define abstract entity ZMM_CH_INPUT
//  with parameters parameter_name : parameter_type
{
  @EndUserText.label: 'Challan Number'
  Challanno    : abap.char(20);
  @EndUserText.label: 'Challan Date'
  Challandate  : abap.dats;
  @EndUserText.label: 'Transporter ID'
  @Consumption.valueHelpDefinition: [ { entity: { name: 'ZSD_BP_ZTRP_VH', element: 'Transporterid' }  } ]
  trasporterid : abap.char(10);
  @EndUserText.label: 'LR No'
  lrno         : abap.char(20);
  @EndUserText.label: 'LR Date'
  lrdate       : abap.dats;    
}
