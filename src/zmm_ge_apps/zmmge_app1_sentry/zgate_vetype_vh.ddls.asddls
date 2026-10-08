@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help - Gate Entry Vehicle Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: { dataCategory: #VALUE_HELP }
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZGATE_VETYPE_VH 
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZGATE_VEHICLE_TYPE')
{
      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
      @Semantics.language: true
      @UI.hidden: true
  key language,
      @EndUserText.label: 'Vehicle Type'
      @ObjectModel.text.element: [ 'text' ]
      @Search.defaultSearchElement: true
      value_low,
      @Semantics.text: true
      text
}
