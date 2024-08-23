classdef MultiClassClassificationGuessResultSampleLabels < GuessResultSampleLabels
    %MultiClassClassificationGuessResultSampleLabels
    %
    % TODO
    
    % Primary Author: 
    % Created: 
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
          
    properties (SetAccess = immutable, GetAccess = public)
        m2dLabelConfidencesPerSamplePerClass (:,:) double {mustBeNonnegative(m2dLabelConfidencesPerSamplePerClass)} % >= 0 but not necessarily <= 1
        viClasses (1,:) {ValidationUtils.MustBeIntegerClass, ValidationUtils.MustBeIncreasing, ValidationUtils.MustContainUniqueValues} = int8([])
        vsClassDescriptions (1,:) string 
        
    end
                
    properties (Access = private, Constant = true)
        dNotNormalizedThreshold = 0.001 % if |1-(a+b+c+...)| < 0.001, row of confidences are normalized 
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = MultiClassClassificationGuessResultSampleLabels(m2dLabelConfidencesPerSamplePerClass, viClasses, vsClassDescriptions)
            %obj = MultiClassClassificationGuessResultSampleLabels(m2dLabelConfidencesPerSamplePerClass, viClasses, vsClassDescriptions)
            %
            % SYNTAX:
            %  obj = MultiClassClassificationGuessResultSampleLabels(m2dLabelConfidencesPerSamplePerClass, viClasses, vsClassDescriptions)
            %
            % DESCRIPTION:
            %  Constructor for MultiClassClassificationGuessResultSampleLabels
            %
            % INPUT ARGUMENTS:
            %  m2dLabelConfidencesPerSamplePerClass: a 2 dimensional matrix
            %       of confidences for each sample (row) for each class
            %       (column)
            %  viClasses: a vector of integers representing the different
            %       class labels
            %  vsClassDescriptions: a vector of strings describing the
            %       different class labels (optional)
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            
            arguments
               m2dLabelConfidencesPerSamplePerClass (:,:) double {mustBeNonnegative(m2dLabelConfidencesPerSamplePerClass)}
               viClasses (1,:) {ValidationUtils.MustBeIntegerClass}
               vsClassDescriptions (1,:) string = string.empty
            end
            
            [viClasses, vdSortedIndices] = sort(viClasses, 'ascend');
            
            if isempty(vsClassDescriptions)
                vsClassDescriptions = string(viClasses);
            end
            
            ValidationUtils.MustBeSameSize(vsClassDescriptions, viClasses);
            vsClassDescriptions = vsClassDescriptions(vdSortedIndices);
            m2dLabelConfidencesPerSamplePerClass = m2dLabelConfidencesPerSamplePerClass(:,vdSortedIndices);
            
            % super-class constructor
            obj@GuessResultSampleLabels(m2dLabelConfidencesPerSamplePerClass)
            
            % check normalization
            if any(m2dLabelConfidencesPerSamplePerClass(:) > 1)% test that nothing > 1
                warning(...
                    'MultiClassClassificationGuessResultSampleLabels:Constructor:LabelConfidencesGreaterThan1',...
                    'One or more of the label confidences are greater than 1.');
            elseif any(abs(sum(m2dLabelConfidencesPerSamplePerClass,2) - 1) > MultiClassClassificationGuessResultSampleLabels.dNotNormalizedThreshold)
                warning(...
                    'MultiClassClassificationGuessResultSampleLabels:Constructor:LabelConfidencesNotNormalized',...
                    'One or more of the label confidences are not normalized (do not sum to 1)');
            end
            
            % set properities
            obj.m2dLabelConfidencesPerSamplePerClass = m2dLabelConfidencesPerSamplePerClass;
            obj.viClasses = viClasses;
            obj.vsClassDescriptions = vsClassDescriptions;
        end      
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function m2dLabelConfidencesPerSamplePerClass = GetLabelConfidencesPerSamplePerClass(obj)
            %m2dLabelConfidencesPerSamplePerClass = GetLabelConfidencesPerSamplePerClass(obj)
            %
            % SYNTAX:
            %  m2dLabelConfidencesPerSamplePerClass = GetLabelConfidencesPerSamplePerClass(obj)
            %
            % DESCRIPTION:
            %  Provides the matrix containing the confidence results per
            %  sample for each class
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  m2dLabelConfidencesPerSamplePerClass: matrix of doubles
            %       holding the confidence for each sample (rows) for each 
            %       class (columns)
        
            m2dLabelConfidencesPerSamplePerClass = obj.m2dLabelConfidencesPerSamplePerClass;
        end
        
        function viClasses = GetClasses(obj)
            %viClasses = GetClasses(obj)
            %
            % SYNTAX:
            %  viClasses = GetClasses(obj)
            %
            % DESCRIPTION:
            %  Provides the label classes
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viClasses: Column vector of integers (one for each class)
            
            viClasses = obj.viClasses;
        end
        
        function vsClassDescriptions = GetClassDescriptions(obj)
            %vsClassDescriptions = GetClassDescriptions(obj)
            %
            % SYNTAX:
            %  vsClassDescriptions = GetClassDescriptions(obj)
            %
            % DESCRIPTION:
            %  Provides the descriptor for the label classes
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viClassDescriptions: Row vector of strings (one for each class)
            
            vsClassDescriptions = obj.vsClassDescriptions;
        end
        
        function vdLabelConfidencesPerSample = GetLabelConfidencesForClassPerSample(obj, iClass)
            %vdLabelConfidencesPerSample = GetLabelConfidencesForClassPerSample(obj, iClass)
            %
            % SYNTAX:
            %  vdLabelConfidencesPerSample = GetLabelConfidencesForClassPerSample(obj, iClass)
            %
            % DESCRIPTION:
            %  Provides the vector of confidence results per sample for
            %   a requested class
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  iClass: the integer class number for the stored confidences
            %       to retrieve
            %
            % OUTPUTS ARGUMENTS:
            %  vdLabelConfidencesPerSample: column vector of doubles
            %       holding the confidence for each sample (rows) for the
            %       requested class
            
            vbClassColumn = find(obj.viClasses==iClass);
            vdLabelConfidencesPerSample = obj.m2dLabelConfidencesPerSamplePerClass(:,vbClassColumn);
        end
        
        function m2dNormalizedLabelConfidencesPerSamplePerClass = GetNormalizedLabelConfidencesPerSamplePerClass(obj)
            %m2dNormalizedLabelConfidencesPerSamplePerClass = GetNormalizedLabelConfidencesPerSamplePerClass(obj)
            %
            % SYNTAX:
            %  m2dNormalizedLabelConfidencesPerSamplePerClass = GetNormalizedLabelConfidencesPerSamplePerClass(obj)
            %
            % DESCRIPTION:
            %  Provides the matrix containing the normalized confidence
            %       results per sample for each class
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  m2dNormalizedLabelConfidencesPerSamplePerClass: matrix of doubles
            %       holding the confidence for each sample (rows) for each 
            %       class (columns)
        
            m2dNormalizedLabelConfidencesPerSamplePerClass = ...
                obj.m2dLabelConfidencesPerSamplePerClass ./ (sum(obj.m2dLabelConfidencesPerSamplePerClass, 2));
        end
        
        function vdNormalizedLabelConfidencesPerSample = GetNormalizedLabelConfidencesForClassPerSample(obj, iClass)
            %vdNormalizedLabelConfidencesPerSample = GetNormalizedLabelConfidencesPerSample(obj, iClass)
            %
            % SYNTAX:
            %  vdNormalizedLabelConfidencesPerSample = GetNormalizedLabelConfidencesPerSample(obj, iClass)
            %
            % DESCRIPTION:
            %  Provides the vector of doubles of the normalized confidence 
            %   results per sample for a requested class
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  iClass: the integer class number for the normalized stored 
            %       confidences to retrieve
            %
            % OUTPUTS ARGUMENTS:
            %  vdNormalizedLabelConfidencesPerSample: column vector of doubles
            %       holding the normalized confidence for each sample (rows)
            %       for the requested class
           
            vdNormalizedLabelConfidencesPerSample =...
                obj.GetLabelConfidencesForClassPerSample(iClass) ./ (sum(obj.m2dLabelConfidencesPerSamplePerClass, 2));
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        function obj = vertcat(varargin)
            %newObj = vertcat(varargin)
            %
            % SYNTAX:
            %  newObj = [oMultiClassClassificationGuessResultSampleLabels1; oMultiClassClassificationGuessResultSampleLabels2; ...]
            %  newObj = vertcat(oMultiClassClassificationGuessResultSampleLabels1, oMultiClassClassificationGuessResultSampleLabels2, ...)
            %
            % DESCRIPTION:
            %  Overloading vertcat allows for MultiClassClassificationGuessResultSampleLabels objects
            %  to join their label confidences (per sample per class) values vertically (e.g. add multiple
            %  samples together).
            %
            % INPUT ARGUMENTS:
            %  oMultiClassClassificationGuessResultSampleLabels: 
            %       MultiClassClassificationGuessResultSampleLabels object 
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Class object that contains the concatenated values
            
            c1oSampleLabels = varargin;
            
            dNumSampleLabels = length(c1oSampleLabels);
            vdNumSamplesPerSampleLabelsObj = zeros(1,dNumSampleLabels);
            
            for dObjIndex = 1:dNumSampleLabels
                oSampleLabelsObj = c1oSampleLabels{dObjIndex};
                
                % validate
                ValidationUtils.MustBeA(oSampleLabelsObj, 'MultiClassClassificationGuessResultSampleLabels');
                
                % get number of samples
                vdNumSamplesPerSampleLabelsObj(dObjIndex) = oSampleLabelsObj.GetNumberOfSamples();
            end
            
            dTotalNumSamples = sum(vdNumSamplesPerSampleLabelsObj);
            dTotalNumClasses = numel(oSampleLabelsObj.viClasses);
            
            oMasterSampleLabels = oSampleLabelsObj;
            
            m2dLabelConfidencesPerSamplePerClass = zeros(dTotalNumSamples, dTotalNumClasses);
            dInsertIndex = 1;
            
            for dObjIndex = 1:dNumSampleLabels
                oSampleLabelsObj = c1oSampleLabels{dObjIndex};
                
                % validate
                MultiClassClassificationGuessResultSampleLabels.MustBeValidForVertcat(oMasterSampleLabels, oSampleLabelsObj);
                
                % insert labels
                dNumToInsert = vdNumSamplesPerSampleLabelsObj(dObjIndex);
                
                m2dLabelConfidencesPerSamplePerClass(dInsertIndex : dInsertIndex + dNumToInsert - 1 , :) = oSampleLabelsObj.GetLabelConfidencesPerSamplePerClass();
                
                dInsertIndex = dInsertIndex + dNumToInsert;
            end
            
            % create new obj
            obj = MultiClassClassificationGuessResultSampleLabels(m2dLabelConfidencesPerSamplePerClass, oMasterSampleLabels.viClasses);
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
            %  varargout: If is was a selection, a MultiClassClassificationSampleLabels object
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
                    m2dLabelConfidencesPerSamplePerClass = obj.m2dLabelConfidencesPerSamplePerClass((varargout{1}.GetRowSelection()), :);
              
                    varargout{1} = MultiClassClassificationGuessResultSampleLabels(m2dLabelConfidencesPerSamplePerClass, obj.viClasses, obj.vsClassDescriptions)
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
            end
        end
        
        function MustBeValidSampleLabelsForGuessResult(oGuessResultSampleLabels, oGroundTruthSampleLabels)
            %MustBeValidSampleLabelsForGuessResult(oGuessResultSampleLabels, oGroundTruthSampleLabels)
            %
            % SYNTAX:
            %  MustBeValidSampleLabelsForGuessResult(oGuessResultSampleLabels, oGroundTruthSampleLabels)
            %
            % DESCRIPTION:
            %  This is a validator function for multi-class classification
            %  to ensure that the number of equality in each object 
            %  for number of samples, class labels, and class description definitions
            %
            % INPUT ARGUMENTS:
            %  oGuessResultSampleLabels: MultiClassClassificationGuessResultSampleLabels object
            %           holds the confidences and class definitions for the
            %           samples
            %  oGroundTruthSampleLabels: MultiClassClassificationSampleLabels object
            %           holds the labels defined in the testing dataset
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            
            arguments
               oGuessResultSampleLabels (:,1) MultiClassClassificationGuessResultSampleLabels
               oGroundTruthSampleLabels (:,1) MultiClassClassificationSampleLabels
            end
            
            % must have same number of samples
            if (oGuessResultSampleLabels.GetNumberOfSamples() ~= oGroundTruthSampleLabels.GetNumberOfSamples())
                error(...
                    'MultiClassClassificationGuessResultSampleLabels:MustHaveSameNumberOfLabels:Invalid',...
                    'Both the GroundTruthSampleLabels and GuessResultSampleLabels must have the same number of samples.');
            end
            
            % must have same class labels
            if any(oGuessResultSampleLabels.GetClasses() ~= oGroundTruthSampleLabels.GetClasses())
                error(...
                    'MultiClassClassificationGuessResultSampleLabels:MustHaveSameClasses:Invalid',...
                    'Both the GroundTruthSampleLabels and GuessResultSampleLabels must have the same class labels.');
            end
            % must have same class descriptions
            if any(oGuessResultSampleLabels.GetClassDescriptions() ~= oGroundTruthSampleLabels.GetClassDescriptions())
                error(...
                    'MultiClassClassificationGuessResultSampleLabels:MustHaveSameClassDescriptions:Invalid',...
                    'Both the GroundTruthSampleLabels and GuessResultSampleLabels must have the same class descriptions.');
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>> PRINT <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        function PrintHeaders(obj)
            %PrintHeaders(obj)
            %
            % SYNTAX:
            %  PrintHeaders(obj)
            %
            % DESCRIPTION:
            %  Function to define and print header column for the classes
            %  in the multi-class classification GuessResult object
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            

            viClasses = obj.GetClasses();
            c1sClasses = arrayfun(@num2str,viClasses,'UniformOutput',false);
            dMaxClassLength = max(cellfun(@strlength, c1sClasses));
            if dMaxClassLength < 3
                dMaxClassLength = 3;
            end
            
            f = ([' Class: %', num2str(dMaxClassLength), 's |']);
            sPrintFormat = repmat(f,1,length(viClasses));

            c1sClasses = arrayfun(@num2str,viClasses,'UniformOutput',false);
            
            fprintf(sPrintFormat,c1sClasses{:});
        end
        
        function PrintRowForSample(obj, dSampleIndex)
            %PrintRowForSample(obj, dSampleIndex)
            %
            % SYNTAX:
            %  PrintRowForSample(obj, dSampleIndex)
            %
            % DESCRIPTION:
            %  Function to coordinate printing each sample row defined by
            %  the index given. The row consists of the value of the
            %  confidences for each class in the multi-class classification
            %  GuessResult object.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  dSampleIndex: an integer of type double that represents the
            %    row to be printed.
            %
            % OUTPUTS ARGUMENTS:
            %  None
            

            viClasses = obj.GetClasses();
            c1sClasses = arrayfun(@num2str,viClasses,'UniformOutput',false);

            % adjust column width based on the length of the longest class
            dMaxClassLength = max(cellfun(@strlength, c1sClasses));
            if dMaxClassLength < 3
                dMaxClassLength = 3;
            end
            dColWidth = 7 + dMaxClassLength; % 7 for header formatting
            
            f = ([' %', num2str(dColWidth), '.5f |']);
            sPrintFormat = repmat(f,1,obj.GetNumberOfClasses());
            
            fprintf(sPrintFormat, obj.m2dLabelConfidencesPerSamplePerClass(dSampleIndex, :));
        end
        
        function PrintClassesFooter(obj)
            %PrintClassesFooter(obj)
            %
            % SYNTAX:
            %  PrintClassesFooter(obj)
            %
            % DESCRIPTION:
            %  Formats and prints the footer listing the class labels 
            %  and their description.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            
            viClasses = obj.GetClasses();
            vsClassDescriptions = obj.GetClassDescriptions();
            c1sClasses = arrayfun(@num2str,viClasses,'UniformOutput',false);
            dMaxClassLength = max(cellfun(@strlength, c1sClasses));
            dMaxClassDescLength = max(cellfun(@strlength, vsClassDescriptions));
            chRowFormat = ['%',num2str(dMaxClassLength), 's: %-',num2str(dMaxClassDescLength),'s'];

            for dInd = 1: length(viClasses)
                fprintf(chRowFormat,num2str(viClasses(dInd)),num2str(vsClassDescriptions(dInd)))
                fprintf(newline);
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
                

        % >>>>>>>>>>>>>>>>>>>>> VALIDATORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustBeValidForVertcat(obj1, obj2)
            if...
                    any(obj1.viClasses ~= obj2.viClasses) || any(obj1.vsClassDescriptions ~= obj2.vsClassDescriptions)
                error(...
                    'MultiClassClassificationGuessResultSampleLabels:MustBeValidForVertcat:Invalid',...
                    'For two MultiClassClassificationGuessResultSampleLabels objects to be concatenated, the label class definitions and descriptions must be identical.');
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

