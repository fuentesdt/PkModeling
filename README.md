# PkModeling
PkModeling is a [3D Slicer Version 4](http://www.slicer.org) Extension that provides pharmacokinetic modeling for dynamic contrast enhanced MRI (DCE MRI)[1][2]. See documentation at https://www.slicer.org/wiki/Documentation/Nightly/Modules/PkModeling.

PkModeling accepts volumetric timecourse data of signal intensities and computes parametric maps using either a two or three parameter Tofts model. The estimated parameters include

* Ktrans - volume transfer contrast constant between plasma and the extracellular-extravascular space at each voxel
* Ve - fractional volume for extracellular space at each voxel
* fpv - fractional plasma volume at each voxel
* MaxSlope - maximum slope of the of the time sequence at each voxel
* AUC - area under the curve of each voxel, measured from the bolus arrival time to the end of the time interval, normalized by the AUC of the arterial input function (AIF)
* R^2 - goodness of fit value. Since the parametric model is non-linear, R^2 is not strictly bounded by [-1,1]. But larger values still correspond to better fits.

PkModeling can also output a concentration curve view of the original volumetric timecourse as well as the "fitted" concentration curves resulting from the parametric model.

Estimation of the parametric model is controlled through a series of inputs including

* T1 Blood Value
* T1 Tissue Value - defaults to published value for prostate in de Bazelaire et al.[3]
* Relaxivity Value - default 0.0039 corresponds to the Gd-DPTA (Magnevist) at 3T, see Pintaske et al.[4]. This value needs to be adjusted for magnet strength and contrast agent.
* Hematocrit Value - volume percentage of red blood cells in blood
* AUC Time Interval Value - time interval for AUC calculation

Furthermore, an arterial input function (AIF) must be specified either by designating a mask corresponding to the voxels on which to base a patient specific estimate of the AIF, or by specifying a population derived AIF curve directly.

Finally, the estimation of the parametric maps can be restricted to a specified mask defining a region of interest.

Acquisition parameters relevent to the parametric model fitting are embedded in the input volumetric timecourse data, either as attributes on a NRRD file or extracted directly from the underlying DICOM structures

* TR Value - repetition time (in milliseconds)
* TE Value - echo time (in milliseconds)
* FA Value - flip angle (in degrees)
* Timestamps for the timecourses (in milliseconds)

# Visualization
See the [MultiVolumeExplorer](ttps://github.com/fedorov/MultiVolumeExplorer) module in the 3D Slicer.

# Authors
[@millerjv](https://github.com/millerjv), [@fedorov](https://github.com/fedorov), [@zhuy](https://github.com/zhuy)

# References
[1]: Knopp MV, Giesel FL, Marcos H et al. "Dynamic contrast-enhanced magnetic resonance imaging in oncology." Top Magn Reson Imaging, 2001; 12:301-308.

[2]: Rijpkema M, Kaanders JHAM, Joosten FBM et al. "Method for quantitative mapping of dynamic MRI contrast agent uptake in human tumors." J Magn Reson Imaging 2001; 14:457-463.

[3]: de Bazelaire, C.M., et al. "MR imaging relaxation times of abdominal and pelvic tissues measured in vivo at 3.0 T: preliminary results." Radiology, 2004. 230(3): p. 652-9.

[4]: Pintaske J, Martirosian P, Graf H, Erb G, Lodemann K-P, Claussen CD, Schick F. "Relaxivity of Gadopentetate Dimeglumine (Magnevist), Gadobutrol (Gadovist), and Gadobenate Dimeglumine (MultiHance) in human blood plasma at 0.2, 1.5, and 3 Tesla." Investigative radiology. 2006 March;41(3):213–21.

# AUC calculations

[convert_signal_to_concentration](https://github.com/fuentesdt/PkModeling/blob/master/PkSolver/PkSolver.cxx#L306)
```
Breakpoint 4, itk::convert_signal_to_concentration (signalSize=36, SignalIntensityCurve=0x7fffc8000df0, T1Pre=1600, TR=3.14400005, FA=15, concentration=0x7fffc8000d50,
    RGd_relaxivity=0.00389999989, s0=0, S0GradThresh=15) at /workarea/fuentes/github/PkModeling/PkSolver/PkSolver.cxx:278
278       const double exp_TR_BloodT1 = exp (-TR/T1Pre);
(gdb) bt
#0  itk::convert_signal_to_concentration (signalSize=36, SignalIntensityCurve=0x7fffc8000df0, T1Pre=1600, TR=3.14400005, FA=15, concentration=0x7fffc8000d50,
    RGd_relaxivity=0.00389999989, s0=0, S0GradThresh=15) at /workarea/fuentes/github/PkModeling/PkSolver/PkSolver.cxx:278
#1  0x00007ffff788c2f3 in itk::SignalIntensityToConcentrationImageFilter<itk::VectorImage<short, 3u>, itk::Image<short, 3u>, itk::VectorImage<float, 3u> >::GenerateData (this=0xa73130)
    at /workarea/fuentes/github/PkModeling/CLI/itkSignalIntensityToConcentrationImageFilter.hxx:105
#2  0x00007fffe9341368 in itk::ProcessObject::UpdateOutputData (this=0xa73130) at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/src/itkProcessObject.cxx:1743
#3  0x00007fffe93573a9 in itk::DataObject::UpdateOutputData (this=0xa733e0) at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/src/itkDataObject.cxx:434
#4  0x00007ffff7854004 in itk::ImageBase<3u>::UpdateOutputData (this=0xa733e0) at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/include/itkImageBase.hxx:285
#5  0x00007fffe935702f in itk::DataObject::Update (this=0xa733e0) at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/src/itkDataObject.cxx:359
#6  0x00007fffe9340288 in itk::ProcessObject::Update (this=0xa73130) at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/src/itkProcessObject.cxx:1324
#7  0x00007ffff77f8f1e in DoIt<short, short> (argc=35, argv=0x7fffffffd998) at /workarea/fuentes/github/PkModeling/CLI/PkModeling.cxx:366
#8  0x00007ffff77ee381 in ModuleEntryPoint (argc=35, argv=0x7fffffffd998) at /workarea/fuentes/github/PkModeling/CLI/PkModeling.cxx:542
#9  0x0000000000401309 in main (argc=35, argv=0x7fffffffd998) at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/Slicer-build/Base/CLI/SEMCommandLineLibraryWrapper.cxx:42
```

[compute_bolus_arrival_time](https://github.com/fuentesdt/PkModeling/blob/master/PkSolver/PkSolver.cxx#L471)
```
(gdb) bt
#0  itk::compute_bolus_arrival_time (signalSize=36, SignalY=0xa74320, ArrivalTime=@0x7fffd8756bb8, FirstPeak=@0x7fffd8756bb4, MaxSlope=@0x7fffd8756bb0)
    at /workarea/fuentes/github/PkModeling/PkSolver/PkSolver.cxx:439
#1  0x00007ffff79287a8 in itk::compute_s0_individual_curve (signalSize=36, SignalY=0xa74320, S0GradThresh=15, BATCalculationMode=..., constantBAT=1)
    at /workarea/fuentes/github/PkModeling/PkSolver/PkSolver.cxx:614
#2  0x00007ffff791faea in itk::SignalIntensityToS0ImageFilter<itk::VectorImage<short, 3u>, itk::Image<float, 3u> >::ThreadedGenerateData (this=0xa73d10, outputRegionForThread=...)
    at /workarea/fuentes/github/PkModeling/CLI/itkSignalIntensityToS0ImageFilter.hxx:55
#3  0x00007ffff78b1410 in itk::ImageSource<itk::Image<float, 3u> >::ThreaderCallback (arg=0xa81ab8)
    at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/include/itkImageSource.hxx:295
#4  0x00007fffe9352855 in itk::MultiThreader::SingleMethodProxy (arg=0xa81ab8) at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/src/itkMultiThreader.cxx:375
#5  0x00007ffff7bc69ca in start_thread (arg=<value optimized out>) at pthread_create.c:300
#6  0x00007fffe6ce1cdd in clone () at ../sysdeps/unix/sysv/linux/x86_64/clone.S:112
#7  0x0000000000000000 in ?? ()
```

[area_under_curve](https://github.com/fuentesdt/PkModeling/blob/master/PkSolver/PkSolver.cxx#L328)
```
#0  itk::area_under_curve (signalSize=36, timeAxis=0x7fffb4006d10, concentration=0x7fffb4007490, BATIndex=3, aucTimeInterval=90)
    at /workarea/fuentes/github/PkModeling/PkSolver/PkSolver.cxx:328
#1  0x00007ffff7889095 in itk::ConcentrationToQuantitativeImageFilter<itk::VectorImage<float, 3u>, itk::Image<short, 3u>, itk::Image<float, 3u> >::BeforeThreadedGenerateData (
    this=0x7fffb4000b30) at /workarea/fuentes/github/PkModeling/CLI/itkConcentrationToQuantitativeImageFilter.hxx:284
#2  0x00007ffff7886a27 in itk::ImageSource<itk::Image<float, 3u> >::GenerateData (this=0x7fffb4000b30)
    at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/include/itkImageSource.hxx:227
#3  0x00007fffe9341368 in itk::ProcessObject::UpdateOutputData (this=0x7fffb4000b30)
    at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/src/itkProcessObject.cxx:1743
#4  0x00007fffe93573a9 in itk::DataObject::UpdateOutputData (this=0x7fffb4005000) at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/src/itkDataObject.cxx:434
#5  0x00007ffff7854004 in itk::ImageBase<3u>::UpdateOutputData (this=0x7fffb4005000)
    at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/include/itkImageBase.hxx:285
#6  0x00007fffe935702f in itk::DataObject::Update (this=0x7fffb4005000) at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/src/itkDataObject.cxx:359
#7  0x00007fffe9340288 in itk::ProcessObject::Update (this=0x7fffb4000b30) at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/ITKv4/Modules/Core/Common/src/itkProcessObject.cxx:1324
#8  0x00007ffff77f94f7 in DoIt<short, short> (argc=35, argv=0x7fffffffd998) at /workarea/fuentes/github/PkModeling/CLI/PkModeling.cxx:428
#9  0x00007ffff77ee381 in ModuleEntryPoint (argc=35, argv=0x7fffffffd998) at /workarea/fuentes/github/PkModeling/CLI/PkModeling.cxx:542
#10 0x0000000000401309 in main (argc=35, argv=0x7fffffffd998) at /opt/apps/SLICER/Slicer-SuperBuild-r22599-Debug/Slicer-build/Base/CLI/SEMCommandLineLibraryWrapper.cxx:42
```

# Build
See the [Build Instructions](https://www.slicer.org/slicerWiki/index.php/Documentation/Nightly/Developers/Build_Module)

	$ cmake -DSlicer_DIR:PATH=/path/to/Slicer-Superbuild/Slicer-build .
	$ make

# Create Tags

	ctags -R  --langmap=c++:+.cu --langmap=c++:+.cuh --langmap=c++:+.txx --langmap=c++:+.cl $(SOURCE) .

# Convert Files

	4d images are  multi-component 3d images with time component varying the fastest

	c3d -mcs  QINProstate001-phantom.nrrd -oo QINProstate001-phantom.%04d.nii.gz
	c3d -mcs  Util/test/fit.nrrd -oo Util/test/fit.%04d.nii.gz
	c3d -mcs  Util/phantomfit.nrrd -oo Util/phantomfit.%04d.nii.gz

	c3d phantom.0000.nii.gz phantom.0001.nii.gz phantom.0002.nii.gz phantom.0003.nii.gz phantom.0004.nii.gz phantom.0005.nii.gz phantom.0006.nii.gz phantom.0007.nii.gz phantom.0008.nii.gz phantom.0009.nii.gz phantom.0010.nii.gz phantom.0011.nii.gz phantom.0012.nii.gz phantom.0013.nii.gz phantom.0014.nii.gz phantom.0015.nii.gz phantom.0016.nii.gz phantom.0017.nii.gz phantom.0018.nii.gz phantom.0019.nii.gz phantom.0020.nii.gz phantom.0021.nii.gz phantom.0022.nii.gz phantom.0023.nii.gz phantom.0024.nii.gz phantom.0025.nii.gz phantom.0026.nii.gz phantom.0027.nii.gz phantom.0028.nii.gz phantom.0029.nii.gz phantom.0030.nii.gz phantom.0031.nii.gz phantom.0032.nii.gz phantom.0033.nii.gz phantom.0034.nii.gz phantom.0035.nii.gz phantom.0036.nii.gz phantom.0037.nii.gz phantom.0038.nii.gz phantom.0039.nii.gz phantom.0040.nii.gz phantom.0041.nii.gz phantom.0042.nii.gz phantom.0043.nii.gz phantom.0044.nii.gz phantom.0045.nii.gz phantom.0046.nii.gz phantom.0047.nii.gz phantom.0048.nii.gz phantom.0049.nii.gz phantom.0050.nii.gz phantom.0051.nii.gz phantom.0052.nii.gz phantom.0053.nii.gz phantom.0054.nii.gz phantom.0055.nii.gz phantom.0056.nii.gz phantom.0057.nii.gz phantom.0058.nii.gz phantom.0059.nii.gz  -omc phantom.nrrd

# debug 

	gdb --args lib/Slicer-4.3/cli-modules/PkModeling --T1Blood 1600 --T1Tissue 1600 --relaxivity 0.0039 --S0grad 15.0 --fTolerance 1e-4 --gTolerance 1e-4 --xTolerance 1e-5 --epsilon 1e-9 --maxIter 200 --hematocrit 0.4 --aucTimeInterval 90 --usePopAif  --outputKtrans outktrans.nii.gz --outputVe  outVe.nii.gz --outputFpv outfpv.nii.gz --outputMaxSlope outslope.nii.gz --outputAUC outAUC.nii.gz Data/Brain/DCEraw.nrrd

# CLI usage example

	lib/Slicer-4.3/cli-modules/PkModeling --T1Blood 1600 --T1Tissue 1597 --relaxivity 0.0039 --S0grad 15.0 --fTolerance 1e-4 --gTolerance 1e-4 --xTolerance 1e-5 --epsilon 1e-9 --maxIter 200 --hematocrit 0.4 --aucTimeInterval 90 --computeFpv --usePopAif  --outputKtrans outktrans.nii.gz --outputVe  outVe.nii.gz --outputFpv outfpv.nii.gz --outputMaxSlope outslope.nii.gz --outputAUC outAUC.nii.gz  Data/SampledPhantoms/QINProstate001/Input/QINProstate001-phantom.nrrd


	lib/Slicer-4.3/cli-modules/PkModeling --T1Tissue 1597 --T1Blood 1600 --relaxivity 0.0039 --S0grad 15.0 --hematocrit 0.4 --aucTimeInterval 90 --fTolerance 1e-4 --gTolerance 1e-4 --xTolerance 1e-5 --epsilon 1e-9 --maxIter 200 --outputKtrans /workarea/fuentes/github/PkModeling/Testing/Temporary/QINProstate001-ktrans.nrrd --outputVe /workarea/fuentes/github/PkModeling/Testing/Temporary/QINProstate001-ve.nrrd --outputMaxSlope /workarea/fuentes/github/PkModeling/Testing/Temporary/QINProstate001-maxslope.nrrd --outputAUC /workarea/fuentes/github/PkModeling/Testing/Temporary/QINProstate001-auc.nrrd --outputBAT /workarea/fuentes/github/PkModeling/Testing/Temporary/QINProstate001-bat.nrrd --fitted /workarea/fuentes/github/PkModeling/Testing/Temporary/QINProstate001-fit.nrrd --concentrations /workarea/fuentes/github/PkModeling/Testing/Temporary/QINProstate001-conc.nrrd --roiMask /workarea/fuentes/github/PkModeling/CLI/Testing/Cxx/../../../Data/SampledPhantoms/QINProstate001/Input/QINProstate001-phantom-ROI.nrrd --aifMask /workarea/fuentes/github/PkModeling/CLI/Testing/Cxx/../../../Data/SampledPhantoms/QINProstate001/Input/QINProstate001-phantom-AIF.nrrd /workarea/fuentes/github/PkModeling/CLI/Testing/Cxx/../../../Data/SampledPhantoms/QINProstate001/Input/QINProstate001-phantom.nrrd

c3d /workarea/fuentes/github/PkModeling/CLI/Testing/Cxx/../../../Data/SampledPhantoms/QINProstate001/Baseline/phantom-ktrans.nrrd /workarea/fuentes/github/PkModeling/Testing/Temporary/QINProstate001-ktrans.nrrd  -scale -1 -add /workarea/fuentes/github/PkModeling/CLI/Testing/Cxx/../../../Data/SampledPhantoms/QINProstate001/Input/QINProstate001-phantom-ROI.nrrd -lstat

c3d /workarea/fuentes/github/PkModeling/CLI/Testing/Cxx/../../../Data/SampledPhantoms/QINProstate001/Baseline/phantom-ktrans.nrrd  /workarea/fuentes/github/PkModeling/CLI/Testing/Cxx/../../../Data/SampledPhantoms/QINProstate001/Input/QINProstate001-phantom-ROI.nrrd -lstat


	lib/Slicer-4.3/cli-modules/PkModeling --T1Tissue 1600 --T1Blood 1600 --relaxivity 0.0039 --S0grad 15.0 --hematocrit 0.4 --aucTimeInterval 90 --fTolerance 1e-4 --gTolerance 1e-4 --xTolerance 1e-5 --epsilon 1e-9 --maxIter 200 --outputKtrans test-ktrans.nrrd --outputVe test-ve.nrrd --outputMaxSlope test-maxslope.nrrd --outputAUC test-auc.nrrd --outputBAT test-bat.nrrd --fitted test-fit.nrrd --concentrations test-conc.nrrd --roiMask ./Data/SampledPhantoms/QINProstate001/Input/QINProstate001-phantom-ROI.nrrd --aifMask ./Data/SampledPhantoms/QINProstate001/Input/QINProstate001-phantom-AIF.nrrd ./Data/SampledPhantoms/QINProstate001/Input/QINProstate001-phantom.nrrd


	lib/Slicer-4.3/cli-modules/PkModeling --T1Tissue 1600 --T1Blood 1600 --relaxivity 0.0039 --S0grad 15.0 --hematocrit 0.4 --aucTimeInterval 90 --fTolerance 1e-4 --gTolerance 1e-4 --xTolerance 1e-5 --epsilon 1e-9 --maxIter 200 --outputKtrans ./Util/test/ktrans.nrrd --outputVe ./Util/test/ve.nrrd --outputMaxSlope ./Util/test/maxslope.nrrd --outputAUC ./Util/test/auc.nrrd --outputBAT ./Util/test/bat.nrrd --fitted ./Util/test/fit.nrrd --concentrations ./Util/test/conc.nrrd --roiMask ./Util/newphantom/newphantom.mask.roi.nii.gz --aifMask ./Util/newphantom/newphantom.mask.aif.nii.gz  ./Util/newphantom/newphantom.nrrd
