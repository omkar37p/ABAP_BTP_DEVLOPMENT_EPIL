@EndUserText.label: 'Outgoing Gate Security CustomEnty - Apps'
@ObjectModel.query.implementedBy: 'ABAP:ZENTRY_FORM_IMP'
define custom entity ZSD_HCE_GATESEC
{
  key uuid          : sysuuid_x16;
      gateentryid   : abap.char( 10 );
      vehicleno     : abap.char( 15 );
      gateentrydate : abap.dats;
      gateentrytime : abap.tims;
}
