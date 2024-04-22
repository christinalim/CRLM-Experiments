function [voImageHandlers] = NIfTIImageVolume_CL()
% This demo shows how to load images and ROIs in the NIfTI Format

% set-up for data load
vsPatientCodes = ["PT002", "PT003"];
dNumPatients = length(vsPatientCodes);

c1oT1Images = cell(1, dNumPatients);

vsPatientID = ["002", "003"];
sImageBasePath = "D:\Users\CentralLibraryGuest\Christina\Image Database";

% load-up data
for dPatientIndex=1:dNumPatients
    % load up T1 ROIs object (NIfTI format) ? segmentation
    oT1ROIs = NIfTILabelMapRegionsOfInterest(fullfile(sImageBasePath,vsPatientCodes(dPatientIndex),"Segmentation",vsPatientID(dPatientIndex)+"_Segmentation.nii"));
    
    % load up T1 image volume object w/ ROI object supplied (NIfTI format)?
    % T1 images
    c1oT1Images{dPatientIndex} = NIfTIImageVolume(fullfile(sImageBasePath,vsPatientCodes(dPatientIndex),"Volume",vsPatientID(dPatientIndex)+"_Volume.nii"), oT1ROIs);
    
end

% cast cell arrays into vector of image volume objects
voT1Images = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oT1Images);


sFeatureSource = "MRI-T1";

% Patient2 is the first volume with 10 lesions
    % SampleIds (array of group ID #'s for each sample, array of subgroup ID #'s for each sample)
oSampleIds = SampleIds(int32([2 2 2 2 2 2 2 2 2 2]), int32([1 2 3 4 5 6 7 8 9 10]));
    % BinaryClassificationSampleLabels( oSampleIds, array of labels , pos label, neg label)
oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([1 1 1 0 1 1 1 1 1 1]), int32(1), int32(0));
oImageVolumeWithSampleIdsPatient002T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
    voT1Images(1), sFeatureSource,...
    oSampleLabels);

% Patient3 is the second volume with 1 lesion (assuming this is a met)
oSampleIds = SampleIds(int32([3]), int32([1]));
oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([0]), int32(1), int32(0));
oImageVolumeWithSampleIdsPatient003T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
    voT1Images(2), sFeatureSource,...
    oSampleLabels);

% % Patient4 
% oSampleIds = SampleIds(int32([4 4 4 4]), int32([1 2 3 4]));
% oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([1 1 0 1]), int32(1), int32(0));
% oImageVolumeWithSampleIdsPatient004T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
%     voT1Images(3), sFeatureSource,...
%     oSampleLabels);
% 
% % Patient5
% oSampleIds = SampleIds(int32([5 5 5 5 5 5 5 5 5]), int32([1 2 3 4 5 6 7 8 9]));
% oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([0 1 1 1 1 1 1 1 1]), int32(1), int32(0));
% oImageVolumeWithSampleIdsPatient005T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
%     voT1Images(4), sFeatureSource,...
%     oSampleLabels);

% % Patient6
% oSampleIds = SampleIds(int32([6 6 6 6 6 6 6 6 6 6]), int32([1 2 3 4 5 6 7 8 9 10]));
% oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([1 1 1 1 1 1 1 1 1 1]), int32(1), int32(0));
% oImageVolumeWithSampleIdsPatient006T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
%     voT1Images(5), sFeatureSource,...
%     oSampleLabels);
% 
% % Patient7
% oSampleIds = SampleIds(int32([7 7 7 7 7]), int32([1 2 3 4 5]));
% oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([0 0 0 0 0]), int32(1), int32(0));
% oImageVolumeWithSampleIdsPatient007T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
%     voT1Images(6), sFeatureSource,...
%     oSampleLabels);
% 
% % Patient8
% oSampleIds = SampleIds(int32([8 8]), int32([1 2]));
% oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([0 0]), int32(1), int32(0));
% oImageVolumeWithSampleIdsPatient008T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
%     voT1Images(7), sFeatureSource,...
%     oSampleLabels);
% 
% % Patient9
% oSampleIds = SampleIds(int32([9 9 9 9 9 9 9]), int32([1 2 3 4 5 6 7]));
% oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([0 0 0 0 0 0 1]), int32(1), int32(0));
% oImageVolumeWithSampleIdsPatient009T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
%     voT1Images(8), sFeatureSource,...
%     oSampleLabels);
% 
% % Patient10
% oSampleIds = SampleIds(int32([10 10 10 10 10 10 10 10 10 10]), int32([1 2 3 4 5 6 7 8 9 10]));
% oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32([1 1 1 1 1 1 1 1 1 1]), int32(1), int32(0));
% oImageVolumeWithSampleIdsPatient010T1 = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
%     voT1Images(9), sFeatureSource,...
%     oSampleLabels);

%

voImageHandlers = [oImageVolumeWithSampleIdsPatient002T1, oImageVolumeWithSampleIdsPatient003T1, oImageVolumeWithSampleIdsPatient004T1, oImageVolumeWithSampleIdsPatient005T1];
%voImageHandlers = [oImageVolumeWithSampleIdsPatient002T1, oImageVolumeWithSampleIdsPatient003T1, oImageVolumeWithSampleIdsPatient004T1, oImageVolumeWithSampleIdsPatient005T1, oImageVolumeWithSampleIdsPatient006T1, oImageVolumeWithSampleIdsPatient007T1, oImageVolumeWithSampleIdsPatient008T1, oImageVolumeWithSampleIdsPatient009T1, oImageVolumeWithSampleIdsPatient010T1];

end