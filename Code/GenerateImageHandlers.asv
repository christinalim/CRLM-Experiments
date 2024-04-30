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
