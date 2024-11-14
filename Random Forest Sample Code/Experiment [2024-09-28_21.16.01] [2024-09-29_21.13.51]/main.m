Experiment.StartNewSection('Loading Experiment Assets');
% 
% %%%%%% Change codepaths.txt to your file path for the Central Library %%%%%
% 
% 
% % load experiment asset codes
% 
% % [~, vsClinicalFeatureValueCodes, vsRadiomicFeatureValueCodes, sLabelsCode, sModelCode, sHPOCode, sObjFcnCodeForHPO, sFeatureSelectorCode] = ...
% %     ExperimentManager.LoadExperimentManifestCodesMatFile();
% 
% % % load experiment assets
% oClinicalDataSet = [];
% % oClinicalDataSet = ExperimentManager.GetLabelledFeatureValues(...
% %     vsClinicalFeatureValueCodes,...
% %     sLabelsCode);
% 
% % oRadiomicDataSet = ExperimentManager.GetLabelledFeatureValues(...
% %     vsRadiomicFeatureValueCodes,...
% %     sLabelsCode);
% 
% % if ~isempty(oClinicalDataSet)
% %     oReferenceDataSet = oClinicalDataSet;
% % else
% %     oReferenceDataSet = oRadiomicDataSet;
% % end
% 
% %%%%%%% Load in your Feature Values Table here as 'oRadiomicDataSet' %%%%%%%%
% 
% oRadiomicDataSet = FileIOUtils.LoadMatFile("D:\Users\CentralLibraryGuest\Christina\Experiments\Variables\LabelledFeatureValues_24.mat", 'oLabelledFeatureValues');
% oReferenceDataSet = oRadiomicDataSet;
% 
% oOFN = load('OFN-001-001.mat');
% oOFN = oOFN.oObjectiveFunction;
% oFS = load('FS-001-001.mat');
% oFS = oFS.oFeatureSelector;
% oHPO = load('HPO-001-001.mat');
% oHPO = oHPO.oHyperParameterOptimizer;
% oMDL = load('MDL-001-001.mat');
% oMDL = oMDL.oExperimentModel;
% 
% % set up boot-strapped partitions
% dNumGroupsInTrainingSetMultiplier = 1;
% dNumGroupsInTrainingSet = round(dNumGroupsInTrainingSetMultiplier*oReferenceDataSet.GetNumberOfGroups());
% dNumGroupsInTestingSet = []; % default behaviour
% 
dNumBootstrapReps = 3;
% bAtLeastOneOfEachLabelPerPartition = true;
% 
% vstBootstrappedPartitions = BootstrappingPartition.CreatePartitions(oReferenceDataSet, dNumBootstrapReps, dNumGroupsInTrainingSet, dNumGroupsInTestingSet, bAtLeastOneOfEachLabelPerPartition);
% 
% stTrainAndTestOnAllDataPartition = struct('TrainingIndices', 1:oReferenceDataSet.GetNumberOfSamples(), 'TestingIndices', 1:oReferenceDataSet.GetNumberOfSamples());
% vstBootstrappedPartitions = [vstBootstrappedPartitions; stTrainAndTestOnAllDataPartition];
% 
% 
% 
Experiment.EndCurrentSection();
% 
% 
% % Compute bootstrap iterations
% Experiment.StartNewSection('Bootstrapped Iterations');
% 
% oManager = Experiment.GetLoopIterationManager(dNumBootstrapReps+1, 'AvoidIterationRecomputationIfResumed', true); % "+ 1" for the train and test on full data set iteration needed for AUC_0.632
% 
% parfor dBootstrapRepIndex=1:dNumBootstrapReps+1   
%     if oManager.IterationWasPreviouslyComputed(dBootstrapRepIndex)
%         continue; % don't recomputed it!
%     end
%     
%     oManager.PerLoopIndexSetup(dBootstrapRepIndex);
%     
%     if dBootstrapRepIndex == dNumBootstrapReps+1 % train and test on all the data
%         chFilename = 'Train and Test On All Data Results.mat';        
%     else       
%         chFilename = ['Iteration ', StringUtils.num2str_PadWithZeros(dBootstrapRepIndex, length(num2str(dNumBootstrapReps))), ' Results.mat'];        
%     end
%        
%     % Declare variables (this avoids warnings)
%     oRadiomicTuningAndTrainingSet = [];
%     oRadiomicTestingSet = [];
%     
%     oClinicalTuningAndTrainingSet = [];
%     oClinicalTestingSet = [];
%     
%     oTuningSet = [];
%     oTrainingSet = [];
%     oTestingSet = [];    
%     
%     % Get radiomic data
%     if ~isempty(oRadiomicDataSet)
%         oRadiomicTuningAndTrainingSet = oRadiomicDataSet(vstBootstrappedPartitions(dBootstrapRepIndex).TrainingIndices,:);
%         oRadiomicTestingSet = oRadiomicDataSet(vstBootstrappedPartitions(dBootstrapRepIndex).TestingIndices,:);
%         
%         % Correlation filter
%         oFeatureFilter = oFS.CreateFeatureSelector();
%         oFeatureFilter.SelectFeatures(oRadiomicTuningAndTrainingSet, 'JournalingOn', false);
%         vbRadiomicFeatureMask = oFeatureFilter.GetFeatureMask();
%         
%         oRadiomicTuningAndTrainingSet = oRadiomicTuningAndTrainingSet(:, vbRadiomicFeatureMask);
%         oRadiomicTestingSet = oRadiomicTestingSet(:, vbRadiomicFeatureMask);
%     else
%         vbRadiomicFeatureMask = [];
%     end
%         
%     % Get clinical data
%     if ~isempty(oClinicalDataSet)
%         oClinicalTuningAndTrainingSet = oClinicalDataSet(vstBootstrappedPartitions(dBootstrapRepIndex).TrainingIndices,:);
%         oClinicalTestingSet = oClinicalDataSet(vstBootstrappedPartitions(dBootstrapRepIndex).TestingIndices,:);
%     end
%     
%     % Combine radiomic and clinical data into one data set
%     if ~isempty(oClinicalDataSet) && ~isempty(oRadiomicDataSet)
%         oTuningSet = [oRadiomicTuningAndTrainingSet, oClinicalTuningAndTrainingSet];
%         oTrainingSet = [oRadiomicTuningAndTrainingSet, oClinicalTuningAndTrainingSet];
%         oTestingSet = [oRadiomicTestingSet, oClinicalTestingSet];
%     elseif ~isempty(oClinicalDataSet)
%         oTuningSet = oClinicalTuningAndTrainingSet;
%         oTrainingSet = oClinicalTuningAndTrainingSet;
%         oTestingSet = oClinicalTestingSet;
%     elseif ~isempty(oRadiomicDataSet)
%         oTuningSet = oRadiomicTuningAndTrainingSet;
%         oTrainingSet = oRadiomicTuningAndTrainingSet;
%         oTestingSet = oRadiomicTestingSet;
%     end
%     
%     % Perform hyper-parameter optimization           
%     oHyperParameterOptimizer = oHPO.CreateHyperParameterOptimizer(oOFN, oTuningSet);
%     oClassifier = oMDL.CreateModel(oHyperParameterOptimizer, 'JournalingOn', false);
%     %oClassifier = FileIOUtils.LoadMatFile("D:\Users\CentralLibraryGuest\Christina\Variables\oClassifier_24",'oClassifier');
%     dHyperParameterOptimizationAUC = 1 - oClassifier.GetHyperParameterOptimizer().GetObjectiveFunctionValueAtOptimalHyperParameters();
% 
%     % Train and evaluate classifier
%     oRNG = RandomNumberGenerator();
%     
% %     oRNG.PreLoopSetup(1);
% %     oRNG.PerLoopIndexSetup(1);
%     
%     oTrainedClassifier = oClassifier.Train(oTrainingSet, 'JournalingOn', false);
%     oGuessResult = oTrainedClassifier.Guess(oTestingSet, 'JournalingOn', false);
%     oOOBSamplesGuessResult = oTrainedClassifier.GuessOnOutOfBagSamples();
%     
% %     oRNG.PerLoopIndexTeardown;
% %     oRNG.PostLoopTeardown;
% 
%     % Save artifacts to disk
%     FileIOUtils.SaveMatFile(...
%         fullfile(Experiment.GetResultsDirectory(), chFilename),...
%         'vbRadiomicFeatureMask', vbRadiomicFeatureMask,...
%         'stBootstrappedPartitions', vstBootstrappedPartitions(dBootstrapRepIndex),...
%         'dHyperParameterOptimizationAUC', dHyperParameterOptimizationAUC,...
%         'oConstructedClassifier', oClassifier,...
%         'vdFeatureImportanceScores', oTrainedClassifier.GetFeatureImportanceFromOutOfBagSamples(),...
%         'oGuessResult', oGuessResult,...
%         'oOOBSamplesGuessResult', oOOBSamplesGuessResult,...
%         '-v7', '-nocompression');          
%     
%     % par manager clean-up
%     oManager.PerLoopIndexTeardown();
% end
% 
% oManager.PostLoopTeardown();
% 
% % combine all guess results into a single file

Experiment.StartNewSection('Bootstrapped Iterations');

c1oGuessResultsPerBootstrapPartition = cell(dNumBootstrapReps,1);
c1oOOBSamplesGuessResultsPerBootstrapPartition = cell(dNumBootstrapReps,1);

chResultsDirPath = "D:\Users\CentralLibraryGuest\Christina\Experiments\Random Forest Sample Code\Experiment [2024-09-28_21.16.01]\Results"

for dBootstrapIndex=1:dNumBootstrapReps
    [c1oGuessResultsPerBootstrapPartition{dBootstrapIndex}, c1oOOBSamplesGuessResultsPerBootstrapPartition{dBootstrapIndex}] = FileIOUtils.LoadMatFile(...
        fullfile(chResultsDirPath, ['Iteration ', StringUtils.num2str_PadWithZeros(dBootstrapIndex, length(num2str(dNumBootstrapReps))), ' Results.mat']),...
        'oGuessResult', 'oOOBSamplesGuessResult');
end

FileIOUtils.SaveMatFile(...
    fullfile(chResultsDirPath, 'Partitions & Guess Results.mat'),...
    'c1oGuessResultsPerPartition', c1oGuessResultsPerBootstrapPartition,...
    'c1oOOBSamplesGuessResultsPerPartition', c1oOOBSamplesGuessResultsPerBootstrapPartition,...
    'vstBootstrapPartitions', vstBootstrappedPartitions(1:dNumBootstrapReps));

Experiment.EndCurrentSection();

% calculate AUC

Experiment.StartNewSection('Performance');

[oTrainAndTestOnAllSamplesGuessResultForFeatureCombination] = FileIOUtils.LoadMatFile(fullfile(chResultsDirPath, 'Train and Test On All Data Results.mat'), 'oGuessResult');

% Initialize arrays for storing results across bootstrap replications
vdAUCPerBootstrap = zeros(dNumBootstrapReps,1);
vdAccuracyPerBootstrap = zeros(dNumBootstrapReps,1);
vdPrecisionPerBootstrap = zeros(dNumBootstrapReps,1);
vdRecallPerBootstrap = zeros(dNumBootstrapReps,1);
vdF1PerBootstrap = zeros(dNumBootstrapReps,1);

% Loop through the bootstrap replications and calculate metrics
for dBootstrapIndex=1:dNumBootstrapReps
    % Calculate AUC for each bootstrap
    vdAUCPerBootstrap(dBootstrapIndex) = ErrorMetricsCalculator.CalculateAUC(c1oGuessResultsPerBootstrapPartition{dBootstrapIndex}, 'JournalingOn', false);
    
    % Calculate additional metrics for each bootstrap
    vdAccuracyPerBootstrap(dBootstrapIndex) = ErrorMetricsCalculator.CalculateAccuracy(c1oGuessResultsPerBootstrapPartition{dBootstrapIndex});
    vdPrecisionPerBootstrap(dBootstrapIndex) = ErrorMetricsCalculator.CalculatePrecision(c1oGuessResultsPerBootstrapPartition{dBootstrapIndex});
    vdRecallPerBootstrap(dBootstrapIndex) = ErrorMetricsCalculator.CalculateRecall(c1oGuessResultsPerBootstrapPartition{dBootstrapIndex});
    vdF1PerBootstrap(dBootstrapIndex) = ErrorMetricsCalculator.CalculateF1Score(c1oGuessResultsPerBootstrapPartition{dBootstrapIndex});
end

% Calculate advanced AUC metrics
vdAUC_0Point632PerBootstrap = AdvancedErrorMetricsCalculator.CalculateAUC_0Point632(c1oGuessResultsPerBootstrapPartition, oTrainAndTestOnAllSamplesGuessResultForFeatureCombination);
vdAUC_0Point632PlusPerBootstrap = AdvancedErrorMetricsCalculator.CalculateAUC_0Point632Plus(c1oGuessResultsPerBootstrapPartition, oTrainAndTestOnAllSamplesGuessResultForFeatureCombination);

dAUCTrainAndTestOnAllSamples = ErrorMetricsCalculator.CalculateAUC(oTrainAndTestOnAllSamplesGuessResultForFeatureCombination, 'JournalingOn', false);

[dLPOBAUC, dLPOBAUCStDev] = AdvancedErrorMetricsCalculator.LeaveOnePairOutBootstrapAUCAndStDev(vstBootstrappedPartitions(1:dNumBootstrapReps), c1oGuessResultsPerBootstrapPartition);

% Save metrics to MAT file
FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), 'AUC Metrics.mat'),...
    'vdAUCPerBootstrap', vdAUCPerBootstrap,...
    'vdAUC_0Point632PerBootstrap', vdAUC_0Point632PerBootstrap,...
    'vdAUC_0Point632PlusPerBootstrap', vdAUC_0Point632PlusPerBootstrap,...
    'vdAccuracyPerBootstrap', vdAccuracyPerBootstrap,...   % Save Accuracy
    'vdPrecisionPerBootstrap', vdPrecisionPerBootstrap,... % Save Precision
    'vdRecallPerBootstrap', vdRecallPerBootstrap,...       % Save Recall
    'vdF1PerBootstrap', vdF1PerBootstrap,...               % Save F1-Score
    'dAUCTrainAndTestOnAllSamples', dAUCTrainAndTestOnAllSamples,...
    'dLPOBAUC', dLPOBAUC, 'dLPOBAUCStDev', dLPOBAUCStDev);


Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('AUC: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdAUCPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Median: " + string(median(vdAUCPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("St. Dev.: " + string(std(vdAUCPerBootstrap))));

Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('AUC 0.632: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdAUC_0Point632PerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Median: " + string(median(vdAUC_0Point632PerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("St. Dev.: " + string(std(vdAUC_0Point632PerBootstrap))));

Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('AUC 0.632+: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdAUC_0Point632PlusPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Median: " + string(median(vdAUC_0Point632PlusPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("St. Dev.: " + string(std(vdAUC_0Point632PlusPerBootstrap))));

% AUC Metrics
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('AUC: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdAUCPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Median: " + string(median(vdAUCPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("St. Dev.: " + string(std(vdAUCPerBootstrap))));

% Accuracy
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Accuracy: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdAccuracyPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Median: " + string(median(vdAccuracyPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("St. Dev.: " + string(std(vdAccuracyPerBootstrap))));

% Precision, Recall, F1-Score
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Precision: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdPrecisionPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Recall: " + string(mean(vdRecallPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("F1-Score: " + string(mean(vdF1PerBootstrap))));

% Confusion Matrix Statistics
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Confusion Matrix Statistics: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("TP Mean: " + string(mean(vdTPPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("FP Mean: " + string(mean(vdFPPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("TN Mean: " + string(mean(vdTNPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("FN Mean: " + string(mean(vdFNPerBootstrap))));

% Log Loss (Cross-Entropy Loss)
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Log Loss: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdLogLossPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Median: " + string(median(vdLogLossPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("St. Dev.: " + string(std(vdLogLossPerBootstrap))));

% Specificity
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Specificity: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdSpecificityPerBootstrap))));

% Bias-Variance
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Bias-Variance: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Bias: " + string(mean(vdBiasPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Variance: " + string(mean(vdVariancePerBootstrap))));

% 95% Confidence Interval for AUC
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('95% Confidence Interval for AUC: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Lower Bound: " + string(confidence_lower)));
Experiment.AddToReport(ReportUtils.CreateParagraph("Upper Bound: " + string(confidence_upper)));

% Brier Score (Calibration)
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Brier Score: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdBrierScorePerBootstrap))));

% Training vs Testing Accuracy
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Training Accuracy: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean Training Accuracy: " + string(mean(vdTrainingAccuracyPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean Testing Accuracy: " + string(mean(vdTestingAccuracyPerBootstrap))));

% Feature Importance
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Feature Importance: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Top Features: " + string(top_features)));

% Training Time and Prediction Time
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Training Time: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean Training Time: " + string(mean(vdTrainingTimePerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Prediction Time: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean Prediction Time: " + string(mean(vdPredictionTimePerBootstrap))));


% Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('AUC LPOB: ', ''));
% Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(dLPOBAUC)));
% Experiment.AddToReport(ReportUtils.CreateParagraph("St. Dev.: " + string(dLPOBAUCStDev)));

hFig = figure();
histogram(vdAUCPerBootstrap, 'BinEdges', 0:0.1:1);

chFigSavePath = fullfile(Experiment.GetResultsDirectory(), 'AUC Histogram.fig');

savefig(hFig, chFigSavePath);
Experiment.AddToReport(chFigSavePath);

delete(hFig);

Experiment.EndCurrentSection();