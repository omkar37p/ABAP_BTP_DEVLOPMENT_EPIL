@EndUserText.label: 'Storage Location Value Help (S/4)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SD_SLOC_VH_QUERY'
@Search.searchable: true
define custom entity ZSD_SLOC_VH
{
      @EndUserText.label  : 'Plant'
  key Plant               : werks_d;

      @EndUserText.label  : 'Storage Location'
      @ObjectModel.text.element: [ 'Storagelocationname' ]
      @Search.defaultSearchElement: true
  key Storagelocation     : lgort_d;

      @EndUserText.label  : 'Storage Location Name'
      @Search.defaultSearchElement: true
      @Semantics.text     : true
      Storagelocationname : abap.char(16);
}
