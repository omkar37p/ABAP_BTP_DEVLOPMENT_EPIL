@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Image Verification - Gate Entry'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZSD_IH_IMGVR
  as select from zsdge_sentry_ht1 as a
  association [0..*] to ZSD_CE_IMGVR_IMG as _Images on $projection.Uuid = _Images.Uuid
{
  key a.uuid                                                                   as Uuid,
      a.gateentryno                                                            as Gateentryno,
      a.gateentrydate                                                          as Gateentrydate,
      a.gateentrytype                                                          as Gateentrytype,
      a.plant                                                                  as Plant,
      a.plantname                                                              as Plantname,
      a.vehicleno                                                              as Vehicleno,
      a.transportname                                                          as Transportname,
      a.drivername                                                             as Drivername,
      a.customer                                                               as Customer,
      a.customername                                                           as Customername,
      a.weighmentmcno                                                          as Weighmentmcno,
      a.weighmentmcndes                                                        as Weighmentmcndes,
      a.weighmentdate                                                          as Weighmentdate,
      a.weighmenttime                                                          as Weighmenttime,
      a.weighuom                                                               as Weighuom,
      @Semantics.quantity.unitOfMeasure: 'Weighuom'
      a.tarewt                                                                 as Tarewt,
      a.loadendindi                                                            as Loadendindi,
      a.imagevalid                                                             as Imagevalid,
      a.imgseqnotare                                                           as Imgseqnotare,
      a.imgseqnogross                                                          as Imgseqnogross,
      a.imgvrstatustare                                                        as Imgvrstatustare,
      a.imgvrstatusgross                                                       as Imgvrstatusgross,
      a.imgrejreason                                                           as Imgrejreason,
      a.imgverifiedby                                                          as Imgverifiedby,
      a.imgverifiedat                                                          as Imgverifiedat,
      @Semantics.user.createdBy: true
      a.createdby                                                              as Createdby,
      @Semantics.systemDateTime.createdAt: true
      a.createdat                                                              as Createdat,
      @Semantics.user.lastChangedBy: true
      a.lastchangedby                                                          as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      a.lastchangedat                                                          as Lastchangedat,

      // stage waiting for a decision: tare first, then gross
      cast( case when a.imgvrstatustare  = 'P' then 'T'
                 when a.imgvrstatusgross = 'P' then 'G'
                 else ' ' end as abap.char(1) )                                as Pendingstage,
      cast( case when a.imgvrstatustare  = 'P' then 'Tare'
                 when a.imgvrstatusgross = 'P' then 'Gross'
                 else ' ' end as abap.char(10) )                               as Pendingstagetext,
      cast( case when a.imgvrstatustare  = 'P' then 'X'
                 when a.imgvrstatusgross = 'P' then 'X'
                 else ' ' end as abap.char(1) )                                as Ispending,

      // status texts + criticality (same as in Outgoing Weighment)
      cast( case a.imgvrstatustare when 'P' then 'Pending'
                                   when 'A' then 'Approved'
                                   when 'R' then 'Rejected'
                                   else 'Not captured' end as abap.char(20) )  as Imgstatustaretext,
      cast( case a.imgvrstatustare when 'P' then 2
                                   when 'A' then 3
                                   when 'R' then 1
                                   else 0 end as abap.int1 )                   as Imgcrittare,
      cast( case a.imgvrstatusgross when 'P' then 'Pending'
                                    when 'A' then 'Approved'
                                    when 'R' then 'Rejected'
                                    else 'Not captured' end as abap.char(20) ) as Imgstatusgrosstext,
      cast( case a.imgvrstatusgross when 'P' then 2
                                    when 'A' then 3
                                    when 'R' then 1
                                    else 0 end as abap.int1 )                  as Imgcritgross,

      _Images
}
where
      a.imgseqnotare    <> ''
  and a.cancelgateentry =  ''
