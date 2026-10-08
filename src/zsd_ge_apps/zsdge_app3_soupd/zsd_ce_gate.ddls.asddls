@EndUserText.label: 'Gate Entry Apps CE - Dispatch'
@ObjectModel.query.implementedBy: 'ABAP:ZLOADING_FORM_IMP'
define custom entity ZSD_CE_GATE
{
  key uuid          : sysuuid_x16;
      gateentryno   : abap.char( 20 );
      gateentrydate : abap.dats;
      Truckno       : abap.char( 20 );
      Vehiclecapqty : abap.dec( 15, 3);
      quality       : abap.char( 50 );
      remarks       : abap.char( 150 );
      materialdesc  : abap.char( 40 );
}
