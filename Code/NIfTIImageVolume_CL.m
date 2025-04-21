function [voImageHandlers] = NIfTIImageVolume_CL(sCsvFileName, sImageBasePath, numPatients, sFeatureSource)

% Generate lesion data for each patient
allPatients = PatientInformation.ExtractPatientData(sCsvFileName);
allPatients = allPatients(~cellfun(@isempty, allPatients));  % remove empty entries

% Generate image data for each patient
[c1oImages, activePatients] = PatientInformation.ExtractPatientImages(allPatients, numPatients, sImageBasePath, sFeatureSource);

% cast cell arrays into vector of image volume objects
voT1Images = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oImages);

voImageHandlers = PatientInformation.GenerateImageHandlers(voT1Images, activePatients, sFeatureSource);

end