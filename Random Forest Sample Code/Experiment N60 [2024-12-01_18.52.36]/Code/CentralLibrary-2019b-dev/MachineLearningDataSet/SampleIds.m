classdef SampleIds < MatrixContainer
    %SampleIds
    %
    % Provides Group and Sub-Group IDs for samples, along with a custom
    % string the user can set as they want.
    
    % Primary Author: David DeVries
    % Created: June 4, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        viGroupIds (:,1) {ValidationUtils.MustBeIntegerClass} = int8([]) % together Group and Sub-Group IDs form a unique key for a sample (may be duplicated though during balancing)
        viSubGroupIds (:,1) {ValidationUtils.MustBeIntegerClass} = int8([])    
        
        vsUserDefinedSampleStrings (:,1) string % custom string given for each sample by the user. Only for display/debugging purposes!
        
        vbIsDuplicatedSample (:,1) logical % flags whether sample was duplicated or not
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vbIsDuplicatedSample)
            %obj = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vbIsDuplicatedSample)
            %
            % SYNTAX:
            %  obj = SampleIds(viGroupIds, viSubGroupIds)
            %  obj = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings)
            %  obj = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vbIsDuplicatedSample)
            %
            % DESCRIPTION:
            %  Constructor for SampleIds
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                viGroupIds (:,1) {mustBeInteger}
                viSubGroupIds (:,1) {mustBeInteger, ValidationUtils.MustBeSameSize(viGroupIds, viSubGroupIds)}
                vsUserDefinedSampleStrings (:,1) string {ValidationUtils.MustBeSameSize(vsUserDefinedSampleStrings, viGroupIds)} = SampleIds.CreateDefaultUserDefinedSampleStrings(viGroupIds, viSubGroupIds)
                vbIsDuplicatedSample (:,1) logical {ValidationUtils.MustBeSameSize(vbIsDuplicatedSample, viGroupIds), SampleIds.GroupAndSubGroupIdsUniquenessMustMatchIsDuplicatedSample(viGroupIds, viSubGroupIds, vbIsDuplicatedSample)} = SampleIds.CreateDefaultIsDuplicatedSample(viGroupIds)
            end
            
            % super-class constructor
            obj@MatrixContainer(viGroupIds);
            
            % if group/sub-group IDs are int classes, cast them into the
            % smallest classes
            if ~isinteger(viGroupIds)
                viGroupIds = SampleIds.CastNonIntegerToSmallestIntegerClass(viGroupIds);
            end
            
            if ~isinteger(viSubGroupIds)
                viSubGroupIds = SampleIds.CastNonIntegerToSmallestIntegerClass(viSubGroupIds);
            end
            
            % set properities
            obj.viGroupIds = viGroupIds;
            obj.viSubGroupIds = viSubGroupIds;
            obj.vsUserDefinedSampleStrings = vsUserDefinedSampleStrings;
            obj.vbIsDuplicatedSample = vbIsDuplicatedSample;
        end   
        
        
        % >>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dNumSamples = GetNumberOfSamples(obj)
            %dNumSamples = GetNumberOfSamples(obj)
            %
            % SYNTAX:
            %  dNumSamples = obj.GetNumberOfSamples()
            %
            % DESCRIPTION:
            %  Returns the number of samples for which there are IDs for
            %  (e.g. the number of rows in each of the column vectors
            %  stored)
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            dNumSamples = length(obj); % used overloaded length function
        end
        
        function dNumGroups = GetNumberOfGroups(obj)
            %dNumGroups = GetNumberOfGroups(obj)
            %
            % SYNTAX:
            %  dNumGroups = objGetNumberOfGroups()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            dNumGroups = length(obj.GetUniqueGroupIds());
        end
        
        function viUniqueGroupIds = GetUniqueGroupIds(obj)
            %viUniqueGroupIds = GetUniqueGroupIds(obj)
            %
            % SYNTAX:
            %  viUniqueGroupIds = obj.GetUniqueGroupIds()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            viUniqueGroupIds = unique(obj.viGroupIds);
        end
        
        function viGroupIds = GetGroupIds(obj)
            %viGroupIds = GetGroupIds(obj)
            %
            % SYNTAX:
            %  viGroupIds = obj.GetGroupIds()
            %
            % DESCRIPTION:
            %  Getter for obj.viGroupIds
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            viGroupIds = obj.viGroupIds;
        end
        
        function viSubGroupIds = GetSubGroupIds(obj)
            %viSubGroupIds = GetSubGroupIds(obj)
            %
            % SYNTAX:
            %  viSubGroupIds = obj.GetSubGroupIds()
            %
            % DESCRIPTION:
            %  Getter for obj.viSubGroupIds
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            viSubGroupIds = obj.viSubGroupIds;
        end
        
        function vsUserDefinedSampleStrings = GetUserDefinedSampleStrings(obj)
            %vsUserDefinedSampleStrings = GetUserDefinedSampleStrings(obj)
            %
            % SYNTAX:
            %  vsUserDefinedSampleStrings = obj.GetUserDefinedSampleStrings()
            %
            % DESCRIPTION:
            %  Getter for obj.vsUserDefinedSampleStrings
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            vsUserDefinedSampleStrings = obj.vsUserDefinedSampleStrings;
        end
        
        function vbIsDuplicatedSample = IsDuplicatedSample(obj)
            %vbIsDuplicatedSample = IsDuplicatedSample(obj)
            %
            % SYNTAX:
            %  vbIsDuplicatedSample = obj.IsDuplicatedSample()
            %
            % DESCRIPTION:
            %  Getter for obj.vbIsDuplicatedSample
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            vbIsDuplicatedSample = obj.vbIsDuplicatedSample;
        end
        
        function bContainsDuplicatedSamples = ContainsDuplicatedSamples(obj)
            %bContainsDuplicatedSamples = ContainsDuplicatedSamples(obj)
            %
            % SYNTAX:
            %  bContainsDuplicatedSamples = ContainsDuplicatedSamples(obj)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            bContainsDuplicatedSamples = any(obj.vbIsDuplicatedSample);
        end
        
        function iGroupId = GetGroupIdForSample(obj, dSampleIndex)
            %iGroupId = GetGroupIdForSample(obj, dSampleIndex)
            %
            % SYNTAX:
            %  iGroupId = obj.GetGroupIdForSample(dSampleIndex)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            arguments
                obj
                dSampleIndex (1,1) double {MustBeValidSampleIndex(obj, dSampleIndex)}
            end            
            
            iGroupId = obj.viGroupIds(dSampleIndex);
        end
        
        function iSubGroupId = GetSubGroupIdForSample(obj, dSampleIndex)
            %iSubGroupId = GetSubGroupIdForSample(obj, dSampleIndex)
            %
            % SYNTAX:
            %  iSubGroupId = obj.GetSubGroupIdForSample(dSampleIndex)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            arguments
                obj
                dSampleIndex (1,1) double {MustBeValidSampleIndex(obj, dSampleIndex)}
            end            
            
            iSubGroupId = obj.viSubGroupIds(dSampleIndex);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> VALIDATORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustBeValidSampleIndex(obj, dSampleIndex)
            arguments
                obj
                dSampleIndex (1,1) double {mustBePositive, mustBeInteger}
            end
            
            mustBeLessThanOrEqual(dSampleIndex, length(obj))
        end
        
        function MustNotContainDuplicatedSamples(obj)
            if obj.ContainsDuplicatedSamples
                error(...
                    'SampleIds:MustNotContainDuplicatedSamples:Invalid',...
                    'SampleIds object must not contain duplicated samples.');
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
            %  Function to define and print header column for the for the
            %  sample ids.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            dNumSamples = obj.GetNumberOfSamples();
            dSampleNumWidth = length(num2str(dNumSamples));
            
            if obj.ContainsDuplicatedSamples()
                dSampleNumWidth = dSampleNumWidth + 1;
            end
            
            fprintf([' %', num2str(dSampleNumWidth), 's | %5s | %7s |'], '#', 'Group', 'Sub Grp');
        end
        
        function PrintRowForSample(obj, dSampleIndex)
            %PrintRowForSample(obj, dSampleIndex)
            %
            % SYNTAX:
            %  PrintRowForSample(obj, dSampleIndex)
            %
            % DESCRIPTION:
            %  Function to coordinate printing each sample row definded by
            %  the index given. The row consists of the index, Group ID,
            %  and SubGroup ID.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  dSampleIndex: an integer of type double that represents the
            %    row to be printed.
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            dNumSamples = obj.GetNumberOfSamples();
            dSampleNumWidth = length(num2str(dNumSamples));
            
            chFormatString = ['%', num2str(dSampleNumWidth), 'i | %5i | %7i |'];
            c1xPrintVargs = {dSampleIndex, obj.viGroupIds(dSampleIndex), obj.viSubGroupIds(dSampleIndex)};
            
            if obj.ContainsDuplicatedSamples()
                chFormatString = ['%1s', chFormatString];
                
                if obj.vbIsDuplicatedSample(dSampleIndex)
                    c1xPrintVargs = [{'*'}, c1xPrintVargs];
                else
                    c1xPrintVargs = [{''}, c1xPrintVargs];
                end
            end
            
            chFormatString = [' ', chFormatString];
                        
            fprintf(chFormatString, c1xPrintVargs{:});
        end
        
        function PrintFooter(obj)
            %PrintFooter(obj)
            %
            % SYNTAX:
            %  PrintFooter(obj)
            %
            % DESCRIPTION:
            %  Function to coordinate printing the footer which includes
            %  the legend for the duplicate samples indicator.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None

            if obj.ContainsDuplicatedSamples()
                fprintf('* - Duplicated Sample');
                fprintf(newline);
            end
        end
                
        
        % >>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function obj = vertcat(varargin)
            c1oSampleIds = varargin;
            
            dNumSampleIds = length(c1oSampleIds);
            vdNumSamplesPerSampleIdsObj = zeros(1,dNumSampleIds);
                        
            for dObjIndex = 1:dNumSampleIds
                oSampleIdsObj = c1oSampleIds{dObjIndex};
                
                % validate
                ValidationUtils.MustBeA(oSampleIdsObj, 'SampleIds');
                
                % get number of samples
                vdNumSamplesPerSampleIdsObj(dObjIndex) = oSampleIdsObj.GetNumberOfSamples();
            end
            
            dTotalNumSamples = sum(vdNumSamplesPerSampleIdsObj);
            
            oMasterSampleIdsObj = oSampleIdsObj;
            chMasterIdsClass = class(oMasterSampleIdsObj.GetGroupIds());
                        
            viGroupIds = zeros(dTotalNumSamples,1,chMasterIdsClass);
            viSubGroupIds = zeros(dTotalNumSamples,1,chMasterIdsClass);
            vsUserDefinedSampleStrings = strings(dTotalNumSamples,1);
            vbIsDuplicatedSample = false(dTotalNumSamples,1);
            
            dInsertIndex = 1;
            
            for dObjIndex = 1:dNumSampleIds
                oSampleIdsObj = c1oSampleIds{dObjIndex};
                
                % validate
                SampleIds.MustBeValidForVertcat(oMasterSampleIdsObj, oSampleIdsObj);
                
                % insert labels
                dNumToInsert = vdNumSamplesPerSampleIdsObj(dObjIndex);
                
                viGroupIds(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleIdsObj.GetGroupIds();
                viSubGroupIds(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleIdsObj.GetSubGroupIds();
                vsUserDefinedSampleStrings(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleIdsObj.GetUserDefinedSampleStrings();
                vbIsDuplicatedSample(dInsertIndex : dInsertIndex + dNumToInsert - 1) = oSampleIdsObj.IsDuplicatedSample();
                
                dInsertIndex = dInsertIndex + dNumToInsert;
            end
            
            % create new obj
            obj = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vbIsDuplicatedSample);
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
            %  varargout: If is was a selection, a SampleIds object
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
                    vdRowSelection = varargout{1}.GetRowSelection();
                    
                    viGroupIds = obj.viGroupIds(vdRowSelection);
                    viSubGroupIds = obj.viSubGroupIds(vdRowSelection);
                    vsUserDefinedSampleStrings = obj.vsUserDefinedSampleStrings(vdRowSelection);
                    vbIsDuplicatedSample = obj.vbIsDuplicatedSample(vdRowSelection);
                    
                    [vdUniqueRowSelection,~,vdOriginalIndexMapping] = unique(vdRowSelection);
                    
                    if length(vdUniqueRowSelection) < length(vdRowSelection) % there's duplicates, mark as such
                        for dUniqueRowSelectionIndex = 1:length(vdUniqueRowSelection)
                            vdOriginalIndices = find(vdOriginalIndexMapping == dUniqueRowSelectionIndex);
                            
                            if length(vdOriginalIndices) > 1
                                vbIsDuplicatedSample(vdOriginalIndices) = true;
                            end
                        end
                    end
                    
                    varargout{1} = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vbIsDuplicatedSample);
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
            end
        end
        
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj)
            %
            % DESCRIPTION:
            %  Function to coordinate printing the header, rows and footer
            %  for the SampleIds object.
            %
            % INPUT ARGUMENTS:
            %  obj: SampleIds object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            % Headers
            obj.PrintHeaders();
                        
            fprintf(newline);
            
            % Print row by row
            for dSampleIndex=1:obj.GetNumberOfSamples()
                obj.PrintRowForSample(dSampleIndex);
                
                fprintf(newline);
            end     
            
            obj.PrintFooter();
        end
    end
    
    
    methods (Access = public, Static = true) 
        
        function bBool = DoSampleIdsHaveOverlappingGroupIds(obj1, obj2)
            arguments
                obj1 (:,1) {ValidationUtils.MustBeA(obj1, 'SampleIds')}
                obj2 (:,1) {ValidationUtils.MustBeA(obj2, 'SampleIds')}
            end
            
            bBool = ~isempty(intersect(obj1.viGroupIds, obj2.viGroupIds));
        end
        
        function MustBeEqual(obj1, obj2)
            arguments
                obj1 (:,1) 
                obj2 (:,1) {ValidationUtils.MustBeA(obj2, 'SampleIds'), ValidationUtils.MustBeSameSize(obj1, obj2)}
            end
            
            if ...
                    any(obj1.viGroupIds ~= obj2.viGroupIds) ||...
                    any(obj1.viSubGroupIds ~= obj2.viSubGroupIds) ||...
                    any(obj1.vbIsDuplicatedSample ~= obj2.vbIsDuplicatedSample) ||...
                    any(obj1.vsUserDefinedSampleStrings ~= obj2.vsUserDefinedSampleStrings)
                error(...
                    'SampleIds:MustBeEqual:Invalid',...
                    'SampleIds objects are not equivalent.');
            end   
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
    end
    
    
    methods (Access = protected)    
        
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
        
        function viIds = CastNonIntegerToSmallestIntegerClass(vxIds)
            if any(vxIds < 0) % is negative
                if all(abs(vxIds) <= int8(inf))
                    viIds = int8(vxIds);
                elseif all(abs(vxIds) <= int16(inf))
                    viIds = int16(vxIds);
                elseif all(abs(vxIds) <= int32(inf))
                    viIds = int32(vxIds);
                else
                    viIds = int64(vxIds);
                end
            else
                if all(vxIds <= uint8(inf))
                    viIds = uint8(vxIds);
                elseif all(vxIds <= uint16(inf))
                    viIds = uint16(vxIds);
                elseif all(vxIds <= uint32(inf))
                    viIds = uint32(vxIds);
                else
                    viIds = uint64(vxIds);
                end
            end
        end
        
        function GroupAndSubGroupIdsUniquenessMustMatchIsDuplicatedSample(viGroupIds, viSubGroupIds, vbIsDuplicatedSample)
            m2iIdMatrix = [viGroupIds, viSubGroupIds];
            
            for dSampleIndex=1:length(viGroupIds)
                if vbIsDuplicatedSample(dSampleIndex)
                    if sum(all(m2iIdMatrix == m2iIdMatrix(dSampleIndex,:),2)) == 1
                        error(...
                            'SampleIds:GroupAndSubGroupIdsMustFormUniqueIds:InvalidNoDuplicatedWhenMarkedDuplicated',...
                            'No duplicate sample found despite being marked as such.');
                    end
                else                    
                    if sum(all(m2iIdMatrix == m2iIdMatrix(dSampleIndex,:),2)) ~= 1
                        error(...
                            'SampleIds:GroupAndSubGroupIdsMustFormUniqueIds:InvalidDuplicatedWhenMarkedNotDuplicated',...
                            'Duplicate sample found despite being marked as not being duplicated.');
                    end
                end
            end
        end
        
        function MustBeValidForVertcat(obj1, obj2)
            if...
                    ~strcmp(class(obj1.viGroupIds), class(obj2.viGroupIds)) ||...
                    ~strcmp(class(obj1.viSubGroupIds), class(obj2.viSubGroupIds))
                error(...
                    'SampleIds:MustBeValidForVertcat:Invalid',...
                    'For two SampleIds objects to be concatenated, their Group and Sub-Group IDs must be of the same class.');
            end
        end
        
        function vbIsDuplicatedSample = CreateDefaultIsDuplicatedSample(viGroupIds)
            vbIsDuplicatedSample = false(size(viGroupIds));
        end
        
        function vsUserDefinedSampleStrings = CreateDefaultUserDefinedSampleStrings(viGroupIds, viSubGroupIds)
            vsUserDefinedSampleStrings = string(viGroupIds) + "-" + string(viSubGroupIds);
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

