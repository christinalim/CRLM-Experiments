classdef MultiClassClassificationSampleLabels < SampleLabels
    %MultiClassClassificationSampleLabels
    %
    % TODO
    
    % Primary Author: Carol Johnson (David DeVries)
    % Created: Sept 20, 2022
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
        
    
    properties ( SetAccess = immutable, GetAccess = public )
        viLabels (:,1) {ValidationUtils.MustBeIntegerClass} = int8([])
        viClasses (1,:) {ValidationUtils.MustBeIntegerClass, ValidationUtils.MustBeIncreasing, ValidationUtils.MustContainUniqueValues} = int8([])
        vsClassDescriptions (1,:) string 
    end
    
    properties (Access = public)
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
function obj = MultiClassClassificationSampleLabels(oSampleIds, viLabels, viClasses, vsClassDescriptions, sLabelSource)
            %obj = MultiClassClassificationSampleLabels(oSampleIds, viLabels, viClasses, vsClassDescriptions, sLabelSource)
            %
            % SYNTAX:
            %  obj = MultiClassClassificationSampleLabels(oSampleIds, viLabels, viClasses, vsClassDescriptions, sLabelSource)
            %
            % DESCRIPTION:
            %  Constructor for MultiClassClassificationSampleLabels
            %
            % INPUT ARGUMENTS:
            %  oSampleIds: a valid SampleIds object
            %  viLabels: a vector of integer labels, one for each row
            %  viClasses: a vector of integers representing the different
            %       class labels
            %  vsClassDescriptions: a vector of strings describing the
            %       different class labels (optional)
            %  sLabelSource: a string describing the source of the labels
            %       (optional)
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                oSampleIds (:,1) SampleIds
                viLabels (:,1) {mustBeInteger}
                viClasses (1,:) {mustBeInteger, ValidationUtils.MustBeSameClass(viClasses, viLabels)}
                vsClassDescriptions (1,:) string = string.empty
                sLabelSource (1,1) string = ""
            end
            
            [viClasses, vdSortedIndices] = sort(viClasses, 'ascend');
            
            MultiClassClassificationSampleLabels.MustBeValidClasses(viClasses);
            MultiClassClassificationSampleLabels.MustBeValidLabels(viLabels, viClasses);
            
            if isempty(vsClassDescriptions)
                vsClassDescriptions = string(viClasses);
            end
            
            ValidationUtils.MustBeSameSize(vsClassDescriptions, viClasses);
            vsClassDescriptions = vsClassDescriptions(vdSortedIndices);
            
            % super-class constructor
            obj@SampleLabels(oSampleIds, viLabels, sLabelSource)
            
            % set properities
            if ~isinteger(viLabels)
                [viLabels, viClasses] = MultiClassClassificationSampleLabels.CastNonIntegerToSmallestIntegerClass(viLabels, viClasses);
            end

            obj.viLabels = viLabels;
            obj.viClasses = viClasses;
            obj.vsClassDescriptions = vsClassDescriptions;
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function viLabels = GetLabels(obj)
            %viLabels = GetLabels(obj)
            %
            % SYNTAX:
            %  viLabels = GetLabels(obj)
            %
            % DESCRIPTION:
            %  Provides the sample labels (all classes)
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viLabels: Column vector of integers (one for each row)
            
            viLabels = obj.viLabels;
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
            %  viClasses: Row vector of integers (one for each class)
            
            viClasses = obj.viClasses;
        end
        
         function vsClassDescriptions = GetClassDescriptions(obj)
            %viClassDescriptions = GetClassDescriptions(obj)
            %
            % SYNTAX:
            %  viClassDescriptions = GetClassDescriptions(obj)
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
            %  obj: MultiClassClassificationSampleLabels object
            %
            % OUTPUTS ARGUMENTS:
            %  oRecord: a MultiClassClassificationSampleLabelsRecordForModel 
            %       object
            
            oRecord = MultiClassClassificationSampleLabelsRecordForModel(obj);
        end
       
        % >>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function obj = vertcat(varargin)
            %newObj = vertcat(varargin)
            %
            % SYNTAX:
            %  newObj = [oMultiClassClassificationSampleLabels1; oMultiClassClassificationSampleLabels2; ...]
            %  newObj = vertcat(oMultiClassClassificationSampleLabels1, oMultiClassClassificationSampleLabels2, ...)
            %
            % DESCRIPTION:
            %  Overloading vertcat allows for MultiClassClassificationSampleLabels objects
            %  to join their sample id and label values vertically (e.g. add multiple
            %  samples together). This requires each object to have unique
            %  samples in their rows (specified by the Group/Sub-Group ID pairs).
            %
            % INPUT ARGUMENTS:
            %  oMultiClassClassificationSampleLabels: 
            %       MultiClassClassificationSampleLabels object 
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Class object that contains the concatenated values
            
            c1oSampleLabels = varargin;
            
            dNumSampleLabels = length(c1oSampleLabels);
            vdNumSamplesPerSampleLabelsObj = zeros(1,dNumSampleLabels);
            
            c1oSampleIds = cell(dNumSampleLabels,1);
            
            for dObjIndex = 1:dNumSampleLabels
                oSampleLabelsObj = c1oSampleLabels{dObjIndex};
                
                % validate
                ValidationUtils.MustBeA(oSampleLabelsObj, 'MultiClassClassificationSampleLabels');
                
                % get number of samples
                vdNumSamplesPerSampleLabelsObj(dObjIndex) = oSampleLabelsObj.GetNumberOfSamples();
                
                % get sample IDs
                c1oSampleIds{dObjIndex} = oSampleLabelsObj.GetSampleIds();
            end
            
            dTotalNumSamples = sum(vdNumSamplesPerSampleLabelsObj);
            
            oMasterSampleLabels = oSampleLabelsObj;
            chMasterLabelsClass = class(oMasterSampleLabels.GetLabels());
            
            viLabels = zeros(dTotalNumSamples,1,chMasterLabelsClass);
            dInsertIndex = 1;
            
            for dObjIndex = 1:dNumSampleLabels
                oSampleLabelsObj = c1oSampleLabels{dObjIndex};
                
                % validate
                MultiClassClassificationSampleLabels.MustBeValidForVertcat(oMasterSampleLabels, oSampleLabelsObj);
                
                % insert labels
                dNumToInsert = vdNumSamplesPerSampleLabelsObj(dObjIndex);
                
                viLabels(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleLabelsObj.GetLabels();
                
                dInsertIndex = dInsertIndex + dNumToInsert;
            end
            
            % create new obj
            obj = MultiClassClassificationSampleLabels(vertcat(c1oSampleIds{:}), viLabels, oMasterSampleLabels.viClasses, oMasterSampleLabels.vsClassDescriptions);
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
                    viLabels = obj.viLabels(varargout{1}.GetRowSelection());
                    oSampleIds = obj.oSampleIds(varargout{1}.GetRowSelection());
                    
                    varargout{1} = MultiClassClassificationSampleLabels(oSampleIds, viLabels, obj.viClasses, obj.vsClassDescriptions);
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>> PRINT <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
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
    
    methods (Access = private, Static = true)
        
        function MustBeValidClasses(viClasses)
            % Validation:
            % - no repeats
            % - not empty
            % - if length == 1 - error
            % - if length == 2 - warning suggesting to use Binary
            
            if length(unique(viClasses)) < size(viClasses,2)
                chLabelDefStr = MultiClassClassificationSampleLabels.GenerateLabelDefinitionString(viClasses);
                error(...
                    'MultiClassClassificationSampleLabels:MustBeValidClasses:RepeatedClasses',...
                    ['There cannot be repeated classes defined for MultiClass classification.(', chLabelDefStr, ')']);
            end
            
            if isempty(viClasses)
                error(...
                    'MultiClassClassificationSampleLabels:MustBeValidClasses:EmptyClasses',...
                    'There must be an array of valid classes for multi-class classification. The classes array given was empty.');
            end
            
            if length(viClasses) == 1
                error(...
                    'MultiClassClassificationSampleLabels:MustBeValidClasses:Invalid',...
                    'There must be more than one class defined for multi-class classification.');
            end 
            
            if length(viClasses) == 2
                warning(...
                    'MultiClassClassificationSampleLabels:MustBeValidClasses:TwoClasses',...
                    'There were only 2 classes defined. Consider using binary classification instead of multi-class Classification.');
            end
            
        end
        
        function MustBeValidLabels(viLabels, viClasses)
            % Validation:
            % - not empty
            % - every entry in unique(viLabels) must appear in viClasses
            
            if isempty(viLabels)
                error(...
                    'MultiClassClassificationSampleLabels:MustBeValidLabels:EmptyLabels',...
                    'There must be an array of valid labels for MultiClass classification. The labels array given was empty.');
            end
            
            if any(~ismember(viLabels, viClasses))
                error(...
                    'MultiClassClassificationSampleLabels:MustBeValidLabels:Invalid',...
                    ['The given label values must match one of the valid class labels: (', num2str(viClasses), ') .']);
            end
        end

        function MustBeValidForVertcat(obj1, obj2)
            if...
                    ~strcmp(class(obj1.viLabels), class(obj2.viLabels)) ||...
                    ~strcmp(class(obj1.viClasses), class(obj2.viClasses)) ||...
                    any(obj1.viClasses ~= obj2.viClasses)
                error(...
                    'MultiClassClassificationSampleLabels:MustBeValidForVertcat:Invalid',...
                    'For two MultiClassClassificationSampleLabels objects to be concatenated, their labels and classes must be of the same class type and the defined class definitions must be identical.');
            end
        end
        
        function [viLabels, viClasses] = CastNonIntegerToSmallestIntegerClass(vxLabels, vxClasses)
            dMaxValue = max(abs(vxClasses));
            
            if any(vxClasses < 0) % is negative
                if dMaxValue <= int8(inf)
                    viLabels = int8(vxLabels);
                    viClasses = int8(vxClasses);
                elseif dMaxValue <= int16(inf)
                    viLabels = int16(vxLabels);
                    viClasses = int16(vxClasses);
                elseif dMaxValue <= int32(inf)
                    viLabels = int32(vxLabels);
                    viClasses = int32(vxClasses);
                else
                    viLabels = int64(vxLabels);
                    viClasses = int64(vxClasses);
                end
            else
                if dMaxValue <= uint8(inf)
                    viLabels = uint8(vxLabels);
                    viClasses = uint8(vxClasses);
                elseif dMaxValue <= uint16(inf)
                    viLabels = uint16(vxLabels);
                    viClasses = uint16(vxClasses);
                elseif dMaxValue <= uint32(inf)
                    viLabels = uint32(vxLabels);
                    viClasses = uint32(vxClasses);
                else
                    viLabels = uint64(vxLabels);
                    viClasses = uint64(vxClasses);
                end
            end
        end

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
    
    
    methods (Access = {?MultiClassClassificationSampleLabelsRecordForModel}, Static = true)      
        
        function chLabelDefStr = GenerateLabelDefinitionString(viClasses)
            %chLabelDefStr = GenerateLabelDefinitionString(viClasses)
            %
            % SYNTAX:
            %  chLabelDefStr = GenerateLabelDefinitionString(viClasses)
            %
            % DESCRIPTION:
            %  Function to generate a character array containing the class
            %  labels separated by '/'
            %
            % INPUT ARGUMENTS:
            %  viClasses: vector of integer class numbers
            %
            % OUTPUTS ARGUMENTS:
            %  chLabelDefStr: character array of class labels
            
            sLabelDefStr = "";
            
            for dInd = 1: length(viClasses)
                sLabelDefStr = sLabelDefStr + num2str(viClasses(dInd));
               
                if dInd < length(viClasses)
                    sLabelDefStr = sLabelDefStr + "/";
                end
            end
            
            chLabelDefStr = convertStringsToChars(sLabelDefStr);
        end
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

