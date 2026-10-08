@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Dispatch Planning Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZSD_CI_DISPLAN
  as projection on ZSD_II_DISPLAN
{
  key Uuid,
  key Salesorder,
  key Salesorderitem,
      Slno,
      Dispatchdate,
      Customer,
      Plant,
      Transmode,
      Material,
      Baseunit,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Totalorderqty,
      @Semantics.quantity.unitOfMeasure: 'Baseunit'
      Dispplantqty,
      Vehicleno,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _Head : redirected to parent ZSD_CH_DISPLAN
}
