function [voImageVolumeWithSampleIdsT1, voImageVolumeWithSampleIdsT2] = CreateImageVolumeWithSampleIdsForFeatureExtraction_Demo()
% This demo shows how image volume handlers can be created to join image
% volumes and regions of interest with Group IDs, Sub-Group IDs, Labels,
% etc. before feature extraction is performed

% Signatures for object c
%   oSampleIds = SampleIds(viGroupIds, viSubGroupIds, UserDefinedSampleStrings)
%   oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, viLabels, iPositiveLabel, iNegativeLabel)

% Load image volumes with regions of interest
[voT1Images] = NIfTIImageVolume_CL();

% Create handlers for T1 MRI data:

sFeatureSource = "MRI-T1";

% Example of all parameters being explicitly specified
oSampleIds = SampleIds(int32([1 1 1 1 1 1 1 1 1 1]), int32([1 2 3 4 5 6 7 8 9 10]));
oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([1 1 1 0 1 1 1 1 1 1]), int32(1), int32(0));
oImageVolumeWithSampleIdsPatient001T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
    voT1Images(1), sFeatureSource,...
    oSampleLabels);

% Example of minimal parameters being given
%   setup group and subgroup ids based on the number of ROIs
vsUserDefinedSampleStrings = ["Tumour" "Ventricle"];
dNumRois = length(vsUserDefinedSampleStrings);
oSampleIds = SampleIds(int32(repmat(3,1,dNumRois)), int32(1:1:dNumRois), vsUserDefinedSampleStrings);
oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([1 0]), int32(1), int32(0));
oImageVolumeWithSampleIdsPatient002T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
    voT1Images(2), sFeatureSource,...
    oSampleLabels);

% Example of only processing some ROIs
oSampleIds = SampleIds(int32(4), int32(1), "Ventricle");
oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32(0), int32(1), int32(0));
oImageVolumeWithSampleIdsPatient003T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
    voT1Images(3), sFeatureSource,...
    oSampleLabels,...
    'SampleOrder', 2);

% Vector of all the patients
voImageVolumeWithSampleIdsT1 = [oImageVolumeWithSampleIdsPatient001T1, oImageVolumeWithSampleIdsPatient002T1, oImageVolumeWithSampleIdsPatient003T1];


% % Create handlers for T2 MRI data:

sFeatureSource = "MRI-T2";

% Example of all parameters being explicitly specified
oSampleIds = SampleIds(int32([1 2]), int32([1 1]), ["Ventricle" "Tumour"]);
oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([1 0]), int32(1), int32(0));
oImageVolumeWithSampleIdsPatient001T2 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
    voT2Images(1), sFeatureSource,...
    oSampleLabels,...
    'SampleOrder', [2 1],...
    'ImageInterpretation', '3D');

% Example of minimal parameters being given
oSampleIds = SampleIds(int32([3 3]), int32([1 2]), ["Tumour" "Ventricle"]);
oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([1 0]), int32(1), int32(0));
oImageVolumeWithSampleIdsPatient002T2 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
    voT2Images(2), sFeatureSource,...
    oSampleLabels);

% Example of only processing some ROIs
oSampleIds = SampleIds(int32(4), int32(1), "Ventricle");
oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32(0), int32(1), int32(0));
oImageVolumeWithSampleIdsPatient003T2 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
    voT2Images(3), sFeatureSource,...
    oSampleLabels,...
    'SampleOrder', 2);

voImageVolumeWithSampleIdsT2 = [oImageVolumeWithSampleIdsPatient001T2, oImageVolumeWithSampleIdsPatient002T2, oImageVolumeWithSampleIdsPatient003T2];

end

