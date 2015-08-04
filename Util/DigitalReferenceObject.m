clear all
close all

% model parameters
RepetitionTime=3.776;
FlipAngle=15;
T1Phantom = 1600.
R10 = 1./T1Phantom;
ktrans = 0.796541
ve = 0.453603

MeasureTime = 1.e-3*[0.0,4270.0,8541.0,12812.0,17082.0,21353.0,25624.0,29894.0,34165.0,38436.0,42706.0,46977.0,51248.0,55518.0,59789.0,64060.0,68331.0,72601.0,76872.0,81143.0,85413.0,89684.0,93955.0,98225.0,102496.0,106767.0,111037.0,115308.0,119579.0,123850.0,128120.0,132391.0,136662.0,140932.0,145203.0,149474.0,153744.0,158015.0,162286.0,166556.0,170827.0,175098.0,179369.0,183639.0,187910.0,192181.0,196451.0,200722.0,204993.0,209263.0,213534.0,217805.0,222075.0,226346.0,230617.0,234888.0,239158.0,243429.0,247700.0,251970.0]
ntime = length(MeasureTime);

DeltaT = MeasureTime(2) - MeasureTime(1) 

VeTerm = -ktrans /ve* MeasureTime;

YVmaxTumor  = .0006
YVmaxTumor  = 2500.0006
RTumor      = .08
RcTumor     = .05
toffset     = 21.


Cb = YVmaxTumor * RTumor*(exp(-RcTumor * (MeasureTime-toffset) ) - exp(-RTumor * (MeasureTime-toffset) )) /(RTumor - RcTumor);
Cb(Cb<200.) = 200.;
Cb(MeasureTime >55.) = 600.;

signalCb = (1.-exp(- RepetitionTime*(Cb +R10))).* (1.- cos(FlipAngle*pi/180.) * exp(- RepetitionTime*(Cb +R10))).^(-1);

sprintf('%f,%f\n', [MeasureTime;Cb])

Ct = ktrans  * DeltaT *conv (Cb,exp(VeTerm ))
signalCt = (1.-exp(- RepetitionTime*(Ct +R10))).* (1.- cos(FlipAngle*pi/180.) * exp(- RepetitionTime*(Ct +R10))).^(-1);

% rewrite prostate dataset AIF
prostateqin = zeros(ntime ,9,12);
newdro      = zeros(ntime ,9,12);
for idtime = 1:ntime 
  % read
  niidata = load_untouch_nii(sprintf('QIN/QINProstate001-phantom.%04d.nii.gz',idtime-1 ));
  prostateqin (idtime,:,:) = niidata.img;
  % save
  niidata.img(1,1) = Cb(idtime);
  save_untouch_nii(niidata,sprintf('newphantom/newphantom.%04d.nii.gz',idtime-1 ));
  % read
  niidata = load_untouch_nii(sprintf('test/fit.%04d.nii.gz',idtime-1 ));
  newdro(idtime,:,:) = niidata.img;
end
% c3d newphantom.0000.nii.gz newphantom.0001.nii.gz newphantom.0002.nii.gz newphantom.0003.nii.gz newphantom.0004.nii.gz newphantom.0005.nii.gz newphantom.0006.nii.gz newphantom.0007.nii.gz newphantom.0008.nii.gz newphantom.0009.nii.gz newphantom.0010.nii.gz newphantom.0011.nii.gz newphantom.0012.nii.gz newphantom.0013.nii.gz newphantom.0014.nii.gz newphantom.0015.nii.gz newphantom.0016.nii.gz newphantom.0017.nii.gz newphantom.0018.nii.gz newphantom.0019.nii.gz newphantom.0020.nii.gz newphantom.0021.nii.gz newphantom.0022.nii.gz newphantom.0023.nii.gz newphantom.0024.nii.gz newphantom.0025.nii.gz newphantom.0026.nii.gz newphantom.0027.nii.gz newphantom.0028.nii.gz newphantom.0029.nii.gz newphantom.0030.nii.gz newphantom.0031.nii.gz newphantom.0032.nii.gz newphantom.0033.nii.gz newphantom.0034.nii.gz newphantom.0035.nii.gz newphantom.0036.nii.gz newphantom.0037.nii.gz newphantom.0038.nii.gz newphantom.0039.nii.gz newphantom.0040.nii.gz newphantom.0041.nii.gz newphantom.0042.nii.gz newphantom.0043.nii.gz newphantom.0044.nii.gz newphantom.0045.nii.gz newphantom.0046.nii.gz newphantom.0047.nii.gz newphantom.0048.nii.gz newphantom.0049.nii.gz newphantom.0050.nii.gz newphantom.0051.nii.gz newphantom.0052.nii.gz newphantom.0053.nii.gz newphantom.0054.nii.gz newphantom.0055.nii.gz newphantom.0056.nii.gz newphantom.0057.nii.gz newphantom.0058.nii.gz newphantom.0059.nii.gz -omc newphantom.nrrd
% c3d newphantom/newphantom.0000.nii.gz QIN/QINProstate001-phantom-AIF.nrrd -copy-transform -o newphantom/newphantom.mask.aif.nii.gz
% c3d newphantom/newphantom.0000.nii.gz QIN/QINProstate001-phantom-ROI.nrrd -copy-transform -o newphantom/newphantom.mask.roi.nii.gz



handlefive = figure(5)
plot(MeasureTime,prostateqin (:,1,1))



handleone = figure(1)
plot(MeasureTime,signalCb);

handletwo = figure(2)
plot(MeasureTime,Cb);
hold
plot(MeasureTime,newdro(:,4,4));

handlethree = figure(3)
plot(MeasureTime,signalCt(1:length(MeasureTime)));

handlefour = figure(4)
plot(MeasureTime,Ct(1:length(MeasureTime)));
hold
plot(MeasureTime,newdro(:,4,4));


imageout = zeros(5,4,3);
for idtime =1:length(MeasureTime)
  imageout(:,1,:)   = signalCb (idtime);
  imageout(:,2:4,:) = signalCt (idtime);
  %imageout(:,1,:)   = Cb (idtime);
  %imageout(:,2:4,:) = Ct (idtime);
  niidata = make_nii(imageout,[1 1 1], [0 0 0],16,'phantom');
  save_nii(niidata ,sprintf('phantom.%04d.nii.gz',idtime));
end

% create aif mask
aifmask = zeros(5,4,3);
aifmask(:,1,:) = 1;
niidata = make_nii(aifmask,[1 1 1], [0 0 0],2,'aif mask');
save_nii(niidata ,'aifmask.nii.gz');

% create roi mask
roimask = zeros(5,4,3);
roimask(:,2:4,:) = 1;
niidata = make_nii(roimask,[1 1 1], [0 0 0],2,'roi mask');
save_nii(niidata ,'roimask.nii.gz');


disp(sprintf('c3d phantom.0001.nii.gz phantom.0002.nii.gz phantom.0003.nii.gz phantom.0004.nii.gz phantom.0005.nii.gz phantom.0006.nii.gz phantom.0007.nii.gz phantom.0008.nii.gz phantom.0009.nii.gz phantom.0010.nii.gz phantom.0011.nii.gz phantom.0012.nii.gz phantom.0013.nii.gz phantom.0014.nii.gz phantom.0015.nii.gz phantom.0016.nii.gz phantom.0017.nii.gz phantom.0018.nii.gz phantom.0019.nii.gz phantom.0020.nii.gz -omc phantom.nrrd'))
disp(sprintf('MultiVolume.FrameLabels:=%s ',sprintf('%4.1f,',MeasureTime)))
disp(sprintf('MultiVolume.NumberOfFrames:=%d ',length(MeasureTime)))
disp(sprintf('MultiVolume.DICOM.FlipAngle:=%f ',FlipAngle))
disp(sprintf('MultiVolume.DICOM.RepetitionTime:=%f ',RepetitionTime))
disp(sprintf('MultiVolume.FrameIdentifyingDICOMTagName:=TriggerTime'))
disp(sprintf('kinds: list domain domain domain '))


sprintf('../lib/Slicer-4.3/cli-modules/PkModeling --T1Tissue %f --T1Blood %f --relaxivity 1.0 --S0grad 15.0 --hematocrit 1.0 --aucTimeInterval 90 --fTolerance 1e-4 --gTolerance 1e-4 --xTolerance 1e-5 --epsilon 1e-9 --maxIter 200 --outputKtrans ./phantomktrans.nrrd --outputVe ./phantomve.nrrd --outputMaxSlope ./phantommaxslope.nrrd --outputAUC ./phantomauc.nrrd --outputBAT ./phantombat.nrrd --fitted ./phantomfit.nrrd --concentrations ./phantomconc.nrrd --roiMask ./roimask.nii.gz --aifMask aifmask.nii.gz phantom.nrrd',T1Phantom,T1Phantom)


