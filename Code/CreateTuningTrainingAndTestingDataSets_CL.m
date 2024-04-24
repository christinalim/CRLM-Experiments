function [oTuningSet, oTrainingSet, oTestingSet] = CreateTuningTrainingAndTestingDataSets_CL(oLabelledFeatureValues)
%  This function takes a labelled feature values object with 100 samples
%  and splits it into a tuning set (40 samples), training set (40 samples),
%  and testing set (20 samples).

% Get labelled feature values object for another demo
% oLabelledFeatureValues = CreateLabelledFeatureValuesFromDataMatrix_Demo();

% Randomly select samples for each set
rng(7); % reproducible randomization
vdSelectionIndices = randperm(oLabelledFeatureValues.GetNumberOfSamples());

%TO DO: make calculations dynamic and handle even/odd values
dNumSamples = oLabelledFeatureValues.GetNumberOfSamples();
dTuningMax = dNumSamples / 4;
dTrainingMin = dTuningMax + 1;
dTrainingMax = dNumSamples / 4 * 3;
dTestingMin = dTrainingMax + 1;

% Create tuning set
% (This is done by selecting all columns, but only specific rows (e.g.
% samples) to be a part of the tuning set. This selection is just like
% working with a 2D matrix)
vdTuningSetRange = 1:dTuningMax;
oTuningSet = oLabelledFeatureValues(vdSelectionIndices(vdTuningSetRange), :);

% Create training set
vdTrainingSetRange = dTrainingMin:dTrainingMax;
oTrainingSet = oLabelledFeatureValues(vdSelectionIndices(vdTrainingSetRange), :);

% Create testing set
vdTestingSetRange = dTestingMin:dNumSamples;
oTestingSet = oLabelledFeatureValues(vdSelectionIndices(vdTestingSetRange), :);

end