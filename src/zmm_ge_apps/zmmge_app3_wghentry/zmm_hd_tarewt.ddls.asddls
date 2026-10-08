@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tare and Net Weight calculation'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMM_HD_TAREWT
  as select from ZMM_SUM_WTNET
{
  key Uuid,
      Grosswt   as DecGrossWt,
      Netweight as DecNetWt,
      cast( coalesce( Grosswt, 0 ) - coalesce( Netweight, 0 )
          as abap.dec(13,3)
      )         as DecTareWt
}
