function ErrorMetricsCalculator_CL(oGuessResult)

% Get guess result object from another demo
% oGuessResult = ClassifierGuess_Demo();

% First we need to find an optimal threshold
% Our criteria will be closest point to the upper left corner on the ROC
c1xCriteria = {"upperleft","MCR"};
dConfidenceThreshold = ErrorMetricsCalculator.CalculateOptimalThreshold(c1xCriteria,oGuessResult);

% Next, calculate AUC, FNR, FPR, and MCR
dFalsePositiveRate = ErrorMetricsCalculator.CalculateFalsePositiveRate(oGuessResult,dConfidenceThreshold);
dFalseNegativeRate = ErrorMetricsCalculator.CalculateFalseNegativeRate(oGuessResult,dConfidenceThreshold);
dAUC = ErrorMetricsCalculator.CalculateAUC(oGuessResult);
dMisclassificationRate = ErrorMetricsCalculator.CalculateMisclassificationRate(oGuessResult,dConfidenceThreshold);

% Plot the ROC curve associated with this classification
[vdROCXVals,vdROCYVals,~] = ErrorMetricsCalculator.CalculateROCPoints(oGuessResult);
figure
plot(vdROCXVals, vdROCYVals, 'Color', 'r', 'LineWidth', 2);
hold('on');
plot([0 1],[0 1], 'Color', 'k', 'LineWidth', 1, 'LineStyle', '--');
grid('on');
axis('equal');
xlim([0,1]);
ylim([0,1]);
xticks(0:0.1:1);
yticks(0:0.1:1);
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title('ROC Curve');

% Plot the PRROC curve associated with this classification
[vdX,vdY,~] = ErrorMetricsCalculator.CalculatePRROCPoints(oGuessResult);
viLabels = oGuessResult.GetGroundTruthSampleLabels().GetLabels();
iPositiveLabel = oGuessResult.GetGuessResultSampleLabels().GetPositiveLabel();
dNumPositive = sum(viLabels(:)==iPositiveLabel);
dNumNegative = sum(viLabels(:)~=iPositiveLabel);
dRandomPerfLine = dNumPositive/(dNumPositive + dNumNegative);
figure
plot(vdX, vdY, 'Color', 'r', 'LineWidth', 2);
hold('on');
yline(dRandomPerfLine, 'Color', 'k', 'LineWidth', 1, 'LineStyle', '--');
grid('on');
axis('equal');
xlim([0,1]);
ylim([0,1]);
xticks(0:0.1:1);
yticks(0:0.1:1);
xlabel('Recall');
ylabel('Precision');
title('Precision-Recall ROC Curve'); 

% clean-up figures
% close all;
end
