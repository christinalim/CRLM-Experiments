classdef LabelledImageVolumeWithSampleIds < ImageVolumeWithSampleIds
    %LabelledImageVolumeWithSampleIds
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 4, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = private, GetAccess = public) % None
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)         
        oSampleLabels (:,1) SampleLabels = BinaryClassificationSampleLabels(SampleIds(0,0), int8(1),int8(0),int8(1)) % TODO: what a hack...please figure out the "empty" for these
    end  
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = LabelledImageVolumeWithSampleIds(oImageVolume, sImageSource, oSampleLabels, NameValueArgs)
            %obj = LabelledImageVolumeWithSampleIds(oImageVolume, sImageSource, oSampleLabels, NameValueArgs)
            %
            % SYNTAX:
            %  obj = FeatureExtractionImagingSeries(oImageVolume, sImageSource, oSampleLabels)
            %  obj = FeatureExtractionImagingSeries(oImageVolume, sImageSource, oSampleLabels, NameValueArgs)
            %
            % DESCRIPTION:
            %  Constructor for LabelledImageVolumeWithSampleIds
            %
            % INPUT ARGUMENTS:
            %  oImageVolume: object of type ImageVolume
            %  sImageSource: string describing the source of the
            %       ImageVolume object
            %  oSampleLabels: object of type SampleLabels
            %
            %  Name-Value Pairs:
            % 'SampleOrder': (Optional) This is a vector of Region of
            %                    Interest numbers (see "RegionsOfInterest")
            %                    that specify in which order the regions of
            %                    interest will have their features
            %                    extracted. This also allows for ROIs
            %                    within the ImageVolume to be excluded from
            %                    having features extracted. **NOTE** This
            %                    vector also determines with
            %                    Group/Sub-Group IDs are linked up with
            %                    each sample. E.g if 'SampleOrder' =
            %                    [4,3,1] and 'GroupIds' = [6,7,8], then ROI
            %                    #4 in the ImageVolume object will be
            %                    assigned Group ID 6, ROI #3 will be ID 7,
            %                    and ROI #1 will be ID 8. ROI #2 will not
            %                    be processed.
            %                    If this value is not specified, the
            %                    default behaviour will be to extract
            %                    features for all ROIs within the
            %                    ImageVolume, in order.
            % 'SetRepresentativeFieldsOfView': (Optional) Values:
            %                    true/false
            %
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                oImageVolume (1,1) ImageVolume {MustHaveRegionsOfInterest(oImageVolume)}
                sImageSource (1,1) string {mustBeNonempty}
                oSampleLabels (:,1) SampleLabels
                NameValueArgs.SampleOrder (:,1) double = []
                NameValueArgs.SetRepresentativeFieldsOfView (1,1) logical = true
            end
                                    
            c1xNameValueArgs = {'SampleOrder',NameValueArgs.SampleOrder,'SetRepresentativeFieldsOfView',NameValueArgs.SetRepresentativeFieldsOfView};
                        
            % Super-class constructor
            obj@ImageVolumeWithSampleIds(oImageVolume, sImageSource, oSampleLabels.GetSampleIds(), c1xNameValueArgs{:});
                        
            % validate samples based on the super-class constructor
            dNumRois = obj.GetNumberOfRegionsOfInterest();
            
            if dNumRois ~= oSampleLabels.GetNumberOfSamples()
                error(...
                    'LabelledImageVolumeWithSampleIds:Constructor:InvalidSampleLabels',...
                    'The number of samples within oSampleLabels does not match the number of regions of interest to be used.');
            end
            
            % set properities
            obj.oSampleLabels = oSampleLabels;
        end 
       
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        function oSampleLabels = GetSampleLabels(obj)
            oSampleLabels = obj.oSampleLabels;
        end  
        
    end
    
    
    methods (Access = public, Static = true)
        
        function oLabels = GetSampleLabelsForAll(voLabelledImageVolumeWithSampleIds)
            arguments
                voLabelledImageVolumeWithSampleIds (1,:) LabelledImageVolumeWithSampleIds
            end
            
            dNumImageVolumeWithSampleIds = length(voLabelledImageVolumeWithSampleIds);
            c1oSampleLabelsPerImageVolumeWithSampleIds = cell(1, dNumImageVolumeWithSampleIds);
            
            sMasterImageSource = voLabelledImageVolumeWithSampleIds(1).sImageSource;
            
            for dImageVolumeWithSampleIdsIndex=1:dNumImageVolumeWithSampleIds
                if sMasterImageSource ~= voLabelledImageVolumeWithSampleIds(dImageVolumeWithSampleIdsIndex).sImageSource
                    error(...
                        'LabelledImageVolumeWithSampleIds:GetSampleLabelsForAll:Invalid',...
                        'All LabelledImageVolumeWithSampleIds objects must have the same Image Source value to have their Sample Labels combined.');
                end
                
                c1oSampleLabelsPerImageVolumeWithSampleIds{dImageVolumeWithSampleIdsIndex} = voLabelledImageVolumeWithSampleIds(dImageVolumeWithSampleIdsIndex).GetSampleLabels();
            end
            
            oLabels = vertcat(c1oSampleLabelsPerImageVolumeWithSampleIds{:});
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
       
    
    methods (Access = protected)
                
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@FeatureExtractionImageVolumeWithSampleIds(obj);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private) % None
    end        
    
    
    methods (Access = private, Static = true) % None
    end 
    
    
    methods (Access = {?Feature}, Static = true)
                    
        function oSampleLabels = GetSampleLabelsForImageVolumesWithSampleIds(voImageVolumeWithSampleIds)
            dNumImageVolumeObjects = length(voImageVolumeWithSampleIds);
            
            if dNumImageVolumeObjects == 0
                oSampleLabels = BinaryClassificationSampleLabels.empty; % TODO figure out BinaryClassifcationSampleLabels.empty
            elseif dNumImageVolumeObjects == 1
                oSampleLabels = voImageVolumeWithSampleIds.GetSampleLabels();
            else
                c1xSampleLabels = cell(1,dNumImageVolumeObjects);
                
                for dInd = 1: dNumImageVolumeObjects
                    c1xSampleLabels{dInd} = voImageVolumeWithSampleIds(dInd).GetSampleLabels();
                end
                
                oSampleLabels = vertcat(c1xSampleLabels{:});                
            end
            
        end
            
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