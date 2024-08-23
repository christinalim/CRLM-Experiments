classdef ImageCollection < MachineLearningDataSet & MatrixContainer
    %ImageCollection
    %
    % Joins up ImageVolume objects with SampleIds
    
    % Primary Author: David DeVries
    % Created: June 11, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)        
        oSampleIds (:,1) SampleIds = SampleIds(int8(1), int8(1), "") % TODO figure out SampleIds.empty
        
        vdImageVolumeWithSampleIdsIndexPerSample (:,1) double {mustBeInteger, mustBePositive}
        voImageVolumeWithSampleIds (1,:) ImageVolumeWithSampleIds
        
        vdRegionOfInterestNumberPerSample (:,1) double {mustBeInteger, mustBePositive}
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = ImageCollection(varargin)
            %obj = ImageCollection(varargin)
            %
            % SYNTAX:
            %  obj = ImageCollection(voImageVolumeWithSampleIds)
            %  obj = ImageCollection(obj, vdRowSelection)
            %  obj = ImageCollection(obj)
            %
            % DESCRIPTION:
            %  Constructor for ImageCollection
            %
            % INPUT ARGUMENTS:
            %  voImageVolumeWithSampleIds: TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
           
            if nargin == 1 && isa(varargin{1}, 'ImageVolumeWithSampleIds')
                % For:
                %  obj = ImageCollection(voImageVolumeWithSampleIds)
                
                voImageVolumeWithSampleIds = varargin{1};
                
                ValidationUtils.MustBeA(voImageVolumeWithSampleIds, 'ImageVolumeWithSampleIds');
                ValidationUtils.MustBeRowVector(voImageVolumeWithSampleIds);
                
                % get sample IDs across all ImageVolumeWithSampleIds objects
                oSampleIds = ImageVolumeWithSampleIds.GetSampleIdsForAll(voImageVolumeWithSampleIds);
                
                dNumSamples = oSampleIds.GetNumberOfSamples();
                
                vdImageVolumeWithSampleIdsIndexPerSample = zeros(dNumSamples,1);
                vdRegionOfInterestNumberPerSample = zeros(dNumSamples,1);
                
                dSampleInsertIndex = 1;
                
                for dImageVolumeWithSampleIdsIndex=1:length(voImageVolumeWithSampleIds)
                    vdSampleOrder = voImageVolumeWithSampleIds(dImageVolumeWithSampleIdsIndex).GetSampleOrder();
                    
                    dNumSamplesFromImageVolumeWithSampleIds = length(vdSampleOrder);
                    
                    vdImageVolumeWithSampleIdsIndexPerSample(dSampleInsertIndex : dSampleInsertIndex + dNumSamplesFromImageVolumeWithSampleIds - 1) = dImageVolumeWithSampleIdsIndex;
                    vdRegionOfInterestNumberPerSample(dSampleInsertIndex : dSampleInsertIndex + dNumSamplesFromImageVolumeWithSampleIds - 1) = vdSampleOrder;
                    
                    dSampleInsertIndex = dSampleInsertIndex + dNumSamplesFromImageVolumeWithSampleIds;
                end
                
            elseif nargin == 1
                % For:
                %  obj = ImageCollection(obj)
                
                oCurrentObj = varargin{1};
                
                oSampleIds = oCurrentObj.oSampleIds;
                voImageVolumeWithSampleIds = oCurrentObj.voImageVolumeWithSampleIds;
                vdImageVolumeWithSampleIdsIndexPerSample = oCurrentObj.vdImageVolumeWithSampleIdsIndexPerSample;
                vdRegionOfInterestNumberPerSample = oCurrentObj.vdRegionOfInterestNumberPerSample;
                
            elseif nargin == 2
                % For:
                %  obj = ImageCollection(objCurrent, vdRowSelection)
                
                objCurrent = varargin{1};
                vdRowSelection = varargin{2};
                
                ValidationUtils.MustBeA(objCurrent, 'ImageCollection');
                
                ValidationUtils.MustBeA(vdRowSelection, 'double');
                mustBeInteger(vdRowSelection);
                mustBePositive(vdRowSelection);
                
                if max(vdRowSelection) > objCurrent.GetNumberOfSamples()
                    error(...
                        'ImageCollection:Constructor:InvalidRowSelection',...
                        'The row selection indices must not exceed the number of samples.');
                end
                
                oSampleIds = objCurrent.oSampleIds(vdRowSelection);
                
                vdRegionOfInterestNumberPerSample = objCurrent.vdRegionOfInterestNumberPerSample(vdRowSelection);
                
                [vdImageVolumeWithSampleIdsIndexPerSample, vbImageVolumeWithSampleIds] = MatrixUtils.ApplySelectionToIndexMappingVectorWithMappingRemoval(objCurrent.vdImageVolumeWithSampleIdsIndexPerSample, vdRowSelection);
                voImageVolumeWithSampleIds = objCurrent.voImageVolumeWithSampleIds(vbImageVolumeWithSampleIds);
                vdImageVolumeWithSampleIdsIndexPerSample = vdImageVolumeWithSampleIdsIndexPerSample(vdRowSelection);
            else
                error(...
                    'ImageCollection:Constructor:InvalidNumberOfArguments',...
                    'See constructor documentation for more details.');
            end
            
            % super-class constructor
            obj@MachineLearningDataSet();
            obj@MatrixContainer(oSampleIds);
            
            % local constructor
            obj.oSampleIds = oSampleIds;
            
            obj.voImageVolumeWithSampleIds = voImageVolumeWithSampleIds;
                        
            obj.vdImageVolumeWithSampleIdsIndexPerSample = vdImageVolumeWithSampleIdsIndexPerSample;
            obj.vdRegionOfInterestNumberPerSample = vdRegionOfInterestNumberPerSample;
        end 
        
        function m4xTensor = MakeTensor(obj)
            %m4xTensor = MakeTensor(obj)
            %
            % SYNTAX:
            %  m4xTensor = obj.MakeTensor()
            %
            % DESCRIPTION:
            %  Make an image tensor to be stored in RAM
            %
            % INPUT ARGUMENTS:
            %  obj: ImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  m4xTensor: image tensor (sample, xdim, ydim, channel)
            
            % Grab the first ImageVolumeWithSampleIds object as the baseline to compare all
            % other ImageVolumeWithSampleIds objects to, to make sure they all have the same patch
            % size
            vdPatchSizePerDim = obj.voImageVolumeWithSampleIds(1).GetRASImageVolume().GetRegionsOfInterest().GetPatchSize();
            
            dNumTotalROIs = obj.GetNumberOfSamples();
            
            % pre-allocating tensor for speed
            m4xTensor = zeros(dNumTotalROIs, vdPatchSizePerDim(1), vdPatchSizePerDim(2), vdPatchSizePerDim(3));
            
            % looping through ImageVolumeWithSampleIds object and then filling
            % in all parts of the tensor that derive data from each
            % ImageVolumeWithSampleIds object. This is done looping through ImageVolumeWithSampleIds objects instead of
            % samples such that each image volume only needs to be loaded
            % once.
            for dImageVolumeWithSampelIdsIdx = 1:length(obj.voImageVolumeWithSampleIds)
                % validating that ImageVolumeWithSampleIds object is valid for making tensor
                obj.MustBeUniformRectilinearRegionsOfInterestAndSamePatchSize(dImageVolumeWithSampelIdsIdx, vdPatchSizePerDim);
                
                oImageVolume = obj.voImageVolumeWithSampleIds(dImageVolumeWithSampelIdsIdx).GetRASImageVolume();
                m3xImagingData = oImageVolume.GetImageData();
                
                vdSampleIndicesForImageVolumeWithSampleIds = find(obj.vdImageVolumeWithSampleIdsIndexPerSample == dImageVolumeWithSampelIdsIdx);
                
                % for each sample associated with the ImageVolumeWithSampleIds object get the image
                % data associated with the sample's ROI and place it into
                % the tensor
                for dSampleIdx = 1:length(vdSampleIndicesForImageVolumeWithSampleIds)
                    dROINumber = obj.vdRegionOfInterestNumberPerSample(vdSampleIndicesForImageVolumeWithSampleIds(dSampleIdx));
                    
                    [vdRowBounds, vdColumnBounds, vdSliceBounds] = oImageVolume.oRegionsOfInterest.GetMinimalBoundsByRegionOfInterestNumber(dROINumber);
                    
                    m4xTensor(vdSampleIndicesForImageVolumeWithSampleIds(dSampleIdx),:,:,:) = m3xImagingData(vdRowBounds(1):vdRowBounds(2), vdColumnBounds(1):vdColumnBounds(2), vdSliceBounds(1):vdSliceBounds(2));
                end
            end
        end
        
        function MakeTensorPatches(obj, sPatchSaveDirectoryPath, sPatchFilenamePrefix)
            %MakeTensorPatches(obj)
            %
            % SYNTAX:
            %  obj.MakeTensorPatches(sPatchSaveDirectoryPath)
            %
            % DESCRIPTION:
            %  Make individual image patches to be stored on disk.
            %
            % INPUT ARGUMENTS:
            %  obj: ImageCollection object
            %  sPatchSaveDirectoryPath: string for patch directory to save
            %           patches REQUIRED
            %  sPatchFilenamePrefix: string for naming prefix OPTIONAL
            %
            % OUTPUTS ARGUMENTS:
            %  
            
            arguments
                obj ImageCollection
                sPatchSaveDirectoryPath (1,1) string
                sPatchFilenamePrefix (1,1) string = ""
            end
            
            % Edit filename prefix to be used when saving ROI patches
            sPatchFilenamePrefix = strtrim(sPatchFilenamePrefix);
            
            if sPatchFilenamePrefix.strlength ~= 0
                sPatchFilenamePrefix = sPatchFilenamePrefix + "_";
            end
            
            % Get GroupIds and SubGroupIds to be used for file naming
            dMaxGroupId = max(abs(obj.oSampleIds.GetGroupIds()));
            dNumOfGroupIdDigits = strlength(string(dMaxGroupId));
            
            dMaxSubGroupId = max(abs(obj.oSampleIds.GetSubGroupIds()));
            dNumOfSubGroupIdDigits = strlength(string(dMaxSubGroupId));
            
            % Grab the first ImageVolumeWithSampleIds object as the baseline to compare all
            % other ImageVolumeWithSampleIds objects to, to make sure they all have the same patch
            % size
            vdPatchSizePerDim = obj.voImageVolumeWithSampleIds(1).GetRASImageVolume().GetRegionsOfInterest().GetPatchSize();
            
            % looping through ImageVolumeWithSampleIds objects and then filling
            % in all parts of the tensor that derive data from each
            % object. This is done looping through ImageVolumeWithSampleIds objects instead of
            % samples such that each image volume only needs to be loaded
            % once.
            for dImageVolumeWithSampleIdsIdx = 1:length(obj.voImageVolumeWithSampleIds)
                obj.MustBeUniformRectilinearRegionsOfInterestAndSamePatchSize(dImageVolumeWithSampleIdsIdx, vdPatchSizePerDim)
                
                oImageVolume = obj.voImageVolumeWithSampleIds(dImageVolumeWithSampleIdsIdx).GetRASImageVolume();
                m3xImagingData = oImageVolume.GetImageData();
                
                vdSampleIndiciesForImageVolumeWithSampleIds = find(obj.vdImageVolumeWithSampleIdsIndexPerSample == dImageVolumeWithSampleIdsIdx);
                
                % for each sample associated with the ImageVolumeWithSampleIds object get the image
                % data associated with the sample's ROI and save on disk
                for dSampleIdx = 1:length(vdSampleIndiciesForImageVolumeWithSampleIds)
                    dROINumber = obj.vdRegionOfInterestNumberPerSample(vdSampleIndiciesForImageVolumeWithSampleIds(dSampleIdx));
                    
                    [vdRowBounds, vdColumnBounds, vdSliceBounds] = oImageVolume.oRegionsOfInterest.GetMinimalBoundsByRegionOfInterestNumber(dROINumber);
                    
                    m3xImagePatch = m3xImagingData(vdRowBounds(1):vdRowBounds(2), vdColumnBounds(1):vdColumnBounds(2), vdSliceBounds(1):vdSliceBounds(2));
                    
                    sFileName = ...
                        sPatchFilenamePrefix + ...
                        string(StringUtils.num2str_PadWithZeros(obj.oSampleIds.viGroupIds(vdSampleIndiciesForImageVolumeWithSampleIds(dSampleIdx)), dNumOfGroupIdDigits)) +...
                        "-" +...
                        string(StringUtils.num2str_PadWithZeros(obj.oSampleIds.viSubGroupIds(vdSampleIndiciesForImageVolumeWithSampleIds(dSampleIdx)), dNumOfSubGroupIdDigits)) +...                    
                        ".mat";
                    
                    FileIOUtils.SaveMatFile(...                    
                        fullfile(sPatchSaveDirectoryPath, sFileName),...
                        'm3xImagePatch', m3xImagePatch);
                end
            end
        end
        
        function newObj = Label(obj, oSampleLabels)
            %newObj = Label(obj, oSampleLabels)
            %
            % SYNTAX:
            %  newObj = Label(obj, oSampleLabels)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: ImageCollection object
            %  oSampleLabels: SampleLabels object
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: 
            
            newObj = LabelledImageCollection(obj, oSampleLabels);
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function oSampleIds = GetSampleIds(obj)
            %oSampleIds = GetSampleIds(obj)
            %
            % SYNTAX:
            %  oSampleIds = obj.GetSampleIds()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: ImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oSampleIds = obj.oSampleIds;
        end
        
        function dNumSamples = GetNumberOfSamples(obj)
            %dNumSamples = GetNumberOfSamples(obj)
            %
            % SYNTAX:
            %  dNumSamples = obj.GetNumberOfSamples()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: ImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            dNumSamples = obj.oSampleIds.GetNumberOfSamples();
        end
        
        function [oRASImageVolume, dRoiNumber] = GetImageVolumeAndRegionOfInterestNumberForSample(obj, dSampleNumber)
            oImageVolumeWithSampleIds = obj.voImageVolumeWithSampleIds(obj.vdImageVolumeWithSampleIdsIndexPerSample(dSampleNumber));
            
            oRASImageVolume = oImageVolumeWithSampleIds.GetRASImageVolume();
            dRoiNumber = obj.vdRegionOfInterestNumberPerSample(dSampleNumber);
        end
        
        function sImageSource = GetImageSource(obj)
            sImageSource = obj.voImageVolumeWithSampleIds(1).GetImageSource();
        end        
        
        function oRecord = GetRecordForModel(obj)
            %oRecord = GetRecordForModel(obj)
            %
            % SYNTAX:
            %  oRecord = obj.GetRecordForModel()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: ImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oRecord = ImageCollectionRecordForModel(obj);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj)
            %
            % DESCRIPTION:
            %  Displays a ImageCollection
            %
            % INPUT ARGUMENTS:
            %  obj: ImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            % Headers
            obj.GetSampleIds().PrintHeaders();
            obj.PrintHeaders();
            
            fprintf(newline);
            
            % Print row by row
            for dSampleIndex=1:obj.GetNumberOfSamples()
                obj.GetSampleIds().PrintRowForSample(dSampleIndex);
                obj.PrintRowForSample(dSampleIndex);
                
                fprintf(newline);
            end     
            
            fprintf(newline);
            obj.PrintFooter();
            fprintf(newline);
            
            obj.GetSampleIds().PrintFooter();
        end
        
        function varargout = subsref(obj, stSelection)
            %varargout = subsref(obj, stSelection)
            %
            % SYNTAX:
            %  varargout = subsref(obj, stSelection)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  stSelection: Selection struct. Refer to Matlab documentation
            %               on "subsef"
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: If is was a selection, a LabelledImageCollection object
            %             will be returned. If it was a obj.FnName() call,
            %             anything could be returned
            
            
            % call super-class method that has this call figured out
            switch stSelection(1).type
                case '.' % allow built in function to run (member methods, etc.)
                    [varargout{1:nargout}] = builtin('subsref',obj, stSelection);
                case '()'
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
                    
                    % if it was a selection, don't want to store the whole matrix
                    % as MatrixContainer does, since this is a waste of memory
                    % if we're passing by value
                    % We'll take the choosen selection, and apply it behind the
                    % scenes
                    varargout{1} = ImageCollection(obj, varargout{1}.GetRowSelection());
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
            end
        end
    end
    
    
    methods (Access = public, Static = true)       
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
    end
    
    
    methods (Access = protected, Static = false)  
        
        function PrintHeaders(obj)
            dNumFilePathChars = 40;
            
            fprintf([' %', num2str(dNumFilePathChars), 's | %', num2str(dNumFilePathChars), 's | %5s'], 'Image Filepath', 'ROI Filepath', 'ROI #');
        end
        
        function PrintRowForSample(obj, dSampleIndex)
            dNumFilePathChars = 40;
            
            [oRASImageVolume, dRoiNumber] = obj.GetImageVolumeAndRegionOfInterestNumberForSample(dSampleIndex);
            
            % Image File Path
            chImageFilePath = char(oRASImageVolume.GetMatFilePath());
            
            if isempty(chImageFilePath)
                chImageFilePath = char(oRASImageVolume.GetOriginalFilePath());
            end
            
            dPathLength = length(chImageFilePath);
            
            dStartIndex = max(1, dPathLength - dNumFilePathChars + 1);
            
            chImageFilePath = chImageFilePath(dStartIndex:end);
            
            % ROI File Path
            chROIFilePath = char(oRASImageVolume.GetRegionsOfInterest().GetMatFilePath());
            
            if isempty(chROIFilePath)
                chROIFilePath = char(oRASImageVolume.GetRegionsOfInterest().GetOriginalFilePath());
                
                if isempty(chROIFilePath)
                    chROIFilePath = class(oRASImageVolume.GetRegionsOfInterest());
                end
            end
            
            dPathLength = length(chROIFilePath);
            
            dStartIndex = max(1, dPathLength - dNumFilePathChars + 1);
            
            chROIFilePath = chROIFilePath(dStartIndex:end);
            
            % print line
            fprintf([' %', num2str(dNumFilePathChars), 's | %', num2str(dNumFilePathChars), 's | %5i '], chImageFilePath, chROIFilePath, dRoiNumber);
        end
        
        function PrintFooter(obj)
            fprintf("Image Source: " + obj.GetImageSource());
        end
        
        function newObj = CopyContainedMatrices(obj, newObj)
            %newObj = CopyContainedMatrices(obj, newObj)
            %
            % SYNTAX:
            %  newObj = CopyContainedMatrices(obj, newObj)
            %
            % DESCRIPTION:
            %  Copies any matrix contained in "obj" over to "newObj". If the
            %  contained matrices are handle objects they should be FULLY
            %  COPIED
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  newObj: Copied class object
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copied class object
            
            newObj = obj;
        end
        
        function sStr = GetMultiModalityDataSetDispSummaryString(obj)
            sStr = "Image Source: " + obj.GetImageSource();
        end
    end
    
    
    methods (Access = protected, Static = true)     
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Abstract)
    end
    
    
    methods (Access = private, Static = false)
        
        function MustBeUniformRectilinearRegionsOfInterestAndSamePatchSize(obj, dImageVolumeWithSampleIdsIdx, vdPatchSizePerDim)
            %MustBeUniformRectilinearRegionsOfInterestAndSamePatchSize(obj, dImageVolumeWithSampleIdsIdx, vdPatchSizePerDim)
            %
            % SYNTAX:
            %  MustBeUniformRectilinearRegionsOfInterestAndSamePatchSize(obj, dImageVolumeWithSampleIdsIdx, vdPatchSizePerDim)
            %
            % DESCRIPTION:
            %  Validate each ImageVolumeWithSampleIds in collection contains an
            %  UniformRectilinearRegionsOfInterest object and patch
            %  dimensions are consistent with the baseline patch
            %  dimensions.
            %
            % INPUT ARGUMENTS:
            %  obj: ImageCollection object
            %  dImageVolumeWithSampleIdsIdx: ImageVolumeWithSampleIds index within image collection
            %  vdPatchSizePerDim: patch dimensions
            %
            % OUTPUTS ARGUMENTS:
            %  
            
            if ~isa(obj.voImageVolumeWithSampleIds(dImageVolumeWithSampleIdsIdx).GetRASImageVolume().GetRegionsOfInterest(), 'UniformRectilinearRegionsOfInterest')
                error(...
                    'ImageCollection:MustBeUniformRectilinearRegionsOfInterestAndSamePatchSize:InvalidGeometricalImagingObjectClass',...
                    'ImageVolumeWithSampleIds contains a geomtrical imaging object that is not of UniformRectilinearRegionsOfInterest class.');
            end
            
            if any(obj.voImageVolumeWithSampleIds(dImageVolumeWithSampleIdsIdx).GetRASImageVolume().GetRegionsOfInterest().GetPatchSize() ~= vdPatchSizePerDim)
                error(...
                    'ImageCollection:MustBeUniformRectilinearRegionsOfInterestAndSamePatchSize:InconsistentPatchSize',...
                    'ImageVolumeWithSampleIds contains a patch size that is not consistent.');
            end
        end
    end
    
    
    methods (Access = private, Static = true)
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)        
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

