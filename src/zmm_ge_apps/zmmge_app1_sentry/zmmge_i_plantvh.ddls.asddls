@EndUserText.label: 'Plant Value Help (S/4HANA I_Plant)'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MMGE_PLANTVH_QUERY'
@Search.searchable: true
@ObjectModel.resultSet.sizeCategory: #XS

define custom entity ZMMGE_I_PLANTVH
{
      @EndUserText.label: 'Plant'
      @ObjectModel.text.element: [ 'PlantName' ]
      @Search.defaultSearchElement: true
  key Plant     : abap.char(4);

      @EndUserText.label: 'Plant Name'
      @Search.defaultSearchElement: true
      @Semantics.text: true
      PlantName : abap.char(30);
}
