classdef LabelledFeatureValuesRecordForModel < LabelledMachineLearningDataSetRecordForModel & FeatureValuesRecordForModel
    %
    %
    % TODO
    
    % Primary Author: Carol Johnson 
    % Created: August 31, 2022
    % Note:  modelled after LabelledImageCollectionRecordForModel
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
                       
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = LabelledFeatureValuesRecordForModel(oLabelledFeatureValues)
            %obj = LabelledFeatureValuesRecordForModel(oLabelledFeatureValues)
            %
            % SYNTAX:
            %  obj = LabelledFeatureValuesRecordForModel(oLabelledFeatureValues)
            %
            % DESCRIPTION:
            %  Constructor for LabelledFeatureValuesRecordForModel
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
                        
            arguments
                oLabelledFeatureValues (:,1) LabelledFeatureValues {MustBeValidForBinaryClassification(oLabelledFeatureValues)}
            end
            
            % super-class constructor
            obj@FeatureValuesRecordForModel(oLabelledFeatureValues);
            obj@LabelledMachineLearningDataSetRecordForModel(oLabelledFeatureValues);
            
            % set properities
            % none
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
    end
    
    
    methods (Access = protected, Static = true)      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Abstract)
    end
    
    
    methods (Access = private, Static = false)       
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

