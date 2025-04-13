dNumBootstrapReps = 100;
dFeatureColumnOfInterest = 37;
% 37 = axial resist column (?)

    % Get Full Experiment Name
 sExpResultsPath = fullfile("D:\Users\CentralLibraryGuest\Christina\Experiments\Random Forest Sample Code\Experiment N60 [2024-11-25_22.16.40]\Results");
 % Load in tHe clinical features table for the experiments
 vdClinicalFeatures = load("D:\Users\CentralLibraryGuest\Christina\Experiments\Variables\LabelledFeatureValues_60.mat");
 % Load the guess results from the testing set
 vdGuessResults = FileIOUtils.LoadMatFile(fullfile(sExpResultsPath, "02 Bootstrapped Iterations", "Partitions & Guess Results.mat"), "c1oGuessResultsPerPartition");
 % Load the guess results from the training set
 vdOOBGuessResults = FileIOUtils.LoadMatFile(fullfile(sExpResultsPath, "02 Bootstrapped Iterations", "Partitions & Guess Results.mat"), "c1oOOBSamplesGuessResultsPerPartition");
 % Initiallize variables
 oGuessResultsForErrorMetrics = [];
  oOOBGuessResultsForErrorMetrics = [];
 for dBootstrapIndex=1:dNumBootstrapReps
        % Extract the testing guess results for this bootstrap
    vdCurrentGuessResults = vdGuessResults{dBootstrapIndex,1};  
    for dTestCase = 1: length(vdCurrentGuessResults)
        % Extract the first datpoint from the the guess results
        vdTestCaseData = vdCurrentGuessResults(dTestCase,1);
        dPatientIndex = find(vdClinicalFeatures.oLabelledFeatureValues.oSampleIds.viGroupIds==vdTestCaseData.GetGroupIds & vdClinicalFeatures.oLabelledFeatureValues.oSampleIds.viSubGroupIds==vdTestCaseData.GetSubGroupIds);
        dRecistSize = vdClinicalFeatures.oLabelledFeatureValues.m2dUnstandardizedFeatures(dPatientIndex, dFeatureColumnOfInterest);
        % If their Site matches the sites of interest, add their confidence
        % and label to the results matrix
        if dRecistSize <=6
            c1vdConfidencesPerBootstrap = vdTestCaseData.GetPositiveLabelConfidences();
            c1vdTrueLabelsPerBootstrap = vdTestCaseData.GetLabels();
            vdLabelAndConfidence = [double(c1vdTrueLabelsPerBootstrap), double(c1vdConfidencesPerBootstrap)];
            oGuessResultsForErrorMetrics = [oGuessResultsForErrorMetrics; vdLabelAndConfidence];
            clear vdLabelAndConfidence
        end
    end
    
    % Extract the testing guess results for this bootstrap   
    vdOOBCurrentGuessResults = vdOOBGuessResults{dBootstrapIndex,1};
    for dOOBTestCase = 1: length(vdOOBCurrentGuessResults)
        % Extract the first datpoint from the the guess results
        vdOOBTestCaseData = vdOOBCurrentGuessResults(dOOBTestCase,1);
        dOOBPatientIndex = find(vdClinicalFeatures.oLabelledFeatureValues.oSampleIds.viGroupIds==vdOOBTestCaseData.GetGroupIds & vdClinicalFeatures.oLabelledFeatureValues.oSampleIds.viSubGroupIds==vdOOBTestCaseData.GetSubGroupIds);
        dOOBRecistSize = vdClinicalFeatures.oLabelledFeatureValues.m2dUnstandardizedFeatures(dOOBPatientIndex, dFeatureColumnOfInterest);
        % If their Site matches the sites of interest, add their confidence
        % and label to the results matrix
        if dOOBRecistSize <=6
            c1vdOOBConfidencesPerBootstrap = vdOOBTestCaseData.GetPositiveLabelConfidences();
            c1vdOOBTrueLabelsPerBootstrap = vdOOBTestCaseData.GetLabels();
            vdOOBLabelAndConfidence = [double(c1vdOOBTrueLabelsPerBootstrap), double(c1vdOOBConfidencesPerBootstrap)];
            oOOBGuessResultsForErrorMetrics = [oOOBGuessResultsForErrorMetrics; vdOOBLabelAndConfidence];
            clear vdOOBLabelAndConfidence
        end
    end
 end
 
% Find the number of positive and negative labels in the concatenated testing guess results
dNumPositives = sum(oGuessResultsForErrorMetrics(:,1));
dNumNegatives = size(oGuessResultsForErrorMetrics,1)-dNumPositives;


[vdAUCAndCI, vdMCRAndCI, vdTNRAndCI, vdTPRAndCI, vdACCAndCI, dPointIndexForOptThres, vdPRAUCAndCI, m2dPRXAndCI, m2dPRYAndCI,m2dXAndCI,m2dYAndCI] = GenerateROCAndCIMetrics(oGuessResultsForErrorMetrics, oOOBGuessResultsForErrorMetrics, dNumPositives, dNumNegatives);
vdAUCAndCIAllExp{CurrentExp} = vdAUCAndCI;
vdTNRAndCIAllExp{CurrentExp} = vdTNRAndCI;
vdTPRAndCIAllExp{CurrentExp} = vdTPRAndCI;
dOptimalThresholdPointIndexAllExp{CurrentExp} = dPointIndexForOptThres;
vdPRAUCAndCIAllExp{CurrentExp} = vdPRAUCAndCI;
m2dPRXAndCIAllExp{CurrentExp} = m2dPRXAndCI;
m2dPRYAndCIAllExp{CurrentExp} = m2dPRYAndCI;
m2dAccuracyExp{CurrentExp} = vdACCAndCI;
clear oLBL sExpCode_Radiomic_LRCP dNumNegatives dNumPositives



function [vdAUCAndCI, vdMCRAndCI, vdTNRAndCI, vdTPRAndCI, vdACCAndCI, dPointIndexForOptThres, vdPRAUCAndCI, m2dPRXAndCI, m2dPRYAndCI,m2dXAndCI,m2dYAndCI] = GenerateROCAndCIMetrics(oGuessResultsForErrorMetrics, oOOBGuessResultsForErrorMetrics, dNumPositives, dNumNegatives)

%Initialize variables
c1oGuessResultsPerPartition = oGuessResultsForErrorMetrics;
c1oOOBGuessResultsPerPartition = oOOBGuessResultsForErrorMetrics;

dPosLabel = 1;

% Extract label and confidences seperatley
for dBootstrapIndex=1:length(c1oGuessResultsPerPartition);
    
    c1vdConfidencesPerBootstrap(dBootstrapIndex) = c1oGuessResultsPerPartition(dBootstrapIndex,2);
    c1vdTrueLabelsPerBootstrap(dBootstrapIndex) = c1oGuessResultsPerPartition(dBootstrapIndex,1);

end
for dBootstrapIndex=1:length(c1oOOBGuessResultsPerPartition)
    
    c1vdOOBConfidencesPerBootstrap(dBootstrapIndex) = c1oOOBGuessResultsPerPartition(dBootstrapIndex,2);
    c1vdOOBTrueLabelsPerBootstrap(dBootstrapIndex) = c1oOOBGuessResultsPerPartition(dBootstrapIndex,1);

end  

% Use perfcurve and non-OOB samples to calculate AUC and PRAUC
[m2dXAndCI, m2dYAndCI, vdT, vdAUCAndCI] = perfcurve(num2cell(c1vdTrueLabelsPerBootstrap), num2cell(c1vdConfidencesPerBootstrap), 1, 'TVals', 0:0.001:1);
[m2dPRXAndCI, m2dPRYAndCI, vdPRT, vdPRAUCAndCI] = perfcurve(num2cell(c1vdTrueLabelsPerBootstrap), num2cell(c1vdConfidencesPerBootstrap), 1,'XCrit','reca','YCrit','prec','TVals', 0:0.001:1);

% Use perfcurve and OOB samples to find optimal threshold (upper
% left)
[m2dOOBX, m2dOOBY, vdOOBT, ~] = perfcurve(num2cell(c1vdOOBTrueLabelsPerBootstrap), num2cell(c1vdOOBConfidencesPerBootstrap), dPosLabel, 'TVals', 0:0.001:1);

vdUpperLeftDist = ((m2dOOBX(:,1)).^2) + ((1-m2dOOBY(:,1)).^2);
[~,dMinIndex] = min(vdUpperLeftDist);
dOptThres = vdOOBT(dMinIndex);

% find the corresponding closest point on the non-OOB ROC for the
% same threshold
[~,dPointIndexForOptThres] = min(abs(dOptThres - vdT(:,1)));

% get FPR, FNR and MCR from ROC
vdFPRAndCI = m2dXAndCI(dPointIndexForOptThres,:); % since ROC
vdTPRAndCI = m2dYAndCI(dPointIndexForOptThres,:); % since ROC

vdFNRAndCI = 1-vdTPRAndCI; % by defn
vdTNRAndCI = 1-vdFPRAndCI; % by defn

vdFNRAndCI([2,3]) = vdFNRAndCI([3,2]); % CIs are backwards
vdTNRAndCI([2,3]) = vdTNRAndCI([3,2]); % CIs are backwards

vdFPAndCI = vdFPRAndCI * dNumNegatives; % by defn
vdFNAndCI = vdFNRAndCI * dNumPositives; % by defn

vdMCRAndCI = (vdFPAndCI + vdFNAndCI) ./ (dNumPositives + dNumNegatives);

vdACCAndCI = (vdTPRAndCI + vdTNRAndCI)/2;

end
