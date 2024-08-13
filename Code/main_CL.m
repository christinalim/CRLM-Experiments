function [oTuningSet, oTrainingSet, oTestingSet, oGuessResult] = main_CL()

%%%%%%%%%%%%% GENERATE SINGLE IMAGE HANDLERS (DE-BUGGING) %%%%%%%%%%%%%%%%%

% % set-up for data load
% vsPatientCodes = ["PT022"];
% dNumPatients = length(vsPatientCodes);
% 
% c1oT1Images = cell(1, dNumPatients);
% 
% vsPatientID = ["022"];
% sImageBasePath = "D:\Users\CentralLibraryGuest\Christina\Image Database";
% 
% % load-up data
% for dPatientIndex=1:dNumPatients
%     % load up T1 ROIs object (NIfTI format) ? segmentation
%     oT1ROIs = NIfTILabelMapRegionsOfInterest(fullfile(sImageBasePath,vsPatientCodes(dPatientIndex),"Segmentation",vsPatientID(dPatientIndex)+"_Segmentation.nii"));
%     
%     % load up T1 image volume object w/ ROI object supplied (NIfTI format)?
%     % T1 images
%     c1oT1Images{dPatientIndex} = NIfTIImageVolume(fullfile(sImageBasePath,vsPatientCodes(dPatientIndex),"Volume",vsPatientID(dPatientIndex)+"_Volume.nii"), oT1ROIs);
%     dMin = c1oT1Images{dPatientIndex}.GetImageDataMinimumValue();
%     dMax = c1oT1Images{dPatientIndex}.GetImageDataMaximumValue();
%     if dMin >= -1 && dMax <= 1
%         error("Cannot cast images to integer values because all values are between -1 and 1. See Patient:" + dPatientIndex);
%     end
%     c1oT1Images{dPatientIndex}.CastImageDataToType('int16');
% end
% 
% % cast cell arrays into vector of image volume objects
% voT1Images = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oT1Images);
% 
% 
% sFeatureSource = "MRI-T1";
% 
% % Tester patient and lesions
%     % SampleIds (array of group ID #'s for each sample, array of subgroup ID #'s for each sample)
% oSampleIds = SampleIds(int32([1 1 1 1 1 1 1 1]), int32([1 2 3 4 5 6 7 8]));
%     % BinaryClassificationSampleLabels( oSampleIds, array of labels , pos label, neg label)
% oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([1 0 0 0 0 0 1 1]), int32(1), int32(0));
% oImageVolumeWithSampleIdsPatientTest = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
%     voT1Images(1), sFeatureSource,...
%     oSampleLabels);
% 
% voImageHandlers = [oImageVolumeWithSampleIdsPatientTest];


%%%%%%%%%%%%%% GENERATE MULTIPLE NEW IMAGE HANDLERS %%%%%%%%%%%%%%%%

% % Specify the path to lesion CSV file and images/segmentations
% sCsvFileName = "D:\Users\CentralLibraryGuest\Christina\Experiments\Resources\Lesion_Labels.csv";
% sImageBasePath = "D:\Users\CentralLibraryGuest\Christina\Image Database";
% 
% % Specify number of patients to extract data from
% % OPTIONS: integer value OR -1 to do all patients in csv file
% numPatients = 12;
% 
% voImageHandlers = NIfTIImageVolume_CL(sCsvFileName, sImageBasePath, numPatients);
  
%%%%%%%%%%%%% LOAD SAVED IMAGE HANDLERS %%%%%%%%%%%%%%%%%

% voImageHandlers = FileIOUtils.LoadMatFile("D:\Users\CentralLibraryGuest\Christina\Variables\ImageHandlers_24_GLCM.mat", 'voImageHandlers_24_GLCM');
% % for Shape and Size features - problems with images 15, 16, 19, 20, 21
% voImageHandlers = horzcat(voImageHandlers(1:14), voImageHandlers(17:18), voImageHandlers(21));

voImageHandlers = FileIOUtils.LoadMatFile("D:\Users\CentralLibraryGuest\Christina\Variables\ImageHandlers_24_GLCM.mat", 'voImageHandlers_24_GLCM');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

oLabelledFeatureValues = ExtractFeatures_CL(voImageHandlers);
% oLabelledFeatureValues = FileIOUtils.LoadMatFile("D:\Users\CentralLibraryGuest\Christina\Variables\LabelledFeatureValues_12_FTE2.mat", 'LabelledFeatureValues_12_FTE2');

tuningRatio = 0.25;
trainingRatio = 0.5;
testingRatio = 0.25;

[oTuningSet, oTrainingSet, oTestingSet] = CreateTuningTrainingAndTestingDataSets_CL(oLabelledFeatureValues, tuningRatio, trainingRatio, testingRatio);

sOptionsPath = fullfile('HyperParameterOptimizer','Demos','MATLABMachineLearningHyperParameterOptimizerOptions.mat');

oOptimizer = MATLABMachineLearningHyperParameterOptimizer(sOptionsPath, oTuningSet);

% oClassifier = MATLABfitctree(fullfile('DefaultInputs','Classifier','MATLABfitctree_hyperParameters.mat'));

oOptimizedClassifier = MATLABfitctree(...
    fullfile('D:\Users\CentralLibraryGuest\Christina\Variables','MATLABfitctree_hyperParameters.mat'),...
    oOptimizer);

% oOptimizer = oOptimizedClassifier.GetHyperParameterOptimizer();

oTrainedClassifier = oOptimizedClassifier.Train(oTrainingSet);

oGuessResult = Guess(oTrainedClassifier, oTestingSet);

ErrorMetricsCalculator_CL(oGuessResult);

%FeatureSelector_CL(oTuningSet, oTrainingSet, oTestingSet, oOptimizedClassifier)

end