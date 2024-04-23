function oFeatureValues = ExtractFeatures_CL(voImageVolumeHandlersT1)
% This demo demonstrates how to:
% - choose the features to extract
% - set the feature extraction parameters
% - extract features using a single and multiple cores

% Get image volume handlers from another demo
% [voImageVolumeHandlersT1] = CreateImageVolumeWithSampleIdsForFeatureExtraction_Demo();

% Choose the features to extract
% - Features can be chosen one by one:
voFeaturesToExtract1 = [F010001_Mean, F010003_Range, F010012_Entropy];

% - Features can be chosen by group/family (it is important to specific whether to get features for 2D or 3D ROIs):
voFeaturesToExtract2 = [FirstOrderFeature.GetAllFeatures3D(), ShapeAndSizeFeature.GetAllFeatures3D(), GLCMFeature.GetAllFeatures3D(), GLRLMFeature.GetAllFeatures3D()];

% - All possible features can also be chosen:
voFeaturesToExtract3 = Feature.GetAllFeatures2D();


% Load the parameters from Excel file (to change parameters edit and save
% the Excel file)
oFeatureExtractionParameters = FeatureExtractionParameters(fullfile('FeatureExtraction','Demos','ExtractFeatures_Demo.xlsx'));


% Set the target max memory usage
dMaxMemoryUsage_Gb = 2;


% Extract the features for T1 MRI data using a single core
sDescription = "A Feature Extraction Test of T1 Data";

oFeatureValuesT1 = Feature.ExtractFeaturesForImageVolumeWithSampleIds(...
    voImageVolumeHandlersT1, voFeaturesToExtract1,...
    oFeatureExtractionParameters,...
    sDescription,...
    dMaxMemoryUsage_Gb);


% Extract the features for T2 MRI data using a parallel pool
% sDescription = "A Feature Extraction Test of T2 Data";
% 
% oFeatureValuesT2 = Feature.ExtractFeaturesForImageVolumeWithSampleIds_Parallel(...
%     voImageVolumeHandlersT2, voFeaturesToExtract1,...
%     oFeatureExtractionParameters,...
%     sDescription,...
%     dMaxMemoryUsage_Gb);


% The feature values from each set of image volume handlers are
% concatenated horizontally, as they represent different features for the
% same samples
oFeatureValues = [oFeatureValuesT1];

end