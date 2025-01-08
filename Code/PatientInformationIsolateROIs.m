classdef PatientInformationIsolateROIs
    properties
        PatientIndex
        RawLesionData
        LesionLabels
        LesionIndexing
        PatientID
        PatientIDString
        T1ImagesVectorIndex
        SampleOrder
    end
    methods
        function obj = PatientInformationIsolateROIs(patientIndex, rawLesionData, lesionLabels, lesionIndexing, patientID, patientIDString)
            obj.PatientIndex = patientIndex;
            obj.RawLesionData = rawLesionData;
            obj.LesionLabels = lesionLabels;
            obj.LesionIndexing = lesionIndexing;
            obj.PatientID = patientID;
            obj.PatientIDString = patientIDString;
        end
        
        function T1Images = createT1Images(obj, sImageBasePath)
            % load up T1 ROIs segmentation (NIfTI format)
            oT1ROIs = NIfTILabelMapRegionsOfInterest(fullfile(sImageBasePath,obj.PatientIDString,"Segmentation",obj.PatientID +"_Segmentation.nii"));

            % load up T1 ROIs volume (NIfTI format) with corresponding
            % segmentations
            T1Images = NIfTIImageVolume(fullfile(sImageBasePath,obj.PatientIDString,"Volume",obj.PatientID +"_Volume.nii"), oT1ROIs);
            dMin = T1Images.GetImageDataMinimumValue();
            dMax = T1Images.GetImageDataMaximumValue();
            if dMin >= -1 && dMax <= 1
                error("Cannot cast images to integer values because all values are between -1 and 1. See Patient: " + sImageBasePath);
            end
            T1Images.CastImageDataToType('int16');
        end
           
        function obj = setT1ImagesVectorIndex(obj, voT1ImagesVectorIndex)
            obj.T1ImagesVectorIndex = voT1ImagesVectorIndex;
        end
        
    end
    
    methods (Static)
        function [allPatients] = ExtractPatientData(sCsvFileName)

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

        end
        
        function [c1oT1Images, activePatients] = ExtractPatientImages(allPatients, numPatients, sImageBasePath)
            c1oT1Images = {}; % empty 1 x dNumPatients vector
            activePatients = [];

            if numPatients == -1
                numPatientsIndex = length(allPatients);
            else
                numPatientsIndex = numPatients;
            end

            dT1ImagesVectorIndex = 1;

            % load-up data
            for i=1:numPatientsIndex
                if ~isempty(allPatients{i}.RawLesionData)
                    activePatients{dT1ImagesVectorIndex} = allPatients{i};

                    c1oT1Images{dT1ImagesVectorIndex} = activePatients{dT1ImagesVectorIndex}.createT1Images(sImageBasePath);
                    activePatients{dT1ImagesVectorIndex} = activePatients{dT1ImagesVectorIndex}.setT1ImagesVectorIndex(dT1ImagesVectorIndex);

                    disp("Extracted images for " + activePatients{dT1ImagesVectorIndex}.PatientIDString);

                    dT1ImagesVectorIndex = dT1ImagesVectorIndex + 1;
                end
            end
        end
        
        function [voImageHandlers] = GenerateImageHandlers(voT1Images, activePatients, sFeatureSource)

            for i=1:length(voT1Images)
                % Patient2 is the first volume with 10 lesions
                % SampleIds (array of group ID #'s for each sample, array of subgroup ID #'s for each sample)
                oSampleIds = SampleIds(int32(activePatients{i}.LesionLabels), int32(activePatients{i}.LesionIndexing));

                % BinaryClassificationSampleLabels( oSampleIds, array of labels , pos label, neg label)
                oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32(activePatients{i}.RawLesionData), int32(1), int32(0));
                oImageVolumeWithSampleIdsPatient = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
                    voT1Images(i), sFeatureSource,...
                    oSampleLabels);
                voImageHandlers(i) = oImageVolumeWithSampleIdsPatient;

               disp("Generated ImageHandler for " + activePatients{i}.PatientIDString);

            end

        end

        function [voImageHandlers] = GenerateImageHandlersWithSampleOrder(voT1Images, activePatients, sFeatureSource, vdSampleOrder)

            for i=1:length(voT1Images)
                % Patient2 is the first volume with 10 lesions
                % SampleIds (array of group ID #'s for each sample, array of subgroup ID #'s for each sample)
                oSampleIds = SampleIds(int32(activePatients{i}.LesionLabels), int32(activePatients{i}.LesionIndexing));

                % BinaryClassificationSampleLabels( oSampleIds, array of labels , pos label, neg label)
                oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, int32(activePatients{i}.RawLesionData), int32(1), int32(0));
                oImageVolumeWithSampleIdsPatient = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
                    voT1Images(i), sFeatureSource,...
                    oSampleLabels,...
                    'SampleOrder', vdSampleOrder{i});
                voImageHandlers(i) = oImageVolumeWithSampleIdsPatient;

               disp("Generated ImageHandler for " + activePatients{i}.PatientIDString);

            end

        end
        
        
    end
end
