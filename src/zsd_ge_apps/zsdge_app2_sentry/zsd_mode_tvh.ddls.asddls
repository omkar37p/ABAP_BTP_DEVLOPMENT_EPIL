@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Mode Of Transport Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: { dataCategory: #VALUE_HELP, resultSet.sizeCategory: #XS }
@Search.searchable: true
define view entity ZSD_MODE_TVH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name : 'ZSD_MODEOF_TRAN' )
{
      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
      @Semantics.language: true
      @UI.hidden: true
  key language,
      @EndUserText.label: 'Mode of Transport'
      @ObjectModel.text.element: [ 'text' ]
      @Search.defaultSearchElement: true
      value_low,
      @Semantics.text: true
      text
}
