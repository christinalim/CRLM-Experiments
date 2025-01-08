function main_CL()

% Specify the path to lesion CSV file and images/segmentations
sCsvFileName = "D:\Users\CentralLibraryGuest\Christina\Experiments\Resources\Lesion_Labels_24_Large.csv";
sImageBasePath = "D:\Users\CentralLibraryGuest\Christina\Image Database";

% Specify number of patients to extract data from
% OPTIONS: integer value OR -1 to do all patients in csv file
numPatients = 24;
vdSampleOrder_Large = {[1,2,3,4,6,7],[1],[1,2],[1,2,3,4,5,6,7,8,9],[1,2,3,4,5,6,7,8,9,10],[1,2,3,4,5],[1,2],[3,7],[1,2,3,4,5,6,7,8,9,10],[1,2,3,4,5,6,7,8,9,10],[1,2],[1,2,3,4,5,6,7,8,9,10],[1,2,3,4],[1,2,3,4,6,7,8,9,10],[1,4],[1,2],[3],[6,7],[1,2],[1],[1,3,4]};
vdSampleOrder_Small = {[5,8,9,10],[3,4],[1,2,4,5,6],[5],[1,2,3,4], [2,3], [1,2], [1,2,3,4,5,8],[3,4,5,6,7,8],[2]};

% indicate size for vdSampleOrder variable here
voImageHandlers = NIfTIImageVolumeIsolateROIs(sCsvFileName, sImageBasePath, numPatients, vdSampleOrder_Large);

% FileIOUtils.SaveMatFile('D:\Users\CentralLibraryGuest\Christina\Experiments\Variables\ImageHandlers_24_Small.mat','voImageHandlersSmall', voImageHandlers);
FileIOUtils.SaveMatFile('D:\Users\CentralLibraryGuest\Christina\Experiments\Variables\ImageHandlers_24_Large.mat','voImageHandlersLarge', voImageHandlers);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

oLabelledFeatureValues = ExtractFeatures_CL(voImageHandlers);
% oLabelledFeatureValues = FileIOUtils.LoadMatFile("D:\Users\CentralLibraryGuest\Christina\Variables\LabelledFeatureValues_24.mat", 'oLabelledFeatureValues');
FileIOUtils.SaveMatFile('D:\Users\CentralLibraryGuest\Christina\Experiments\Variables\LabelledFeatureValues_24_Large.mat','oLabelledFeatureValues', oLabelledFeatureValues);


end