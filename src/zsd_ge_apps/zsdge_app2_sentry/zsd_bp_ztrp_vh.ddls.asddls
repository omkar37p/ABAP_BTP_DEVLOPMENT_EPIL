@EndUserText.label: 'Transporter ID Value Help (S/4)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SD_BPZTRP_VH_QUERY'
@Search.searchable: true
define custom entity ZSD_BP_ZTRP_VH
{
      @EndUserText.label: 'Transporter'
      @ObjectModel.text.element: [ 'Transportername' ]
      @Search.defaultSearchElement: true
  key Transporterid   : abap.char(10);

      @EndUserText.label: 'Transporter Name'
      @Search.defaultSearchElement: true
      @Semantics.text: true
//      Transportername : abap.char(81);
      Transportername : abap.char(100);      
}
