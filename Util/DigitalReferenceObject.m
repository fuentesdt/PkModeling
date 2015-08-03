clear all
close all


ktrans = 0.846593
ve = 0.5
DeltaT=10.
MeasureTime = [1:DeltaT:200];

VeTerm = -ktrans /ve* MeasureTime;

YVmaxTumor  = 201.51
RTumor      = .08
RcTumor     = .05
toffset     = 21.


Cb = YVmaxTumor * RTumor*(exp(-RcTumor * (MeasureTime-toffset) ) - exp(-RTumor * (MeasureTime-toffset) )) /(RTumor - RcTumor);
Cb(1:2) = 0.;

Ct = ktrans  * DeltaT *conv (Cb,exp(VeTerm ))


handleone = figure(1)
plot(MeasureTime,Cb);

handletwo = figure(2)
plot(MeasureTime,Ct(1:length(MeasureTime)));
