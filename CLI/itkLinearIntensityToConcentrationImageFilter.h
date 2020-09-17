/*=========================================================================

  Program:   Insight Segmentation & Registration Toolkit
  Module:    $SignalIntensitiesToConcentrationValues: itkLinearIntensityToConcentrationImageFilter.h $
  Language:  C++
  Date:      $Date: 2012/03/07 $
  Version:   $Revision: 0.0 $

  =========================================================================*/
#ifndef __itkLinearIntensityToConcentrationImageFilter_h
#define __itkLinearIntensityToConcentrationImageFilter_h

#include "itkImageToImageFilter.h"
#include "itkImage.h"
#include "itkVectorImage.h"
#include "itkExtractImageFilter.h"
#include "itkImageRegionIterator.h"
#include "itkSignalIntensityToS0ImageFilter.h"
#include "itkImageFileWriter.h"

#include "PkSolver.h"

namespace itk
{
  /** \class LinearIntensityToConcentrationImageFilter
   * \brief Convert from signal intensities to concentrations.
   *
   * This converts an VectorImage of signal intensities into a
   * VectorImage of concentration values. Typical use if for the output
   * image's pixel component type to be floating point.
   *
   * An second input, specifying the location of the arterial input
   * function, allows for the calculation to be adjusted for blood
   * versus tissue.
   *
   * \note
   * This work is part of the National Alliance for Medical Image Computing
   * (NAMIC), funded by the National Institutes of Health through the NIH Roadmap
   * for Medical Research, Grant U54 EB005149.
   *
   */
  template <class TInputImage, class TMaskImage, class TOutputImage>
  class LinearIntensityToConcentrationImageFilter : public ImageToImageFilter < TInputImage, TOutputImage >
  {
  public:
    /** Convenient typedefs for simplifying declarations. */
    typedef TInputImage                             InputImageType;
    typedef typename InputImageType::Pointer        InputImagePointerType;
    typedef typename InputImageType::ConstPointer   InputImageConstPointer;
    typedef typename InputImageType::PixelType      InputPixelType;
    typedef typename InputImageType::RegionType     InputImageRegionType;
    typedef typename InputImageType::SizeType       InputSizeType;
    typedef itk::ImageRegionConstIterator<InputImageType> InputImageConstIterType;

    typedef TMaskImage                              InputMaskType;
    typedef itk::ImageRegionConstIterator<InputMaskType> InputMaskConstIterType;

    typedef TOutputImage                           OutputImageType;
    typedef typename OutputImageType::Pointer      OutputImagePointer;
    typedef typename OutputImageType::ConstPointer OutputImageConstPointer;
    typedef typename OutputImageType::PixelType    OutputPixelType;
    typedef typename OutputImageType::RegionType   OutputImageRegionType;
    typedef itk::ImageRegionIterator<OutputImageType> OutputIterType;

    typedef float                                  FloatPixelType;

    typedef itk::Image<FloatPixelType, TInputImage::ImageDimension> InternalVolumeType;
    typedef typename InternalVolumeType::Pointer         InternalVolumePointerType;
    typedef itk::ImageRegionIterator<InternalVolumeType> InternalVolumeIterType;
    typedef typename InternalVolumeType::RegionType      InternalVolumeRegionType;
    typedef typename InternalVolumeType::SizeType        InternalVolumeSizeType;

    typedef itk::VectorImage<FloatPixelType, TInputImage::ImageDimension> InternalVectorVolumeType;
    typedef typename InternalVectorVolumeType::Pointer         InternalVectorVolumePointerType;
    typedef itk::ImageRegionConstIterator<InternalVectorVolumeType> InternalVectorVolumeConstIterType;
    typedef typename InternalVectorVolumeType::RegionType      InternalVectorVolumeRegionType;
    typedef typename InternalVectorVolumeType::SizeType        InternalVectorVolumeSizeType;

    typedef itk::VariableLengthVector<float> InternalVectorVoxelType;

    /** Standard class typedefs. */
    typedef LinearIntensityToConcentrationImageFilter Self;
    typedef ImageToImageFilter<InputImageType, OutputImageType> Superclass;
    typedef SmartPointer<Self>                                  Pointer;
    typedef SmartPointer<const Self>                            ConstPointer;

    /** Method for creation through the object factory. */
    itkNewMacro(Self);

    /** Run-time type information (and related methods). */
    itkTypeMacro(LinearIntensityToConcentrationImageFilter, ImageToImageFilter);

    /** Set and get the number of DWI channels. */
    itkGetMacro(T1PreBlood, float);
    itkSetMacro(T1PreBlood, float);
    itkGetMacro(T1PreTissue, float);
    itkSetMacro(T1PreTissue, float);
    itkGetMacro(TR, float);
    itkSetMacro(TR, float);
    itkGetMacro(FA, float);
    itkSetMacro(FA, float);
    itkGetMacro(RGD_relaxivity, float);
    itkSetMacro(RGD_relaxivity, float);
    itkGetMacro(S0GradThresh, float);
    itkSetMacro(S0GradThresh, float);
    itkGetMacro(BATCalculationMode, std::string);
    itkSetMacro(BATCalculationMode, std::string);
    itkGetMacro(constantBAT, int);
    itkSetMacro(constantBAT, int);

    // Set a mask image for specifying the location of the arterial
    // input function. This is interpretted as a binary image with
    // nonzero values only at the arterial input function locations.
    void SetAIFMask(InputMaskType* aifMaskVolume)
    {
      this->SetNthInput(1, const_cast<InputMaskType*>(aifMaskVolume));
    }

    // Get the mask image assigned as the arterial input function
    const InputMaskType* GetAIFMask() const
    {
      return dynamic_cast<const InputMaskType*>(this->ProcessObject::GetInput(1));
    }

    // Set a mask image for specifying the location of voxels for model fit.
    void SetROIMask(InputMaskType* roiMaskVolume)
    {
      this->SetNthInput(2, const_cast<InputMaskType*>(roiMaskVolume));
    }

    // Get the mask image specifying the location of voxels for model fit.
    const InputMaskType* GetROIMask() const
    {
      return dynamic_cast<const InputMaskType*>(this->ProcessObject::GetInput(2));
    }

    // Set a T1 Map image for T1
    void SetT1Map(InputMaskType* T1MapVolume)
    {
      this->SetNthInput(3, const_cast<InputMaskType*>(T1MapVolume));
    }

    // Get the mask image specifying the location of voxels for model fit.
    const InputMaskType* GetT1Map() const
    {
      return dynamic_cast<const InputMaskType*>(this->ProcessObject::GetInput(3));
    }

  protected:
    LinearIntensityToConcentrationImageFilter();

    virtual ~LinearIntensityToConcentrationImageFilter()
    {
    }

    void GenerateData();
    OutputImageType* GetAllocatedOutputVolume(const InputImageType* inputVectorVolume);
    InternalVolumePointerType GetS0Image(const InputImageType* inputVectorVolume);
    InternalVectorVoxelType convertToInternalVectorVoxel(const InputPixelType& inputVectorVoxel);


    void PrintSelf(std::ostream& os, Indent indent) const;

  private:
    LinearIntensityToConcentrationImageFilter(const Self &); //
    // purposely
    // not
    // implemented
    void operator=(const Self &);                                      //
    // purposely
    // not
    // implemented

    float m_T1PreBlood;
    float m_T1PreTissue;
    float m_TR;
    float m_FA;
    float m_RGD_relaxivity;
    float m_S0GradThresh;
    std::string m_BATCalculationMode;
    int m_constantBAT;

    //! Private internal helper class to handle getting the correct T1Pre value.
    //! Use it like an Iterator to walk through the voxel positions.
    class T1PreValueMapper {
    public:
      //! Instantiate the Mapper by providing ROI mask, AIF mask, and/or T1 Map (all of which are optional and my be NULL if not available).
      //! Also provide default constant Tissue and Blood value (these are required inputs).
      T1PreValueMapper(const InputMaskType* roiMask, const InputMaskType* aifMask, const InputMaskType* t1Map, float t1PreTissue, float t1PreBlood);
      virtual ~T1PreValueMapper();

      //! Returns the T1Pre value for the current voxel position, based on the availability and validity of ROI/AIF mask and T1 Map at this position.
      float Get();
      void GoToBegin();
      T1PreValueMapper& operator++();

    protected:
      InputMaskConstIterType* getNewConstMaskIterOrNull(const InputMaskType* inMask);

    private:
      InputMaskConstIterType* roiMaskVolumeIter;
      InputMaskConstIterType* aifMaskVolumeIter;
      InputMaskConstIterType* T1MapVolumeIter;
      float m_T1PreTissue;
      float m_T1PreBlood;

    }; // end T1PreValueIterator class

  };

}; // end namespace itk

#ifndef ITK_MANUAL_INSTANTIATION
#include "itkLinearIntensityToConcentrationImageFilter.hxx"
#endif

#endif
