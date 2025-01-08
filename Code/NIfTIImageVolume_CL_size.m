function [voImageHandlersLower, voImageHandlersUpper] = NIfTIImageVolume_CL_size(sCsvFileName, sImageBasePath, numPatients, sSizeLabelCsv)

% Generate lesion data for each patient
allPatients = PatientInformation.ExtractPatientData(sCsvFileName);

% Generate image data for each patient
[c1oT1Images, activePatients] = PatientInformation.ExtractPatientImages(allPatients, numPatients, sImageBasePath);

% cast cell arrays into vector of image volume objects
voT1Images = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oT1Images);

sFeatureSource = "MRI-T1";

dSizeThreshold = 5;

[voImageHandlersLower, voImageHandlersUpper] = PatientInformation.GenerateImageHandlersBySize(voT1Images, activePatients, sFeatureSource, sSizeLabelCsv, dSizeThreshold);

end