classdef ParametricRegionsOfInterest < RegionsOfInterest
    %RegionsOfInterest
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public, Abstract = false)
    end    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
           
    methods (Access = public)
        
        function obj = ParametricRegionsOfInterest(oOnDiskImageVolumeGeometry, dNumberOfRegionsOfInterest)
            %obj = ParametricRegionsOfInterest(oOnDiskImageVolumeGeometry, dNumberOfRegionsOfInterest)
            %
            % SYNTAX:
            %  obj = ParametricRegionsOfInterest(oOnDiskImageVolumeGeometry, dNumberOfRegionsOfInterest)
            %
            % DESCRIPTION:
            %  Constructor for NewClass
            %
            % INPUT ARGUMENTS:
            %  input1: What input1 is
            %  input2: What input2 is. If input2's description is very, very
            %         long wrap it with tabs to align the second line, and
            %         then the third line will automatically be in line
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Super-class constructor
            obj@RegionsOfInterest(oOnDiskImageVolumeGeometry, dNumberOfRegionsOfInterest);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
    end
    
    
    methods (Access = private, Static = true) % None
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

