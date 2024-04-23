classdef PatientInformation
    properties
        PatientIndex
        RawLesionData
        LesionLabels
        LesionIndexing
        PatientID
        PatientIDString
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
    end
end
