function [oTuningSet, oTrainingSet, oTestingSet, oGuessResult] = main_CL()

% Specify the path to lesion CSV file and images/segmentations
sCsvFileName = "D:\Users\CentralLibraryGuest\Christina\Experiments\Resources\Lesion_Labels.csv";
sImageBasePath = "D:\Users\CentralLibraryGuest\Christina\Image Database";

% Specify number of patients to extract data from
% OPTIONS: integer value or -1 to do all patients in csv file
numPatients = 5;

voImageHandlers = NIfTIImageVolume_CL(sCsvFileName, sImageBasePath, numPatients);

oLabelledFeatureValues = ExtractFeatures_CL(voImageHandlers);

% oLabelledFeatureValues = FileIOUtils.LoadMatFile("D:\Users\CentralLibraryGuest\Christina\Variables\Features", 'oLabelledFeatureValues');

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

end