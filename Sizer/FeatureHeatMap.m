% Assuming you have the following variables:
% vsFeatureNames (1xN cell array of strings) - Names of your features
% vdNormalizedAverageFeatureScores (1xN double array) - Importance scores

numTopFeatures = 100;

% --- Sort features by importance and get the top N indices and scores ---
[sortedScores, sortedIndices] = sort(vdNormalizedAverageFeatureScores, 'descend');

if length(sortedIndices) >= numTopFeatures
    topNIndices = sortedIndices(1:numTopFeatures);
else
    topNIndices = sortedIndices; % Take all if fewer than numTopFeatures
    warning(['Fewer than ', num2str(numTopFeatures), ' features found. Displaying all ', num2str(length(topNIndices)), ' features.']);
end

topNFeatureNames = vsFeatureNames(topNIndices);
topNHeatmapData = sortedScores(1:length(topNIndices));

% --- Find unique feature names among the top N (preserving order of importance) ---
[uniqueTopNFeatureLabels, uniqueTopNIndices] = unique(topNFeatureNames, 'stable');
uniqueTopNHeatmapData = topNHeatmapData(uniqueTopNIndices);

% --- Create the heatmap for the unique top features ---
figure;
heatmap(uniqueTopNFeatureLabels, {'Importance'}, uniqueTopNHeatmapData, 'Colormap', parula, 'ColorbarVisible', 'on');

% --- Customize the appearance (optional) ---
title(['Top ', num2str(length(uniqueTopNFeatureLabels)), ' Unique Feature Importance']);
xlabel('Features (Sorted by Importance)');
ylabel('Metric');

% Rotate x-axis labels for better readability
if length(uniqueTopNFeatureLabels) > 10
    ax = gca;
    ax.XAxis.TickLabelRotation = 90;
    ax.XAxis.FontSize = 8; % Adjust font size if needed
end

% Add a title to the colorbar
colorbar_handle = colorbar;
ylabel(colorbar_handle, 'Importance Score', 'Rotation', 270, 'VerticalAlignment', 'bottom');