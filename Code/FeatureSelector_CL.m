function FeatureSelector_CL(oTuningSet, oTrainingSet, oTestingSet, oOptimizedClassifier)

% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% Load a feature values table in for the demo and massage input
% [oTuningSet, oTrainingSet, oTestingSet] = CreateTuningTrainingAndTestingDataSets_Demo();
% oOptimizedClassifier = BuildClassifier_WithOptimization_Demo();

% create feature selector table
sName = ["NumFeatures";"Classifier"];
c1xValue = {10;oOptimizedClassifier};
sDatatype = {"double";"object"};
vxRange = {[1,inf];NaN};
tFeatureSelectionParameters_Valid = table(sName,c1xValue,sDatatype,vxRange);
sFeatureSelectionParametersPath = strcat(tempdir,'InputFeatureSelectionParameters.mat');
FileIOUtils.SaveMatFile(sFeatureSelectionParametersPath,'tFeatureSelectionParameters',tFeatureSelectionParameters_Valid);

% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% TTest based feature selector
oTTestSelector = TTestFilterFeatureSelector(fullfile('FeatureSelector','Demos','TTestFilterFeatureSelectorParameters.mat'));

oTTestSelector.SelectFeatures(oTuningSet);

vbFilterFeatureMask = oTTestSelector.GetFeatureMask();


% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% Wrapper based feature selector
oObjectiveFunction = CreateKFoldCrossValidationObjectiveFunction_Demo();
oWrapperSelector = ForwardWrapperFeatureSelector(sFeatureSelectionParametersPath, oObjectiveFunction);

oWrapperSelector.SelectFeatures(oTuningSet, 'Classifier', oOptimizedClassifier, 'NumFeatures', 3, 'Verbose', true);

vbWrapperFeatureMask = oWrapperSelector.GetFeatureMask();


% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% Correlation based feature selector
oCorrelationSelector = CorrelationFilterFeatureSelector(fullfile('FeatureSelector','Demos','CorrelationFilterFeatureSelectorParameters.mat'));

oCorrelationSelector.SelectFeatures(oTuningSet);

vbCorrelationFeatureMask = oCorrelationSelector.GetFeatureMask();


% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% How to mask features?
oTrainingSetWithSelectedFeatures = oTrainingSet(:, vbWrapperFeatureMask);
oTestingSetWithSelectedFeatures = oTestingSet(:, vbWrapperFeatureMask);

end
