Experiment.StartNewSection('Loading Experiment Assets');

%%%%%% Change codepaths.txt to your file path for the Central Library %%%%%


% load experiment asset codes

% [~, vsClinicalFeatureValueCodes, vsRadiomicFeatureValueCodes, sLabelsCode, sModelCode, sHPOCode, sObjFcnCodeForHPO, sFeatureSelectorCode] = ...
%     ExperimentManager.LoadExperimentManifestCodesMatFile();

% % load experiment assets
oClinicalDataSet = [];
% oClinicalDataSet = ExperimentManager.GetLabelledFeatureValues(...
%     vsClinicalFeatureValueCodes,...
%     sLabelsCode);

% oRadiomicDataSet = ExperimentManager.GetLabelledFeatureValues(...
%     vsRadiomicFeatureValueCodes,...
%     sLabelsCode);

% if ~isempty(oClinicalDataSet)
%     oReferenceDataSet = oClinicalDataSet;
% else
%     oReferenceDataSet = oRadiomicDataSet;
% end

%%%%%%% Load in your Feature Values Table here as 'oRadiomicDataSet' %%%%%%%%

oRadiomicDataSet = FileIOUtils.LoadMatFile("D:\Users\CentralLibraryGuest\Christina\Experiments\Variables\LabelledFeatureValues_24.mat", 'oLabelledFeatureValues');
oReferenceDataSet = oRadiomicDataSet;

oOFN = load('OFN-001-001.mat');
oOFN = oOFN.oObjectiveFunction;
oFS = load('FS-001-001.mat');
oFS = oFS.oFeatureSelector;
oHPO = load('HPO-001-001.mat');
oHPO = oHPO.oHyperParameterOptimizer;
oMDL = load('MDL-001-001.mat');
oMDL = oMDL.oExperimentModel;

% set up boot-strapped partitions
dNumGroupsInTrainingSetMultiplier = 1;
dNumGroupsInTrainingSet = round(dNumGroupsInTrainingSetMultiplier*oReferenceDataSet.GetNumberOfGroups());
dNumGroupsInTestingSet = []; % default behaviour

dNumBootstrapReps = 3;
bAtLeastOneOfEachLabelPerPartition = true;

vstBootstrappedPartitions = BootstrappingPartition.CreatePartitions(oReferenceDataSet, dNumBootstrapReps, dNumGroupsInTrainingSet, dNumGroupsInTestingSet, bAtLeastOneOfEachLabelPerPartition);

stTrainAndTestOnAllDataPartition = struct('TrainingIndices', 1:oReferenceDataSet.GetNumberOfSamples(), 'TestingIndices', 1:oReferenceDataSet.GetNumberOfSamples());
vstBootstrappedPartitions = [vstBootstrappedPartitions; stTrainAndTestOnAllDataPartition];
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

chResultsDirPath = "D:\Users\CentralLibraryGuest\Christina\Experiments\Random Forest Sample Code\Experiment Error Metric\Results\02 Bootstrapped Iterations"

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

% Loop through the bootstrap replications and calculate metrics
for dBootstrapIndex=1:dNumBootstrapReps
    % Calculate AUC for each bootstrap
    vdAUCPerBootstrap(dBootstrapIndex) = ErrorMetricsCalculator.CalculateAUC(c1oGuessResultsPerBootstrapPartition{dBootstrapIndex}, 'JournalingOn', false);

end

for i=1: dNumBootstrapReps               
%Find values with the highest TPR nad lowest FNR
 c1xCriteria = {"upperleft", "FNR"};
 dThreshold(i) = ErrorMetricsCalculator.CalculateOptimalThreshold...
    (c1xCriteria, c1oGuessResultsPerBootstrapPartition{i, 1});
 
%calculate the FNR
dFalseNegativeRate(i) = ErrorMetricsCalculator.CalculateFalseNegativeRate...
    (c1oGuessResultsPerBootstrapPartition{i, 1}, dThreshold(i));
 
%Calculate the FPR
dFalsePositiveRate(i) = ErrorMetricsCalculator.CalculateFalsePositiveRate...
    (c1oGuessResultsPerBootstrapPartition{i, 1}, dThreshold(i));
 
%calculate the misclassification rate
classificationRate(i) = ErrorMetricsCalculator.CalculateMisclassificationRate...
    (c1oGuessResultsPerBootstrapPartition{i, 1}, dThreshold(i));
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
    'dAUCTrainAndTestOnAllSamples', dAUCTrainAndTestOnAllSamples,...
    'dLPOBAUC', dLPOBAUC, 'dLPOBAUCStDev', dLPOBAUCStDev);

% Calculate other metrics
dThresh=(sum(dThreshold)/dNumBootstrapReps);
dFNR=(sum(dFalseNegativeRate)/dNumBootstrapReps);
dFPR=(sum(dFalsePositiveRate)/dNumBootstrapReps);
dMiss=(sum(classificationRate)/dNumBootstrapReps);

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

Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('Other Error Metrics: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Threshold: " + string(dThresh)));
Experiment.AddToReport(ReportUtils.CreateParagraph("False Negative Rate: " + string(dFNR))); 
Experiment.AddToReport(ReportUtils.CreateParagraph("False Positive Rate: " + string(dFPR)));
Experiment.AddToReport(ReportUtils.CreateParagraph("Classification Rate: " + string(dMiss)));


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