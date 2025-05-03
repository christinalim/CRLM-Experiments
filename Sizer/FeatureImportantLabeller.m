% Assuming you have the following variables loaded:
% vsFeatureNames (1x1155 cell array of strings)
% vdNormalizedAverageFeatureScores (1x1155 double array)

% --- Find the indices of the most important features ---
% You need to define what "most important" means. Here are a few options:

% Option 1: Top N features (e.g., top 10)
nTopFeatures = 20;
[sortedScores, sortedIndices] = sort(vdNormalizedAverageFeatureScores, 'descend');
topNIndices = sortedIndices(1:min(nTopFeatures, length(vdNormalizedAverageFeatureScores)));

disp(['--- Top ', num2str(min(nTopFeatures, length(vdNormalizedAverageFeatureScores))), ' Most Important Features ---']);
for i = 1:length(topNIndices)
    index = topNIndices(i);
    disp(['Rank ', num2str(i), ': Feature "', vsFeatureNames{index}, '" (Importance Score: ', num2str(sortedScores(i)), ')']);
end

% Option 2: Features above a certain importance threshold
importanceThreshold = 0.01; % Adjust this threshold as needed
importantFeatureIndices = find(vdNormalizedAverageFeatureScores > importanceThreshold);

disp(['\n--- Important Features (Importance Score > ', num2str(importanceThreshold), ') ---']);
for i = 1:length(importantFeatureIndices)
    index = importantFeatureIndices(i);
    disp(['Feature "', vsFeatureNames{index}, '" (Importance Score: ', num2str(vdNormalizedAverageFeatureScores(index)), ')']);
end

% Option 3: Percentage of total importance (e.g., features contributing to 90% of total score)
cumulativeImportanceThreshold = 0.90;
sortedScoresForPercentage = sort(vdNormalizedAverageFeatureScores, 'descend');
cumulativeImportance = cumsum(sortedScoresForPercentage) / sum(vdNormalizedAverageFeatureScores);
importantPercentageIndices = find(cumulativeImportance <= cumulativeImportanceThreshold);
if ~isempty(importantPercentageIndices)
    numFeaturesForThreshold = importantPercentageIndices(end);
    topPercentageIndices = sortedIndices(1:numFeaturesForThreshold);
    disp(['\n--- Features Contributing to Top ', num2str(cumulativeImportanceThreshold*100), '% of Importance ---']);
    for i = 1:length(topPercentageIndices)
        index = topPercentageIndices(i);
        disp(['Rank ', num2str(i), ': Feature "', vsFeatureNames{index}, '" (Importance Score: ', num2str(vdNormalizedAverageFeatureScores(index)), ', Cumulative: ', num2str(cumulativeImportance(i)), ')']);
    end
else
    disp(['\n--- Features Contributing to Top ', num2str(cumulativeImportanceThreshold*100), '% of Importance ---']);
    disp('All features contribute less than this threshold.');
end