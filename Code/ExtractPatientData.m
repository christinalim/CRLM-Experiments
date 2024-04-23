function [c1oT1Images] = ExtractPatientData()
    % Specify the path to your CSV file
    sCsvFileName = "/Users/clim/Developer/GitHub/CRLM-Experiments/Resources/Lesion_Labels.csv";

    % Read the CSV file
    data = readmatrix(sCsvFileName, 'Delimiter', ',');

    % Extract patient IDs and lesion data
    patientIndex = data(:, 1);
    patientLesions = data(:, 2:end);

    % Initialize a cell array to store instances of PatientInformation
    allPatients = cell(size(patientLesions, 1), 1);
    dNumPatients = length(allPatients);
    
    % Extract and initialize instances of PatientInformation
    for i = 1:dNumPatients
        % Remove trailing zeros
        rawLesionData = patientLesions(i, :);
        rawLesionData = rawLesionData(~isnan(rawLesionData));
        % Create arrays for value 1 and value 2
        lesionLabels = repmat(patientIndex(i), 1, numel(rawLesionData));
        lesionIndexing = 1:numel(rawLesionData);
        % Generate value 5 and value 6
        patientID = sprintf('%03d', patientIndex(i));  % Formats patient ID with leading zeros
        patientIDString = ['PT', patientID];  % Concatenates "PT" with formatted patient ID
        % Store patient ID, extracted values, value 1 array, value 2 array, value 5, and value 6 as a tuple

        newPatient = PatientInformation(patientIndex(i), rawLesionData, lesionLabels, lesionIndexing, patientID, patientIDString);

        allPatients{i} = newPatient;
    end
    
    c1oT1Images = cell(1, dNumPatients); % empty 1 x dNumPatients vector
    sImageBasePath = "D:\Users\CentralLibraryGuest\Christina\Image Database";
    
    % for loop that iterates through all patients and runs the following
    % code on the patient data if rawLesionData is not an empty array
        
    % load-up data
    for i=1:dNumPatients
        if ~isempty(rawLesionData{i})
            c1oT1Images{i} = allPatients{i}.createT1Images(sImageBasePath);
            allPatients{i}.setT1ImagesVectorIndex(i);
        end
    end

end
