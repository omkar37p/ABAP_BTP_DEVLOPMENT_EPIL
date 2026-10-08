@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GRN/Net Qty Custom CDS view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_GRNQTY
  as select from    zmmge_itm_t01    as a
    left outer join zmmge_wghflg_t01 as b on  b.gateentryseries = a.gateentryseries
                                          and b.materialgroup   = a.materialgroup
{
  key a.uuid,
  key a.purchaseorder,
  key a.purchaseorderitem,
      a.gateentryno,
      a.gateentryseries,
      b.materialgroup,
      b.challanqtyflag

}
