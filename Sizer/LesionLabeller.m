dNumBootstrapReps = 5;
dFeatureColumnOfInterest = 37;
% 37 = axial resist column (?)

% Get Full Experiment Name
sExpResultsPath = fullfile("/Users/clim/Developer/Experiment T1_T2_DWI [2025-04-30_21.22.41]/Results");
% Load in tHe clinical features table for the experiments
vdClinicalFeatures = load("/Users/clim/Developer/GitHub/CRLM-Experiments/Variables/LabelledFeatureValues_ALL_60.mat");
% Load the guess results from the testing set
vdGuessResults = FileIOUtils.LoadMatFile(fullfile(sExpResultsPath, "02 Bootstrapped Iterations", "Partitions & Guess Results.mat"), "c1oGuessResultsPerPartition");
% Load the guess results from the training set
vdOOBGuessResults = FileIOUtils.LoadMatFile(fullfile(sExpResultsPath, "02 Bootstrapped Iterations", "Partitions & Guess Results.mat"), "c1oOOBSamplesGuessResultsPerPartition");

% Initialize variables to store AUCs
testingAUCsPerBootstrap = zeros(dNumBootstrapReps, 1);
oobAUCsPerBootstrap = zeros(dNumBootstrapReps, 1);

for dBootstrapIndex=1:dNumBootstrapReps
    % --- Testing Set AUC ---
    vdCurrentGuessResults = vdGuessResults{dBootstrapIndex,1};
    allTestLabels = [];
    allTestConfidences = [];
    for dTestCase = 1: length(vdCurrentGuessResults)
        vdTestCaseData = vdCurrentGuessResults(dTestCase,1);
        allTestLabels = [allTestLabels; double(vdTestCaseData.GetLabels())];
        allTestConfidences = [allTestConfidences; double(vdTestCaseData.GetPositiveLabelConfidences())];
    end
    if ~isempty(allTestLabels) && length(unique(allTestLabels)) > 1
        [~, ~, ~, auc] = perfcurve(allTestLabels, allTestConfidences, 1);
        testingAUCsPerBootstrap(dBootstrapIndex) = auc;
    else
        testingAUCsPerBootstrap(dBootstrapIndex) = NaN; % Handle cases with single label
        warning(['Bootstrap ', num2str(dBootstrapIndex), ': Only one class present in testing set, AUC set to NaN.']);
    end

    % --- OOB Set AUC ---
    vdOOBCurrentGuessResults = vdOOBGuessResults{dBootstrapIndex,1};
    allOobLabels = [];
    allOobConfidences = [];
    for dOOBTestCase = 1: length(vdOOBCurrentGuessResults)
        vdOOBTestCaseData = vdOOBCurrentGuessResults(dOOBTestCase,1);
        allOobLabels = [allOobLabels; double(vdOOBTestCaseData.GetLabels())];
        allOobConfidences = [allOobConfidences; double(vdOOBTestCaseData.GetPositiveLabelConfidences())];
    end
    if ~isempty(allOobLabels) && length(unique(allOobLabels)) > 1
        [~, ~, ~, auc] = perfcurve(allOobLabels, allOobConfidences, 1);
        oobAUCsPerBootstrap(dBootstrapIndex) = auc;
    else
        oobAUCsPerBootstrap(dBootstrapIndex) = NaN; % Handle cases with single label
        warning(['Bootstrap ', num2str(dBootstrapIndex), ': Only one class present in OOB set, AUC set to NaN.']);
    end
end

% Display the extracted AUCs
disp('Testing Set AUCs per Bootstrap Iteration:');
disp(testingAUCsPerBootstrap);

disp('OOB Set AUCs per Bootstrap Iteration:');
disp(oobAUCsPerBootstrap);

% --- Optional: Save AUCs to .mat file ---
sAucSavePath = fullfile(sExpResultsPath, "bootstrap_aucs.mat");
save(sAucSavePath, 'testingAUCsPerBootstrap', 'oobAUCsPerBootstrap');

% --- Optional: Save AUCs to .csv file ---
testingAucTable = table(testingAUCsPerBootstrap);
oobAucTable = table(oobAUCsPerBootstrap);

sTestingAucCsvPath = fullfile(sExpResultsPath, "testing_bootstrap_aucs.csv");
sOobAucCsvPath = fullfile(sExpResultsPath, "oob_bootstrap_aucs.csv");

writetable(testingAucTable, sTestingAucCsvPath);
writetable(oobAucTable, sOobAucCsvPath);

clear oLBL sExpCode_Radiomic_LRCP