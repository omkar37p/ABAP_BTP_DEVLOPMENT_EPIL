@EndUserText.label: 'Outgoing Weighment Recording - CE'
@ObjectModel.query.implementedBy: 'ABAP:ZWEIGH_FORM_IMP'
define custom entity ZSD_CE_WEIGHT
{
  key uuid          : sysuuid_x16;
      gateentryno   : abap.char(20);
      vehicleno     : abap.char( 20 );
      gateentrydate : abap.dats;
      weighuom      : abap.unit( 3 );
      @Semantics.quantity.unitOfMeasure: 'weighuom'
      tarewt        : abap.dec( 13, 3 );
      baseunit      : abap.unit( 3 );
      @Semantics.quantity.unitOfMeasure: 'baseunit'
      netweight     : abap.dec( 13, 3 );
      grossweight   : abap.dec( 13, 3 );
}
