classdef LabelledImageVolumeWithSampleIdsForFeatureExtraction < ImageVolumeWithSampleIdsForFeatureExtraction & LabelledImageVolumeWithSampleIds
    %LabelledImageVolumeWithSampleIdsForFeatureExtraction
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = private, GetAccess = public) % None
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)         
    end  
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public)
        
        function obj = LabelledImageVolumeWithSampleIdsForFeatureExtraction(oImageVolume, sImageSource , oSampleLabels, NameValueArgs)
            %obj = LabelledImageVolumeWithSampleIdsForFeatureExtraction(oImageVolume, sImageSource , oSampleLabels, NameValueArgs)
            %
            % SYNTAX:
            %  obj = FeatureExtractionImagingSeries(oImageVolume, sImageSource, oSampleLabels, Name, Value)
            %
            % INPUT ARGUMENTS:
            %  oImageVolume: object of type ImageVolume
            %  sImageSource: string describing the source of the
            %       ImageVolume object
            %  oSampleLabels: object of type SampleLabels
            %
            %  Name-Value Pairs:
            % 'SampleOrder':     (Optional) This is a vector of Region of
            %                    Interest numbers (see "RegionsOfInterest")
            %                    that specify in which order the regions of
            %                    interest will have their features
            %                    extracted. This also allows for ROIs
            %                    within the ImageVolume to be excluded from
            %                    having features extracted. **NOTE** This
            %                    vector also determines with
            %                    Group/Sub-Group IDs are linked up with
            %                    each sample. E.g if 'ExtractionOrder' =
            %                    [4,3,1] and 'GroupIds' = [6,7,8], then ROI
            %                    #4 in the ImageVolume object will be
            %                    assigned Group ID 6, ROI #3 will be ID 7,
            %                    and ROI #1 will be ID 8. ROI #2 will not
            %                    be processed.
            %                    If this value is not specified, the
            %                    default behaviour will be to extract
            %                    features for all ROIs within the
            %                    ImageVolume, in order.
            % 'ImageInterpretation': (Optional) Values: '2D' or '3D'
            %                        This allows for image volume with a
            %                        third (slice) dimension of 1 to be
            %                        interpreted as a 2D image (e.g. with a
            %                        thickness of 0). This effects which
            %                        features can be extracted for the
            %                        image volume. **NOTE** Image volumes
            %                        with a third dimensions >1 CAN ONLY be
            %                        interpreted as a 3D image. If the third 
            %                        dimension is 1, the image can be interpretted
            %                        as either 2D or 3D. If no value is
            %                        given the default is to interpret all
            %                        images as 3D.
            % 'SetRepresentativeFieldsOfView': (Optional) Values:
            %
            %                
            %
            % DESCRIPTION:
            %  Constructor for NewClass
            %
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                oImageVolume (1,1) ImageVolume {MustHaveRegionsOfInterest(oImageVolume)}
                sImageSource (1,1) string {mustBeNonempty}
                oSampleLabels (:,1) SampleLabels
                NameValueArgs.SampleOrder (:,1) double {mustBeInteger, ValidationUtils.MustContainUniqueValues} = []
                NameValueArgs.ImageInterpretation (1,:) char {mustBeMember(NameValueArgs.ImageInterpretation, {'2D','3D'})} = '3D'
                NameValueArgs.SetRepresentativeFieldsOfView (1,1) logical = true
            end
            
       
            c1xNameValueArgs = namedargs2cell(NameValueArgs);
            obj@ImageVolumeWithSampleIdsForFeatureExtraction(oImageVolume, sImageSource, oSampleLabels.GetSampleIds(), c1xNameValueArgs{:});
            
            c1xNameValueArgs = {'SampleOrder',NameValueArgs.SampleOrder,'SetRepresentativeFieldsOfView',NameValueArgs.SetRepresentativeFieldsOfView};
            obj@LabelledImageVolumeWithSampleIds(oImageVolume, sImageSource, oSampleLabels, c1xNameValueArgs{:})
            
        end 
        
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
       
    
    methods (Access = protected)
                
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@ImageVolumeWithSampleIdsForFeatureExtraction(obj);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private) % None
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