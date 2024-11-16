classdef MultiClassClassificationSampleLabelsRecordForModel < SampleLabelsRecordForModel
    %
    %
    % TODO
    
    % Primary Author: Carol Johnson (David DeVries)
    % Created: Sept 21, 2022
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
                       
    properties (SetAccess = immutable, GetAccess = public)
        viClasses (1,:) {ValidationUtils.MustBeIntegerClass, ValidationUtils.MustBeIncreasing, ValidationUtils.MustContainUniqueValues} = int8([])
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = MultiClassClassificationSampleLabelsRecordForModel(oMultiClassClassificationSampleLabels)
            %obj = MultiClassClassificationSampleLabelsRecordForModel(oMultiClassClassificationSampleLabels)
            %
            % SYNTAX:
            %  obj = MultiClassClassificationSampleLabelsRecordForModel(oMultiClassClassificationSampleLabels)
            %
            % DESCRIPTION:
            %  Constructor for MultiClassClassificationSampleLabelsRecordForModel
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
                        
            arguments
                oMultiClassClassificationSampleLabels (:,1) MultiClassClassificationSampleLabels
            end
            
            % super-class constructor
            obj@SampleLabelsRecordForModel(oMultiClassClassificationSampleLabels);
            
            % set properities
            obj.viClasses = oMultiClassClassificationSampleLabels.GetClasses();
        end   
        
        function MustBeValidSampleLabelsRecordForGuess(obj, oRecordFromModelTraining)
            %MustBeValidSampleLabelsRecordForGuess(obj, oRecordFromModelTraining)
            %
            % SYNTAX:
            %  MustBeValidSampleLabelsRecordForGuess(obj, oRecordFromModelTraining)
            %
            % DESCRIPTION:
            %  Validates that obj, the sample labels record from the data set
            %  being used for Guess, is valid to use with a model that used
            %  the sample labels represented by oRecordFromModelTraining during
            %  training
            %
            % INPUT ARGUMENTS:
            %  obj: 
            %   SampleLabelsRecordForModel from the labelled data set
            %   which is being used for MachineLearningModel.Guess()
            %  oRecordFromModelTraining:
            %   SampleLabelsRecordForModel from a data set used
            %   during the training/HPO of the model on which .Guess() is
            %   being performed
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                obj (1,1) MultiClassClassificationSampleLabelsRecordForModel
                oRecordFromModelTraining (1,1) SampleLabelsRecordForModel
            end
            
            % super-class calls
            MustBeValidSampleLabelsRecordForGuess@SampleLabelsRecordForModel(obj, oRecordFromModelTraining);
            
            % local checks
            if ~isequal(obj.viClasses, oRecordFromModelTraining.viClasses)
                chLabelDefStr_obj = MultiClassClassificationSampleLabels.GenerateLabelDefinitionString(obj.viClasses);
                chLabelDefStr_record = MultiClassClassificationSampleLabels.GenerateLabelDefinitionString(oRecordFromModelTraining.viClasses);
                error(...
                    'MultiClassClassificationSampleLabelsRecordForModel:MustBeValidDataSetRecordForGuess:ClassDefinitionMismatch',...
                    ['The model was trained using a data set with sample labels definition of "', chLabelDefStr_obj, '" where .Guess() is being called with a data set with sample labels definition of "', chLabelDefStr_record, '". The sample labels used for .Train() and .Guess() must have the same class label definitions.']);
            end
        end 
        
        function MustBeValidSampleLabelsRecordForValidation(obj, oRecordFromModelTraining)
            %MustBeValidSampleLabelsRecordForValidation(obj, oRecordFromModelTraining)
            %
            % SYNTAX:
            %  MustBeValidSampleLabelsRecordForValidation(obj, oRecordFromModelTraining)
            %
            % DESCRIPTION:
            %  Validates that obj, the sample labels record from the data set
            %  being used for validation, is valid to use with a model that used
            %  the sample labels represented by oRecordFromModelTraining during
            %  training
            %
            % INPUT ARGUMENTS:
            %  obj: 
            %   SampleLabelsRecordForModel from the labelled data set
            %   which is being used for validation
            %  oRecordFromModelTraining:
            %   SampleLabelsRecordForModel from a data set used
            %   during the training/HPO of the model on which validation is
            %   being performed
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                obj (1,1) MultiClassClassificationSampleLabelsRecordForModel
                oRecordFromModelTraining (1,1) SampleLabelsRecordForModel
            end
            
            % super-class calls
            MustBeValidSampleLabelsRecordForValidation@SampleLabelsRecordForModel(obj, oRecordFromModelTraining);
            
            % local checks
            if any(obj.viClasses ~= oRecordFromModelTraining.viClasses)
                chLabelDefStr_obj = MultiClassClassificationSampleLabels.GenerateLabelDefinitionString(obj.viClasses);
                chLabelDefStr_record = MultiClassClassificationSampleLabels.GenerateLabelDefinitionString(oRecordFromModelTraining.viClasses);
                error(...
                    'MultiClassClassificationSampleLabelsRecordForModel:MustBeValidDataSetRecordForValidation:ClassDefinitionMismatch',...
                    ['The model was trained using a data set with sample labels definition of "', chLabelDefStr_obj, '" where validation is being called with a data set with sample labels definition of "', chLabelDefStr_record, '". The sample labels used for for training and validation must have the same class label definitions.']);
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

