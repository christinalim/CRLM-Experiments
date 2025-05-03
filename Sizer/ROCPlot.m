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

% --- Plotting ROC Curves for Each Bootstrap (Testing Set) ---
figure; % Create a new figure for the testing set ROCs
hold on; % Allow multiple plots on the same axes
title('ROC Curves for Each Bootstrap (Testing Set)');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
for dBootstrapIndex=1:dNumBootstrapReps
    vdCurrentGuessResults = vdGuessResults{dBootstrapIndex,1};
    allTestLabels = [];
    allTestConfidences = [];
    for dTestCase = 1: length(vdCurrentGuessResults)
        vdTestCaseData = vdCurrentGuessResults(dTestCase,1);
        allTestLabels = [allTestLabels; double(vdTestCaseData.GetLabels())];
        allTestConfidences = [allTestConfidences; double(vdTestCaseData.GetPositiveLabelConfidences())];
    end
    if ~isempty(allTestLabels) && length(unique(allTestLabels)) > 1
        [fpr, tpr, ~] = perfcurve(allTestLabels, allTestConfidences, 1);
        plot(fpr, tpr, 'DisplayName', ['Bootstrap ', num2str(dBootstrapIndex)]);
    else
        warning(['Bootstrap ', num2str(dBootstrapIndex), ': Only one class present in testing set, ROC not plotted.']);
    end
end
plot([0 1], [0 1], 'k--', 'DisplayName', 'Random Classifier'); % Plot the diagonal line for reference
legend('show');
hold off;

% --- Plotting ROC Curves for Each Bootstrap (OOB Set) ---
figure; % Create a new figure for the OOB set ROCs
hold on; % Allow multiple plots on the same axes
title('ROC Curves for Each Bootstrap (OOB Set)');
xlabel('False Positive Rate');
ylabel('True Positive Rate');
for dBootstrapIndex=1:dNumBootstrapReps
    vdOOBCurrentGuessResults = vdOOBGuessResults{dBootstrapIndex,1};
    allOobLabels = [];
    allOobConfidences = [];
    for dOOBTestCase = 1: length(vdOOBCurrentGuessResults)
        vdOOBTestCaseData = vdOOBCurrentGuessResults(dOOBTestCase,1);
        allOobLabels = [allOobLabels; double(vdOOBTestCaseData.GetLabels())];
        allOobConfidences = [allOobConfidences; double(vdOOBTestCaseData.GetPositiveLabelConfidences())];
    end
    if ~isempty(allOobLabels) && length(unique(allOobLabels)) > 1
        [fpr, tpr, ~] = perfcurve(allOobLabels, allOobConfidences, 1);
        plot(fpr, tpr, 'DisplayName', ['Bootstrap ', num2str(dBootstrapIndex)]);
    else
        warning(['Bootstrap ', num2str(dBootstrapIndex), ': Only one class present in OOB set, ROC not plotted.']);
    end
end
plot([0 1], [0 1], 'k--', 'DisplayName', 'Random Classifier'); % Plot the diagonal line for reference
legend('show');
hold off;

clear oLBL sExpCode_Radiomic_LRCP