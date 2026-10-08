@EndUserText.label: 'Image Verification - Camera Images'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SD_IMGVR_IMG_QUERY'
define custom entity ZSD_CE_IMGVR_IMG
{
  key Uuid       : sysuuid_x16;
  key Stage      : abap.char(1);
  key Imageno    : abap.int1;
      Stagetext  : abap.char(10);
      Rowidseq   : abap.char(20);
      @Semantics.imageUrl: true
      Imageurl   : abap.string(0);
      Camweight  : abap.char(20);
      Ocrtext    : abap.char(60);
      Capturedat : abap.char(20);
      Message    : abap.char(255);
}
