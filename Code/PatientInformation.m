classdef PatientInformation
    properties
        PatientIndex
        RawLesionData
        LesionLabels
%         LesionSizes
        LesionIndexing
        PatientID
        PatientIDString
        ImagesVectorIndex
    end
    methods
        function obj = PatientInformation(patientIndex, rawLesionData, lesionLabels, lesionIndexing, patientID, patientIDString)
            obj.PatientIndex = patientIndex;
            obj.RawLesionData = rawLesionData;
            obj.LesionLabels = lesionLabels;
%             obj.LesionSizes = lesionSizes;
            obj.LesionIndexing = lesionIndexing;
            obj.PatientID = patientID;
            obj.PatientIDString = patientIDString;
        end
    
        function Images = createImages_T1(obj, sImageBasePath)
            % load up T1 ROIs segmentation (NIfTI format)
            segmentationFilePath = fullfile(...
                    sImageBasePath, obj.PatientIDString, "Segmentation",...
                    obj.PatientID +"_Segmentation.nii"...
                    );
            oT1ROIs = NIfTILabelMapRegionsOfInterest(...
                segmentationFilePath...
             );

            % load up T1 ROIs volume (NIfTI format) with corresponding
            % segmentations
               %     function obj = NIfTIImageVolume(chFilePath, oRegionsOfInterest, NameValueArgs)

            Images = NIfTIImageVolume(...
                fullfile(...
            sImageBasePath,obj.PatientIDString,"Volume",obj.PatientID +"_Volume.nii"),...
                oT1ROIs...
             );
            dMin = Images.GetImageDataMinimumValue();
            dMax = Images.GetImageDataMaximumValue();
            if dMin >= -1 && dMax <= 1
                error("Cannot cast images to integer values because all values are between -1 and 1. See Patient: " + sImageBasePath);
            end
            Images.CastImageDataToType('int16');
        end
          
        function Images = createImages_ALL(obj, sImageBasePath, sFeatureSource)
            % Validate input
            arguments
                obj
                sImageBasePath (1,:) char
                sFeatureSource (1,:) char {mustBeMember(sFeatureSource, {'T1', 'T2', 'DWI'})}
            end

            % Format file names based on modality
            segFileName = obj.PatientID + "_seg_" + sFeatureSource + ".nii";
            volFileName = obj.PatientID + "_Volume_" + sFeatureSource + ".nii";

            % Construct paths
            segmentationFilePath = fullfile(...
                sImageBasePath, obj.PatientIDString, "Segmentations", segFileName);
            volumeFilePath = fullfile(...
                sImageBasePath, obj.PatientIDString, "Volumes", volFileName);


            % Load segmentation and volume
            oROIs = NIfTILabelMapRegionsOfInterest(segmentationFilePath);
            
            %%%%%
            % Read headers again
            volInfo = niftiinfo(volumeFilePath);
            roiInfo = niftiinfo(segmentationFilePath);

            disp("---- Volume Header ----");
            disp("Image Size: " + mat2str(volInfo.ImageSize));
            disp("Pixel Dimensions: " + mat2str(volInfo.PixelDimensions));
            disp("Transform T: "); disp(volInfo.Transform.T);

            disp("---- Segmentation Header ----");
            disp("Image Size: " + mat2str(roiInfo.ImageSize));
            disp("Pixel Dimensions: " + mat2str(roiInfo.PixelDimensions));
            disp("Transform T: "); disp(roiInfo.Transform.T);

            %%%%%
            
            Images = NIfTIImageVolume(volumeFilePath, oROIs);

            % Intensity range check
            dMin = Images.GetImageDataMinimumValue();
            dMax = Images.GetImageDataMaximumValue();
            if dMin >= -1 && dMax <= 1
                error("Cannot cast images to integer values because all values are between -1 and 1. See Patient: " + obj.PatientID);
            end
            Images.CastImageDataToType('int16');
        end


        function obj = setImagesVectorIndex(obj, voImagesVectorIndex)
            obj.ImagesVectorIndex = voImagesVectorIndex;
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
                rawLesionData = patientLesions(i, :);

                % Remove NaNs (trailing or missing lesions)
                rawLesionData = rawLesionData(~isnan(rawLesionData));

                % Filter out lesions with label -1
                validLesionMask = rawLesionData ~= -1;
                filteredLesionData = rawLesionData(validLesionMask);

                % Skip this patient if no valid lesions remain
                if isempty(filteredLesionData)
                    continue;
                end

                % Use only the valid lesion positions for indexing
                lesionLabels = repmat(patientIndex(i), 1, numel(filteredLesionData));
                lesionIndexing = find(validLesionMask);  % Get original lesion positions (e.g., [1, 3, 4])

                % Format patient ID
                patientID = sprintf('%03d', patientIndex(i));  % e.g., '001'
                patientIDString = ['PT', patientID];           % e.g., 'PT001'

                % Create and store PatientInformation object
                newPatient = PatientInformation(...
                    patientIndex(i), ...
                    filteredLesionData, ...
                    lesionLabels, ...
                    lesionIndexing, ...
                    patientID, ...
                    patientIDString ...
                );

                allPatients{i} = newPatient;
            end

        end

        
        function [c1oImages, activePatients] = ExtractPatientImages(allPatients, numPatients, sImageBasePath, sFeatureSource)
            % vector of patient images
            c1oImages = {}; % empty 1 x dNumPatients vector
            activePatients = [];

            if numPatients == -1
                numPatientsIndex = length(allPatients);
            else
                numPatientsIndex = numPatients;
            end

            dImagesVectorIndex = 1;

            % load-up data
            for i=1:numPatientsIndex
                if ~isempty(allPatients{i}.RawLesionData)
                    activePatients{dImagesVectorIndex} = allPatients{i};

                    c1oImages{dImagesVectorIndex} = activePatients{dImagesVectorIndex}.createImages_ALL(sImageBasePath, sFeatureSource);
                    activePatients{dImagesVectorIndex} = activePatients{dImagesVectorIndex}.setImagesVectorIndex(dImagesVectorIndex);

                    disp("Extracted images for " + activePatients{dImagesVectorIndex}.PatientIDString + " for Modality: " + sFeatureSource);

                    dImagesVectorIndex = dImagesVectorIndex + 1;
                end
            end
        end
        
        function [voImageHandlers] = GenerateImageHandlers(voImages, activePatients, sFeatureSource)

            for i = 1:length(voImages)
                % Extract valid lesion info
                lesionLabels = int32(activePatients{i}.LesionLabels);       % patient ID repeated
                lesionIndices = int32(activePatients{i}.LesionIndexing);    % segmentation labels
                lesionTruth = int32(activePatients{i}.RawLesionData);       % 0 = benign, 1 = malignant

                % Sanity check: lengths should match
                if length(lesionLabels) ~= length(lesionIndices) || length(lesionLabels) ~= length(lesionTruth)
                    error("Mismatch in lesion label arrays for patient: " + activePatients{i}.PatientIDString);
                end

                % Debug print
                disp("Patient " + activePatients{i}.PatientIDString + ...
                     " - valid lesion indices used: " + mat2str(lesionIndices) + ...
                     ", labels: " + mat2str(lesionTruth));

                % Assign segmentation IDs and labels
                oSampleIds = SampleIds(lesionLabels, lesionIndices);
                oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, lesionTruth, int32(1), int32(0));

                % Create labeled image volume
                oImageVolumeWithSampleIdsPatient = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
                    voImages(i), sFeatureSource, oSampleLabels);
%                 oImageVolumeWithSampleIdsPatient = LabelledImageVolumeWithSampleIdsForFeatureExtraction(...
%                     voImages(i), sFeatureSource, oSampleLabels, ...
%                     'SampleOrder', lesionIndices);



                % Store handler
                voImageHandlers(i) = oImageVolumeWithSampleIdsPatient;

                disp("Generated ImageHandler for " + activePatients{i}.PatientIDString);
            end

        end

    end
end
