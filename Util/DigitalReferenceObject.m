clear all
close all

% model parameters
RepetitionTime=3.776;
FlipAngle=15;
T1Phantom = 1600.
R10 = 1./T1Phantom;
ktrans = 0.796541
ve = 0.453603
relaxivity=0.0039 
hematocrit=0.4

% measurement times 
MeasureTime = 1.e-3*[0.0,4270.0,8541.0,12812.0,17082.0,21353.0,25624.0,29894.0,34165.0,38436.0,42706.0,46977.0,51248.0,55518.0,59789.0,64060.0,68331.0,72601.0,76872.0,81143.0,85413.0,89684.0,93955.0,98225.0,102496.0,106767.0,111037.0,115308.0,119579.0,123850.0,128120.0,132391.0,136662.0,140932.0,145203.0,149474.0,153744.0,158015.0,162286.0,166556.0,170827.0,175098.0,179369.0,183639.0,187910.0,192181.0,196451.0,200722.0,204993.0,209263.0,213534.0,217805.0,222075.0,226346.0,230617.0,234888.0,239158.0,243429.0,247700.0,251970.0]
ntime = length(MeasureTime);


% prescribed aif  [AU] (MR signal)
YVmaxTumor  = .0006
YVmaxTumor  = 2500.0006
RTumor      = .08
RcTumor     = .05
toffset     = 21.
signalCb = YVmaxTumor * RTumor*(exp(-RcTumor * (MeasureTime-toffset) ) - exp(-RTumor * (MeasureTime-toffset) )) /(RTumor - RcTumor);
signalCb(signalCb<200.) = 200.;
signalCb(MeasureTime >55.) = 600.;
%sprintf('%f,%f\n', [MeasureTime;signalCb]);

% convert MR signal to Cb
exp_TR_BloodT1 = exp (-RepetitionTime/T1Phantom );
cos_alpha = cos(FlipAngle*pi/180);
constB = (1-exp_TR_BloodT1) / (1-cos_alpha*exp_TR_BloodT1);
constA = 1/signalCb(1)* signalCb;
value = (1 - constA * constB)./ (1- constA * constB * cos_alpha);
%value = (1 - constA * constB).* (1- constA * constB * cos_alpha).^(-1)
log_value = log(value);
ROft = (-1./RepetitionTime) * log_value;
Cb = (ROft - R10 ) / relaxivity;

% convolution gives Cv
% TODO: ktrans in minutes...
DeltaT = (MeasureTime(2) - MeasureTime(1))/60. 
VeTerm = -ktrans /ve* MeasureTime/60.;
% FIXME: is the arrival time shifted
auxvar = padarray(conv (Cb,exp(VeTerm ))',[3 0]);
Cv = (1./(1.0-hematocrit))*ktrans  * DeltaT * auxvar(1:ntime);
DeltaR = relaxivity*Cv;

signalCv = (1.-exp(- RepetitionTime*(DeltaR  +R10))).* (1.- cos(FlipAngle*pi/180.) * exp(- RepetitionTime*(DeltaR  +R10))).^(-1);

% rewrite prostate dataset AIF
prostateqin = zeros(ntime ,9,12);
newdro      = zeros(ntime ,9,12);
for idtime = 1:ntime 
  % read
  niidata = load_untouch_nii(sprintf('QIN/QINProstate001-phantom.%04d.nii.gz',idtime-1 ));
  prostateqin (idtime,:,:) = niidata.img;
  % save
  niidata.img(1,1) = signalCb(idtime);
  niidata.img(4:9,4:12) = niidata.img(4,4) ;
  save_untouch_nii(niidata,sprintf('newphantom/newphantom.%04d.nii.gz',idtime-1 ));
  % read
  niidata = load_untouch_nii(sprintf('test/fit.%04d.nii.gz',idtime-1 ));
  newdro(idtime,:,:) = niidata.img;
end

handlefive = figure(5);
plot(MeasureTime,prostateqin (:,1,1))

handleone = figure(1);
plot(MeasureTime,signalCb);

handletwo = figure(2);
plot(MeasureTime,Cb);

handlethree = figure(3);
plot(MeasureTime,signalCv(1:length(MeasureTime)));

handlefour = figure(4);
plot(MeasureTime,Cv);
hold
plot(MeasureTime,newdro(:,4,4),'r-.');


imageout = zeros(5,4,3);
for idtime =1:length(MeasureTime)
  imageout(:,1,:)   = signalCb (idtime);
  imageout(:,2:4,:) = signalCv (idtime);
  %imageout(:,1,:)   = Cb (idtime);
  %imageout(:,2:4,:) = Cv (idtime);
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


disp(sprintf('c3d %s -omc newphantom.nrrd',sprintf('newphantom.%04d.nii.gz ',[0:ntime-1]) ))
disp(sprintf('c3d newphantom.0000.nii.gz ../QIN/QINProstate001-phantom-AIF.nrrd -copy-transform -o newphantom.mask.aif.nii.gz '))
disp(sprintf('c3d newphantom.0000.nii.gz ../QIN/QINProstate001-phantom-ROI.nrrd -copy-transform -o newphantom.mask.roi.nii.gz '))
disp('\n')
disp(sprintf('c3d %s -omc phantom.nrrd',sprintf('phantom.%04d.nii.gz ',[0:ntime-1]) ))
disp(sprintf('MultiVolume.FrameLabels:=%s ',sprintf('%4.1f,',MeasureTime)))
disp(sprintf('MultiVolume.NumberOfFrames:=%d ',length(MeasureTime)))
disp(sprintf('MultiVolume.DICOM.FlipAngle:=%f ',FlipAngle))
disp(sprintf('MultiVolume.DICOM.RepetitionTime:=%f ',RepetitionTime))
disp(sprintf('MultiVolume.FrameIdentifyingDICOMTagName:=TriggerTime'))
disp(sprintf('kinds: list domain domain domain '))


sprintf('./lib/Slicer-4.3/cli-modules/PkModeling --T1Tissue %f --T1Blood %f --relaxivity %f --S0grad 15.0 --hematocrit %f --aucTimeInterval 90 --fTolerance 1e-4 --gTolerance 1e-4 --xTolerance 1e-5 --epsilon 1e-9 --outputKtrans ./Util/phantomktrans.nrrd --outputVe ./Util/phantomve.nrrd --outputMaxSlope ./Util/phantommaxslope.nrrd --outputAUC ./Util/phantomauc.nrrd --outputBAT ./Util/phantombat.nrrd --fitted ./Util/phantomfit.nrrd --concentrations ./Util/phantomconc.nrrd --roiMask ./Util/roimask.nii.gz --aifMask ./Util/aifmask.nii.gz --maxIter 200 ./Util/phantom.nrrd',T1Phantom,T1Phantom,relaxivity, hematocrit)


