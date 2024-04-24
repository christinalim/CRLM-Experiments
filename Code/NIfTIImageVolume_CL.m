function [voImageHandlers] = NIfTIImageVolume_CL()

% Specify the path to lesion CSV file and images/segmentations
sCsvFileName = "D:\Users\CentralLibraryGuest\Christina\Experiments\Resources\Lesion_Labels.csv";
sImageBasePath = "D:\Users\CentralLibraryGuest\Christina\Image Database";

% Specify number of patients to extract data from
% OPTIONS: integer value or -1 to do all patients in csv file
numPatients = 3;

% Generate lesion data for each patient
allPatients = ExtractPatientData(sCsvFileName);

% Generate image data for each patient
[c1oT1Images, activePatients] = ExtractPatientImages(allPatients, numPatients, sImageBasePath);

% cast cell arrays into vector of image volume objects
voT1Images = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oT1Images);

sFeatureSource = "MRI-T1";

voImageHandlers = GenerateImageHandlers(voT1Images, activePatients, sFeatureSource);

end