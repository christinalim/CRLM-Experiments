
dNumBootstraps = 200;

Experiment.StartNewSection('Progression');
m2bOverallFeatureImportanceMatrix = [];
m2bOverallFeatureRankingMatrix = [];
ZeroCount = 0;
for CurrentExp = 1
    
    %%%%%%%
    sResultsDirectory = 'D:\Users\CentralLibraryGuest\Christina\Experiments\Random Forest Sample Code\Experiment N60 [2024-12-04_08.23.49]\Results'
    % Example for my code: "E:\Users\rpolicelli\Brain Project\LRCP Experiments\EXP\200\003\102R [2023-12-06_21.56.24]\Results";
    
    
    [chExpRoot,~] = FileIOUtils.SeparateFilePathAndFilename(sResultsDirectory);
    sExpRoot = string(chExpRoot);
    
    copyfile(fullfile(sExpRoot, "Experiment Manifest Codes.mat"), "Experiment Manifest Codes.mat");
    
    % load experiment assets
    oClinicalDataSet = [];
    
    %%%%%%%%%%%
    oRadiomicDataSet = FileIOUtils.LoadMatFile("D:\Users\CentralLibraryGuest\Christina\Experiments\Variables\LabelledFeatureValues_60.mat", 'oLabelledFeatureValues');
    
    oReferenceDataSet = oRadiomicDataSet;

    dTotalNumFeatures = oReferenceDataSet.GetNumberOfFeatures();
    vsFeatureNames = oReferenceDataSet.GetFeatureNames();
    
    m2dFeatureRankingScorePerBootstrapPerFeature = nan(dNumBootstraps, dTotalNumFeatures);
    m2dFeatureRankPerBootstrapPerFeature = nan(dNumBootstraps, dTotalNumFeatures);
    
    for dBootstrapIndex=1:dNumBootstraps
        % load artifacts from experiment
        % Note: add zeros to match file nomenclature of iteration results
        clear vbRadiomicFeatureMask vdFeatureImportanceScores
        [vbRadiomicFeatureMask, vdFeatureImportanceScores] = FileIOUtils.LoadMatFile(...
            fullfile(sResultsDirectory, "02 Bootstrapped Iterations", "Iteration " + string(StringUtils.num2str_PadWithZeros(dBootstrapIndex,3)) + " Results.mat"),...
            'vbRadiomicFeatureMask', 'vdFeatureImportanceScores');
        if sum(vdFeatureImportanceScores) == 0
            m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,isnan(m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,:))) = zeros(1,107);
            m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,isnan(m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,:))) = zeros(1,107);
            ZeroCount = ZeroCount+1;
            disp(fullfile(sExpCurrentCode + " " + string(dBootstrapIndex) + " " +ZeroCount))
            continue
        end
        % get data set
        oBootstrapRadiomicDataSet = oRadiomicDataSet(:, vbRadiomicFeatureMask);
        oBootstrapDataSet = oBootstrapRadiomicDataSet;

        vsBootstrapFeatureNames = oBootstrapDataSet.GetFeatureNames();
        
        % calculate feature ranking scores
        vdFeatureRankings = zeros(size(vdFeatureImportanceScores));
        [~, vdSortIndices] = sort(vdFeatureImportanceScores, 'descend');
        
        for dFeatureIndex=1:length(vdFeatureImportanceScores)
            vdFeatureRankings(vdSortIndices(dFeatureIndex)) = dFeatureIndex;
        end
        
        vdNormalizedFeatureImportance = (vdFeatureImportanceScores - min(vdFeatureImportanceScores)) / (max(vdFeatureImportanceScores) - min(vdFeatureImportanceScores));
        
        for dBoostrapFeatureIndex=1:oBootstrapDataSet.GetNumberOfFeatures()
            m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex, vsFeatureNames==vsBootstrapFeatureNames(dBoostrapFeatureIndex)) = vdNormalizedFeatureImportance(dBoostrapFeatureIndex);
            m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex, vsFeatureNames==vsBootstrapFeatureNames(dBoostrapFeatureIndex)) = vdFeatureRankings(dBoostrapFeatureIndex);
        end
        
        m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,isnan(m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,:))) = min(m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,~isnan(m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex,:))));
        m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,isnan(m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,:))) = max(m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,~isnan(m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex,:))));
        
    end
    
    vdAverageFeatureScore = mean(m2dFeatureRankingScorePerBootstrapPerFeature);
    vdAverageFeatureRanking = mean(m2dFeatureRankPerBootstrapPerFeature);
    
    vdNormalizedAverageFeatureScores = (vdAverageFeatureScore - min(vdAverageFeatureScore)) / (max(vdAverageFeatureScore) - min(vdAverageFeatureScore));
    vdNormalizedAverageFeatureRanking = (vdAverageFeatureRanking - min(vdAverageFeatureRanking)) / (max(vdAverageFeatureRanking) - min(vdAverageFeatureRanking));
    m2bOverallFeatureImportanceMatrix = [m2bOverallFeatureImportanceMatrix; vdNormalizedAverageFeatureScores];
    m2bOverallFeatureRankingMatrix = [m2bOverallFeatureRankingMatrix; vdNormalizedAverageFeatureRanking];
end


FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), 'Feature Importance.mat'),...
    'vsFeatureNames', vsFeatureNames,...
    'vdNormalizedAverageFeatureScores', m2bOverallFeatureImportanceMatrix, 'vdNormalizedAverageFeatureRanking', m2bOverallFeatureRankingMatrix);

