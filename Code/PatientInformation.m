classdef PatientInformation
    properties
        PatientIndex
        RawLesionData
        LesionLabels
        LesionIndexing
        PatientID
        PatientIDString
        T1ImagesVectorIndex
    end
    methods
        function obj = PatientInformation(patientIndex, rawLesionData, lesionLabels, lesionIndexing, patientID, patientIDString)
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
            T1Images{dPatientIndex} = NIfTIImageVolume(fullfile(sImageBasePath,obj.PatientIDString,"Volume",obj.PatientID +"_Volume.nii"), oT1ROIs);
        end
           
        function obj = setT1ImagesVectorIndex(obj, voT1ImagesVectorIndex)
            obj.T1ImagesVectorIndex = voT1ImagesVectorIndex;
        end
        
    end
end
