classdef ParametricRegionsOfInterestFieldsOfView < RegionsOfInterestFieldsOfView
    %ParametricRegionsOfInterestFieldsOfView
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Oct 13, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        oRASImageVolume
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)
        vdRegionOfInterestNumbers
    end
    
    
    properties (Constant = true, GetAccess = public)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
                
        function obj = ParametricRegionsOfInterestFieldsOfView(oRASImageVolume, vdRegionOfInterestNumbers)
            arguments
                oRASImageVolume (1,1) ImageVolume {MustHaveRegionsOfInterestOfClass(oRASImageVolume, 'ParametricRegionsOfInterest'),  MustBeRAS(oRASImageVolume)}
                vdRegionOfInterestNumbers (1,:) double {MustBeValidRegionOfInterestNumbers(oRASImageVolume, vdRegionOfInterestNumbers)}                
            end
            
            % super-class call
            dNumRois = length(vdRegionOfInterestNumbers);
            obj@RegionsOfInterestFieldsOfView(dNumRois);
            
            % set properities
            obj.vdRegionOfInterestNumbers = vdRegionOfInterestNumbers;
            obj.oRASImageVolume = oRASImageVolume;
        end
        
        function RenderFieldOfViewOnAxesByExtractionIndex(obj, oImagingPlaneAxes, dExtractionIndex, NameValueArgs)
            arguments
                obj
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                dExtractionIndex (1,1) double {MustBeValidExtractionIndex(obj, dExtractionIndex)}
                NameValueArgs.ForceImagingPlaneType ImagingPlaneTypes {ValidationUtils.MustBeEmptyOrScalar}
                NameValueArgs.ShowAllRegionsOfInterest (1,1) logical = true
                NameValueArgs.LineWidth (1,1) double {mustBePositive} = 1
                NameValueArgs.RegionOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector}
                NameValueArgs.OtherRegionsOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector}
            end
            
            error('Under construction');
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
           
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