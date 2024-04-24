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
            
            dT1ImagesVectorIndex = dT1ImagesVectorIndex + 1;
        end
    end
end