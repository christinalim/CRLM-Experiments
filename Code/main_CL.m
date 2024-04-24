function [oTuningSet, oTrainingSet, oTestingSet, oGuessResult] = main_CL()
%voImageHandlers = NIfTIImageVolume_CL();

%oLabelledFeatureValues = ExtractFeatures_CL(voImageHandlers);

oLabelledFeatureValues = FileIOUtils.LoadMatFile("D:\Users\CentralLibraryGuest\Christina\Variables\Features", 'oLabelledFeatureValues');

[oTuningSet, oTrainingSet, oTestingSet] = CreateTuningTrainingAndTestingDataSets_CL(oLabelledFeatureValues);

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