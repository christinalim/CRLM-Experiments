classdef FeatureValuesByValue < FeatureValues & MatrixContainer
    %FeatureValuesByValue
    %
    % Stores the Feature Values, Group/Sub-group IDs, and Feature Names is
    % a common structure. The data is passed and copied by value, meaning
    % that multiple copies of the the data may be stored in memory.
    %
    % See also: FeatureValues
    
    % Primary Author: David DeVries
    % Created: Mar 12, 2019
    % Modified: Aug 26, 2022 - C.Johnson - combine Group and SubGroup Ids
    %   into a SampleIds object
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
        
    properties (SetAccess = private, GetAccess = public)%%%(SetAccess = immutable, GetAccess = public)
        m2dUnstandardizedFeatures (:,:) double % feature values, unstandardized.
                
        oSampleIds(:,1) SampleIds = SampleIds(int8(1), int8(1), "");

        vsFeatureNames (1,:) string % unique string for each feature
        vbFeatureIsCategorical (1,:) logical % boolean flag for each column/feature to flag it is is categorical (true) or not
        
        voFeatureValuesToFeatureExtractionRecordLinks (1,:) FeatureValuesToFeatureExtractionRecordLink = FeatureValuesToFeatureExtractionRecordLink.empty(1,0)
        vdLinkIndexPerFeature (1,:) double {mustBeInteger}    
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = FeatureValuesByValue(varargin)
            %obj = FeatureValuesByValue(varargin)
            %
            % SYNTAX:
            %  obj = FeatureValuesByValue(oFeatureValuesByValue, vdRowSelection, vdColSelection)
            %  obj = FeatureValuesByValue(oSampleIds, m2dFeatures, vsFeatureNames)
            %  obj = FeatureValuesByValue(oSampleIds, m2dFeatures, vsFeatureNames, NameValueArgs)
            %  obj = FeatureValuesByValue(m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames)
            %  obj = FeatureValuesByValue(m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, NameValueArgs)
            %  obj = FeatureValuesByValue(oFeatureValuesByValue)
            %  obj = FeatureValuesByValue('horzcat', oFeatureValuesByValue1, oFeatureValuesByValue2, ...)
            %  obj = FeatureValuesByValue('vertcat', oFeatureValuesByValue1, oFeatureValuesByValue2, ...)
            %
            %  Name-Value Pair Arguments:
            %   'FeatureExtractionRecord'
            %   'FeatureIsCategorical'
            %
            % DESCRIPTION:
            %  obj = FeatureValuesByValue(oFeatureValuesByValue, vdRowSelection, vdColSelection)
            %    produces a new FeatureValuesByValue object for the given row and
            %    column selection from an existing FeatureValuesByValue object.
            %    This could be reducing or duplicating rows, but only
            %    reducing columns. The produced object will have the same
            %    FeatureValuesIdentifier as the provided object.
            %  obj = FeatureValuesByValue(m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames)
            %    produces a new FeatureValuesByValue object given the required
            %    properties. All of these properties are validated,
            %    assuming that they do not contain any duplicated samples.
            %  obj = FeatureValuesByValue(oFeatureValuesByValue)
            %    produces a new FeatureValuesByValue object that is a copy
            %    of the FeatureValuesByValue object passed in. This
            %    functionality is mostly used by child class constructors.
            %  obj = FeatureValuesByValue('horzcat', oFeatureValuesByValue1, oFeatureValuesByValue2, ...)
            %    produces a new FeatureValuesByValue object that concatenates the
            %    provides FeatureValueByValue objects (oFeatureValuesByValue1,
            %    oFeatureValuesByValue2, etc.). Horizontal concatenation 
            %    requires the same samples, but new features (columns).
            %  obj = FeatureValuesByValue('vertcat', oFeatureValuesByValue1, oFeatureValuesByValue2, ...)
            %    same as "obj = FeatureValuesByValue('horzcat',...", except for
            %    vertical concatenation. Vertical concatenation requires the
            %    same features, but new samples (rows).
            %
            % INPUT ARGUMENTS:
            %  oFeatureValuesByValue: A valid FeatureValueByValue object
            %  vdRowSelection: A row vector of row index numbers to select
            %  vdColSelection: A row vector of column index numbers to select
            %  m2dFeatures: feature table with samples along rows and
            %               features along columns
            %  viGroupIds: column vector of Group Ids for each sample. Do
            %              not to be unique
            %  viSubGroupIds: column vector of Sub Group Ids for each
            %                 sample. Need to be unique within a given Group
            %                 Id
            %  vsUserDefinedSampleStrings: a column string vector of custom
            %                              user-defined strings for each
            %                              sample
            %  vsFeatureNames: a row string array of feature names for each
            %                  column in the m2dFeatures
            %
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed class object
                         
            if nargin == 3 && isa(varargin{1}, 'FeatureValuesByValue')
                % For: obj = FeatureValuesByValue(oFeatureValuesByValue, vdRowSelection, vdColSelection)
                
                oFeatureValuesByValue = varargin{1};
                
                vdRowSelection = varargin{2};
                vdColSelection = varargin{3};
                
                oFeatureValuesByValue.MustBeValidRowAndColumnSelections(vdRowSelection, vdColSelection);
                                
                % oSampleIds
                oSampleIds = oFeatureValuesByValue.oSampleIds(vdRowSelection);
                                
                % m2dUnstandardizedFeatures
                % vsFeatureNames
                % vbFeatureIsCategorical
                m2dUnstandardizedFeatures = oFeatureValuesByValue.m2dUnstandardizedFeatures(vdRowSelection, vdColSelection);
                vsFeatureNames = oFeatureValuesByValue.vsFeatureNames(vdColSelection); 
                vbFeatureIsCategorical = oFeatureValuesByValue.vbFeatureIsCategorical(vdColSelection);
        
                % voFeatureValuesToFeatureExtractionRecordLinks
                % vdLinkIndexPerFeature
                vdSelectedLinkIndexPerFeature = oFeatureValuesByValue.vdLinkIndexPerFeature(vdColSelection);
                
                vdIndicesUsed = unique(vdSelectedLinkIndexPerFeature, 'stable');
                
                vdLinkIndexPerFeature = zeros(1,length(vdSelectedLinkIndexPerFeature));
                
                dNumLinksToKeep = length(vdIndicesUsed);
                
                for dLinkIndex=1:dNumLinksToKeep
                    vdLinkIndexPerFeature(vdSelectedLinkIndexPerFeature == vdIndicesUsed(dLinkIndex)) = dLinkIndex;
                end
                                
                voFeatureValuesToFeatureExtractionRecordLinks = oFeatureValuesByValue.voFeatureValuesToFeatureExtractionRecordLinks(vdIndicesUsed);
                
                % apply the sample selection to each feature extraction
                % record
                for dLinkIndex=1:length(voFeatureValuesToFeatureExtractionRecordLinks)
                    voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex) = ...
                        voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex).ApplySampleSelection(vdRowSelection');
                end
                                          
            elseif nargin == 1 && isa(varargin{1}, 'FeatureValuesByValue')
                oFeatureValuesByValue = varargin{1};
                
                oSampleIds = oFeatureValuesByValue.oSampleIds;                
                m2dUnstandardizedFeatures = oFeatureValuesByValue.m2dUnstandardizedFeatures; 
                vsFeatureNames = oFeatureValuesByValue.vsFeatureNames;
                vbFeatureIsCategorical = oFeatureValuesByValue.vbFeatureIsCategorical;                
                voFeatureValuesToFeatureExtractionRecordLinks = oFeatureValuesByValue.voFeatureValuesToFeatureExtractionRecordLinks;
                vdLinkIndexPerFeature = oFeatureValuesByValue.vdLinkIndexPerFeature;
                
                varargin = {oFeatureValuesByValue.m2dUnstandardizedFeatures};
                
            elseif nargin >= 3 && isa(varargin{1}, 'char') && ( strcmp(varargin{1}, 'horzcat') || strcmp(varargin{1}, 'vertcat') ) && CellArrayUtils.AreAllIndexClassesEqual(varargin(2:end)) && isa(varargin{2}, 'FeatureValuesByValue')
                % For: obj = FeatureValuesByValue('horzcat', oFeatureValuesByValue1, oFeatureValuesByValue2, ...)
                %      obj = FeatureValuesByValue('vertcat', oFeatureValuesByValue1, oFeatureValuesByValue2, ...)
                
                % oSampleIds
                c1oFeatureValuesByValue = varargin(2:end);
                dNumFeatureValuesByValue = length(c1oFeatureValuesByValue);
                c1oSampleIds = cell(dNumFeatureValuesByValue,1);
                
                for dFeatureValuesIndex=1:dNumFeatureValuesByValue
                    c1oSampleIds{dFeatureValuesIndex} = c1oFeatureValuesByValue{dFeatureValuesIndex}.oSampleIds;
                    
                    if c1oFeatureValuesByValue{dFeatureValuesIndex}.oSampleIds.ContainsDuplicatedSamples()
                        error(...
                            'FeatureValuesByValue:Constructor:InvalidContainsDuplicatedSamplesForConcatenation',...
                            'Cannot concatenate FeatureValuesByValue object after sample duplication');
                    end
                end
                
                if strcmp(varargin{1}, 'horzcat')
                    % all SampleIds must be equal
                    for dFeatureValuesIndex=1:dNumFeatureValuesByValue
                        SampleIds.MustBeEqual(c1oSampleIds{1}, c1oSampleIds{dFeatureValuesIndex});
                    end
                    
                    oSampleIds = c1oSampleIds{1}; % since they're all equal, any one can be used
                else % vertcat
                    % vertcat SampleIds (validations done by SampleIds)
                    oSampleIds = vertcat(c1oSampleIds{:});
                end
                
                % m2dUnstandardizedFeatures
                % vsFeatureNames
                % vbFeatureIsCategorical
                % voFeatureValuesToFeatureExtractionRecordLinks
                % vdLinkIndexPerFeature
                
                if strcmp(varargin{1}, 'horzcat')
                    [m2dUnstandardizedFeatures, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature] ...
                        = FeatureValuesByValue.GetProperitiesForHorzcat(c1oFeatureValuesByValue{:});
                else % vertcat
                    [m2dUnstandardizedFeatures, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature] ...
                        = FeatureValuesByValue.GetProperitiesForVertcat(c1oFeatureValuesByValue{:});
                end
                                
            elseif nargin >= 5 && isnumeric(varargin{1})
                % For: obj = FeatureValuesByValue(m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames)
                %      obj = FeatureValuesByValue(m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, NameValueArgs)
                
                m2dUnstandardizedFeatures = varargin{1};
                viGroupIds = varargin{2};
                viSubGroupIds = varargin{3};
                vsUserDefinedSampleStrings = varargin{4};
                vsFeatureNames = varargin{5};
                
                oSampleIds = SampleIds(viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings);
                
                [m2dUnstandardizedFeatures, vsFeatureNames] = FeatureValuesByValue.MustBeValidSampleIdsFeaturesAndFeatureNames(oSampleIds, m2dUnstandardizedFeatures, vsFeatureNames);
                
                [oFeatureExtractionRecord, vdSampleIndicesToFeatureExtractionRecordIndices, vbFeatureIsCategorical] = FeatureValuesByValue.ValidateAndProcessNameValueArgs(m2dUnstandardizedFeatures, varargin{6:end});
                                    
                oLink = FeatureValuesToFeatureExtractionRecordLink(oFeatureExtractionRecord, vdSampleIndicesToFeatureExtractionRecordIndices); 
                varargin = {m2dUnstandardizedFeatures};
                
                voFeatureValuesToFeatureExtractionRecordLinks = oLink;
                vdLinkIndexPerFeature = ones(1,size(m2dUnstandardizedFeatures,2));
                
            elseif nargin >= 3 && isa(varargin{1}, 'SampleIds') && isnumeric(varargin{2})           
                % For: obj = FeatureValuesByValue(oSampleIds, m2dFeatures, vsFeatureNames)
                %      obj = FeatureValuesByValue(oSampleIds, m2dFeatures, vsFeatureNames, NameValueArgs)
                
                oSampleIds = varargin{1};
                m2dUnstandardizedFeatures = varargin{2};
                vsFeatureNames = varargin{3};
                
                [m2dUnstandardizedFeatures, vsFeatureNames] = FeatureValuesByValue.MustBeValidSampleIdsFeaturesAndFeatureNames(oSampleIds, m2dUnstandardizedFeatures, vsFeatureNames);
                
                [oFeatureExtractionRecord, vdSampleIndicesToFeatureExtractionRecordIndices, vbFeatureIsCategorical] = FeatureValuesByValue.ValidateAndProcessNameValueArgs(m2dUnstandardizedFeatures, varargin{4:end});
                 
                oLink = FeatureValuesToFeatureExtractionRecordLink(oFeatureExtractionRecord, vdSampleIndicesToFeatureExtractionRecordIndices); 
                varargin = {m2dUnstandardizedFeatures};
                
                voFeatureValuesToFeatureExtractionRecordLinks = oLink;
                vdLinkIndexPerFeature = ones(1,size(m2dUnstandardizedFeatures,2));
                
            else
                error(...
                    'FeatureValuesByValue:Constructor:InvalidParameters',...
                    'See constructor documentation for usage.');
            end
            
            % Super-class:
            
            % initialize FeatureValues
            obj@FeatureValues(varargin{:});
            
            % initialize MatrixContainer            
            obj@MatrixContainer(m2dUnstandardizedFeatures);          
            
            
            % This class:          
            
            % set field values
            obj.oSampleIds = oSampleIds;
            
            obj.m2dUnstandardizedFeatures = m2dUnstandardizedFeatures;
            obj.vsFeatureNames = vsFeatureNames;            
            obj.vbFeatureIsCategorical = vbFeatureIsCategorical;
                
            obj.voFeatureValuesToFeatureExtractionRecordLinks = voFeatureValuesToFeatureExtractionRecordLinks;
            obj.vdLinkIndexPerFeature = vdLinkIndexPerFeature;
        end
        
        % >>>>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj)
            %
            % DESCRIPTION:
            %  Calls the super-class FeatureValues disp function
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            disp@FeatureValues(obj);
        end
        
        function varargout = subsref(obj, stSelection)
            %varargout = subsref(obj, stSelection)
            %
            % SYNTAX:
            %  varargout = subsref(obj, stSelection)
            %
            % DESCRIPTION:
            %  Overloading subsref to allow selections (e.g. a(1:3,4)) to
            %  be made on FeatureValueByValue objects.
            %  If it is a ".FnName" call, it is passed along to the
            %  built-in subsref for execution.
            %  If it is a "()" selection call, the MatrixContainer and
            %  FeatureValues super-class subsref implementations are
            %  called.
            %  FeatureValuesByValue objects store the entire matrix they're
            %  working with in memory as needed, and so the MatrixContainer
            %  will always contain full selections (e.g. [1,2,3,4,5]) in
            %  all of each dimension selection objects.
            %  To make the final selection, a call the FeatureValuesByValue
            %  constructor is made to make the new object
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  stSelection: Selection struct. Refer to Matlab documentation
            %               on "subsef"
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: If is was a selection, a FeatureValuesByValue object
            %             will be returned. If it was a obj.FnName() call,
            %             anything could be returned
            
            
            % call super-class method that has this call figured out
            switch stSelection(1).type
                case '.' % allow built in function to run (member methods, etc.)
                    [varargout{1:nargout}] = builtin('subsref',obj, stSelection); 
                case '()'
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
                    varargout{1} = subsref@FeatureValues(varargout{1}, stSelection);
                    
                    % if it was a selection, don't want to store the whole matrix
                    % as MatrixContainer does, since this is a waste of memory
                    % if we're passing by value
                    % We'll take the choosen selection, and apply it behind the
                    % scenes
                    varargout{1} = FeatureValuesByValue(obj, varargout{1}.GetRowSelection(), varargout{1}.GetColumnSelection());
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
            end
        end
        
        function newObj = horzcat(varargin)
            %newObj = horzcat(varargin)
            %
            % SYNTAX:
            %  newObj = [oFeatureValuesByValue1, oFeatureValuesByValue2, ...]
            %  newObj = horzcat(oFeatureValuesByValue1, oFeatureValuesByValue2, ...)
            %
            % DESCRIPTION:
            %  Overloading horzcat allows for FeatureValuesByValue objects
            %  to join their feature values horizontally (e.g. add multiple
            %  features together). This requires each object to have the
            %  same sample in each row (specified by the Group/Sub-Group
            %  ID), as well as unique features in their columns (specified
            %  by the Feature Names).
            %  FeatureValuesByValue objects that have been standardized or
            %  do/have contained duplicated samples are not valid to be
            %  concatenated
            %
            % INPUT ARGUMENTS:
            %  oFeatureValuesByValue: FeatureValuesByValue object that is
            %                         unstandardized and contains no
            %                         duplicated samples
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Class object that contains the concatenated values
            
            
            % just pass the given values on to the constructor for
            % validation and concatenation            
            newObj = FeatureValuesByValue('horzcat', varargin{:});        
        end
        
        function newObj = vertcat(varargin)
            %newObj = vertcat(varargin)
            %
            % SYNTAX:
            %  newObj = [oFeatureValuesByValue1; oFeatureValuesByValue2; ...]
            %  newObj = vertcat(oFeatureValuesByValue1, oFeatureValuesByValue2, ...)
            %
            % DESCRIPTION:
            %  Overloading vertcat allows for FeatureValuesByValue objects
            %  to join their feature values vertically (e.g. add multiple
            %  samples together). This requires each object to have the
            %  same features in each column (specified by the Feature
            %  Name), as well as unique samples in their rows (specified
            %  by the Group/Sub-Group ID pairs).
            %  FeatureValuesByValue objects that have been standardized or
            %  do/have contained duplicated samples are not valid to be
            %  concatenated
            %
            % INPUT ARGUMENTS:
            %  oFeatureValuesByValue: FeatureValuesByValue object that is
            %                         unstandardized and contains no
            %                         duplicated samples
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Class object that contains the concatenated values
            
            
            % just pass the given values on to the constructor for
            % validation and concatenation     
            newObj = FeatureValuesByValue('vertcat', varargin{:});        
        end
    end
        
    
    methods (Access = public, Sealed = true)
        % Sealed since sub-classes should not have to adjust these functions
                
        function vsFeatureNames = GetFeatureNames(obj)
            %vsFeatureNames = GetFeatureNames(obj)
            %
            % SYNTAX:
            %  vsFeatureNames = obj.GetFeatureNames()
            %
            % DESCRIPTION:
            %  Returns the Feature Names for each column of the featue table
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vsFeatureNames: Strings row vector (one for each column)
            
            vsFeatureNames = obj.vsFeatureNames;
        end
                
        function viGroupIds = GetGroupIds(obj)
            %viGroupIds = GetGroupIds(obj)
            %
            % SYNTAX:
            %  viGroupIds = obj.GetGroupIds()
            %
            % DESCRIPTION:
            %  Returns the Group IDs for the samples (with duplicates)
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viGroupIds: Column vector of integers (one for each row, 
            %              including duplicates)
            
            viGroupIds = obj.oSampleIds.GetGroupIds();
        end
        
        function viSubGroupIds = GetSubGroupIds(obj)
            %viSubGroupIds = GetSubGroupIds(obj)
            %
            % SYNTAX:
            %  viSubGroupIds = obj.GetSubGroupIds()
            %
            % DESCRIPTION:
            %  Returns the Sub Group IDs for the samples (with duplicates)
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viSubGroupIds: Column vector of integers (one for each row, 
            %                 including duplicates)
            
            viSubGroupIds = obj.oSampleIds.GetSubGroupIds();
        end
        
        function vsUserDefinedSampleStrings = GetUserDefinedSampleStrings(obj)
            %vsUserDefinedSampleStrings = GetUserDefinedSampleStrings(obj)
            %
            % SYNTAX:
            %  vsUserDefinedSampleStrings = obj.GetUserDefinedSampleStrings()
            %
            % DESCRIPTION:
            %  Returns the custom user defined strings for each sample
            %  (row) in the feature table (including duplicates).
            %  SHOULD ONLY BE USED FOR DISPLAY/DEBUGGING purposes!
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vsUserDefinedSampleStrings: Column vector of strings (one
            %                              for each row, including duplicates)
            
            vsUserDefinedSampleStrings = obj.oSampleIds.GetUserDefinedSampleStrings();
        end
        
        function vbIsFeatureCategorical = IsFeatureCategorical(obj)
            vbIsFeatureCategorical = obj.vbFeatureIsCategorical;
        end
        
        function voLinks = GetFeatureValuesToFeatureExtractionRecordLinks(obj)
            voLinks = obj.voFeatureValuesToFeatureExtractionRecordLinks;
        end
        
        function vdLinkIndices = GetLinkIndexPerFeature(obj)
            vdLinkIndices = obj.vdLinkIndexPerFeature;
        end
                
        
        % >>>>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<
        
        function vdDims = size(obj, varargin)
            %vdDims = size(obj, varargin)
            %
            % SYNTAX:
            %  vdDims = size(obj)
            %  vdDims = size(obj, dDim)
            %
            % DESCRIPTION:
            %  Returns the size of the object, where the number
            %  rows is the number of samples and the number of columns is the
            %  number of features. There should be no further dimensions
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  dDim: Dimension number
            %
            % OUTPUTS ARGUMENTS:
            %  vdDims: Scalar or vector of dimensions
        
            
            % call the MatrixContainer super-class size function
            vdDims = size@MatrixContainer(obj, varargin{:});
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>> MISC <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function obj = UnloadImageVolumeHandlersFromFeatureExtractionRecord(obj, dFeatureValuesToFeatureExtractionRecordLinkIndex, c1vsImageVolumeHandlersPathPerPortion, NameValueArgs)
            arguments
                obj (:,:) FeatureValuesByValue
                dFeatureValuesToFeatureExtractionRecordLinkIndex (1,1) double {mustBePositive, mustBeInteger}
                c1vsImageVolumeHandlersPathPerPortion (1,:) cell                
                NameValueArgs.HandlersAlreadySaved (1,1) logical = false
            end
            
            c1xVarargin = namedargs2cell(NameValueArgs);
            
            obj.voFeatureValuesToFeatureExtractionRecordLinks(dFeatureValuesToFeatureExtractionRecordLinkIndex) = ...
                obj.voFeatureValuesToFeatureExtractionRecordLinks(dFeatureValuesToFeatureExtractionRecordLinkIndex).UnloadImageVolumeHandlersToDisk(c1vsImageVolumeHandlersPathPerPortion, c1xVarargin{:});
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) 
        
        function newObj = CopyContainedMatrices(obj)
            %newObj = CopyContainedMatrices(obj, newObj)
            %
            % SYNTAX:
            %  newObj = CopyContainedMatrices(obj, newObj)
            %
            % DESCRIPTION:
            %  Copies the contained matrices to the new object.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  newObj: Copied class object
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copied class object
            
            
        end 
        
        function m2dFeatures = GetFeaturesForDisp(obj)
            m2dFeatures = obj.GetFeatures();
        end
    end
    
    
    methods (Access = protected, Sealed = true)
        % Sealed since sub-classes should not have to adjust these functions       
        
        function vdRowIndices = GetNonDuplicatedRowIndices(obj)
            %vdRowIndices = GetNonDuplicatedRowIndices(obj)
            %
            % SYNTAX:
            %  vdRowIndices = obj.GetNonDuplicatedRowIndices()
            %
            % DESCRIPTION:
            %  Gives the top-most row indices required to have one of each
            %  sample if the row selection was used
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdRowIndices: Row vector of numeric row indices
            %
            % TODO:
            %  Code is deprecated. To be removed.
            
            m2iUniqueKey = [obj.viGroupIds, obj.viSubGroupIds];
            
            [~,vdRowIndices] = unique(m2iUniqueKey, 'stable', 'rows');
        end        
                
        function m2dFeatures = GetUnstandardizedFeatures(obj)
            %m2dFeatures = GetUnstandardizedFeatures(obj)
            %
            % SYNTAX:
            %  m2dFeatures = obj.GetUnstandardizedFeatures()
            %
            % DESCRIPTION:
            %  Returns the unstandardized feature table with duplicated
            %  samples included
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  m2dFeatures: Unstandardized feature table
            
            m2dFeatures = obj.m2dUnstandardizedFeatures;
        end          
        
        function vbIsDuplicatedSample = GetIsDuplicatedSample(obj)
            %vbIsDuplicatedSample = GetIsDuplicatedSample(obj)
            %
            % SYNTAX:
            %  vbIsDuplicatedSample = obj.GetIsDuplicatedSample()
            %
            % DESCRIPTION:
            %  Returns the a column vector of booleans that specify if a
            %  row/sample has or was duplicated. Should only be used
            %  internallly, hence why it's protected
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vbIsDuplicatedSample: Column vector of booleans (one
            %                        for each row, including duplicates)
            
            vbIsDuplicatedSample = obj.oSampleIds.IsDuplicatedSample();
        end
    end
    
    
    methods (Access = protected, Static = true)
        
        function [m2dUnstandardizedFeatures, vsFeatureNames] = MustBeValidSampleIdsFeaturesAndFeatureNames(oSampleIds, m2dUnstandardizedFeatures, vsFeatureNames)
            arguments
                oSampleIds SampleIds
                m2dUnstandardizedFeatures (:,:) double {mustBeFinite}
                vsFeatureNames (1,:) string
            end
            
            if oSampleIds.GetNumberOfSamples() ~= size(m2dUnstandardizedFeatures,1)
                error(...
                    'FeatureValuesByValue:MustBeValidSampleIdsFeaturesAndFeatureNames:InvalidNumberOfRows',...
                    'The number of rows in the features matrix must be equal to the number of samples');
            end
            
            if length(vsFeatureNames) ~= size(m2dUnstandardizedFeatures,2)
                error(...
                    'FeatureValuesByValue:MustBeValidSampleIdsFeaturesAndFeatureNames:InvalidNumberOfColumns',...
                    'The number of columns in the features matrix must be equal to the number feature names');                
            end
               
            if length(vsFeatureNames) ~= length(unique(vsFeatureNames))
                error(...
                    'FeatureValuesByValue:ValidateFeatureNames:NonUniqueValues',...
                    'All Feature Names must be specified as unique strings.');
            end
        end
        
        function obj = loadobj(xLoadedData)
            if isstruct(xLoadedData)
                error(...
                    'FeatureValuesByValue:loadobj:InvalidStruct',...
                    'This is not meant to handle structs.');
            else
                obj = xLoadedData; % obj successfully loaded
                
                if isempty(obj.vbFeatureIsCategorical) % vbFeatureIsCategorical backwards compatibility 
                    obj.vbFeatureIsCategorical = false(1, obj.GetNumberOfFeatures());
                end
            end
        end
    end
    
    
    methods (Access = {?FeatureValues, ?FeatureValuesOnDiskIdentifier}, Sealed = true)
        % Access to sub-classes of FeatureValues and
        % FeatureValuesIdentifier
        % FeatureValuesIdentifier needs these functions to retrieve the
        % data for checksums and saving
        % Sealed since they shouldn't have to be over-written by
        % sub-classes
        
        function vdRowIndices = GetRowSelectionForNonDuplicatedProperties(obj)
            %vdRowSelection = GetRowSelectionForNonDuplicatedProperties(obj)
            %
            % SYNTAX:
            %  vdRowSelection = obj.GetRowSelectionForNonDuplicatedProperties()
            %
            % DESCRIPTION:
            %  Returns a row vector of row indices that can be used to create
            %  the m2dFeatures, viGroupIds, etc. from the non-duplicated
            %  versions of these properities
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdRowSelection: A row vector of doubles containing row indices
            %
            % TODO:
            %  Code is deprecated. To be removed.
            
            m2iUniqueKey = [obj.viGroupIds, obj.viSubGroupIds];
            
            [~,~,vdRowIndices] = unique(m2iUniqueKey, 'stable', 'rows');
            vdRowIndices = vdRowIndices';
        end
        
        function m2dFeatures = GetNonDuplicatedUnstandardizedFeatures(obj)
            %m2dFeatures = GetNonDuplicatedUnstandardizedFeatures(obj)
            %
            % SYNTAX:
            %  m2dFeatures = obj.GetNonDuplicatedUnstandardizedFeatures()
            %
            % DESCRIPTION:
            %  Returns the unstandardized feature table without any duplicated
            %  samples
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  m2dFeatures: Unstandardized feature table without duplicates
            
            vdRowIndices = obj.GetNonDuplicatedRowIndices();
            
            m2dFeatures = obj.m2dUnstandardizedFeatures(vdRowIndices,:);
        end
        
        function viGroupIds = GetNonDuplicatedGroupIds(obj)
            %viGroupIds = GetNonDuplicatedGroupIds(obj)
            %
            % SYNTAX:
            %  viGroupIds = obj.GetNonDuplicatedGroupIds()
            %
            % DESCRIPTION:
            %  Returns the sample Group IDs without any duplicates
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viGroupIds: Group IDs without duplicates
            %
            % TODO:
            %  Code is deprecated. To be removed.
            
            vdRowIndices = obj.GetNonDuplicatedRowIndices();
            
            viGroupIds = obj.viGroupIds(vdRowIndices);
        end
        
        function viSubGroupIds = GetNonDuplicatedSubGroupIds(obj)
            %viSubGroupIds = GetNonDuplicatedSubGroupIds(obj)
            %
            % SYNTAX:
            %  viSubGroupIds = obj.GetNonDuplicatedSubGroupIds()
            %
            % DESCRIPTION:
            %  Returns the sample Sub-Group IDs without any duplicates
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viSubGroupIds: Sub-Group IDs without duplicates
            
            vdRowIndices = obj.GetNonDuplicatedRowIndices();
            
            viSubGroupIds = obj.viSubGroupIds(vdRowIndices);
        end
                
        function vsUserDefinedSampleStrings = GetNonDuplicatedUserDefinedSampleStrings(obj)
            %vsUserDefinedSampleStrings = GetNonDuplicatedUserDefinedSampleStrings(obj)
            %
            % SYNTAX:
            %  vsUserDefinedSampleStrings = obj.GetNonDuplicatedUserDefinedSampleStrings()
            %
            % DESCRIPTION:
            %  Returns the sample strings without any duplicates
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vsUserDefinedSampleStrings: Custom string for each sample without
            %                              duplicates
            %
            % TODO:
            %  Code is deprecated. To be removed.
            
            vdRowIndices = obj.GetNonDuplicatedRowIndices();
            
            vsUserDefinedSampleStrings = obj.vsUserDefinedSampleStrings(vdRowIndices);
        end
        
        function voFeatureValuesToFeatureExtractionRecordLinks = GetNonDuplicatedFeatureValuesToFeatureExtractionRecordLinks(obj)
            vdRowIndices = obj.GetNonDuplicatedRowIndices();
            
            voFeatureValuesToFeatureExtractionRecordLinks = obj.voFeatureValuesToFeatureExtractionRecordLinks;
            
            for dLinkIndex=1:length(voFeatureValuesToFeatureExtractionRecordLinks)
                voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex) = voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex).ApplySampleSelection(vdRowIndices);
            end
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
        
        function [oFeatureExtractionRecord, vdSampleIndicesToFeatureExtractionRecordIndices, vbFeatureIsCategorical] = ValidateAndProcessNameValueArgs(m2dUnstandardizedFeatures, NameValueArgs)
            arguments
                m2dUnstandardizedFeatures (:,:) double
                NameValueArgs.FeatureExtractionRecord (1,1) FeatureExtractionRecord = CustomFeatureExtractionRecord("Unknown", "Set Manually", m2dUnstandardizedFeatures)
                NameValueArgs.FeatureIsCategorical (1,:) logical = false(1, size(m2dUnstandardizedFeatures,2));
            end
            
            dNumSamples = size(m2dUnstandardizedFeatures,1);
            dNumFeatures = size(m2dUnstandardizedFeatures,2);
            
            oFeatureExtractionRecord = NameValueArgs.FeatureExtractionRecord;
            
            if oFeatureExtractionRecord.GetNumberOfSamples() ~= dNumSamples
                error(...
                    'FeatureValuesByValue:ValidateAndProcessNameValueArgs:FeatureExtractionRecordInvalid',...
                    'FeatureExtractionRecord number of samples must match the feature matrix number of rows.');
            end
            
            vdSampleIndicesToFeatureExtractionRecordIndices = (1:size(m2dUnstandardizedFeatures,1))';
            
            vbFeatureIsCategorical = NameValueArgs.FeatureIsCategorical;
            
            if length(vbFeatureIsCategorical) ~= dNumFeatures
                error(...
                    'FeatureValuesByValue:ValidateAndProcessNameValueArgs:FeatureIsCategoricalInvalid',...
                    'vbFeatureIsCategorical length must match the feature matrix number of columns.');                
            end
            
            mustBeInteger(m2dUnstandardizedFeatures(:,vbFeatureIsCategorical)); % categorical feature values must be int
        end
        
        function [m2dUnstandardizedFeatures, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature] = GetProperitiesForHorzcat(varargin)
            %[m2dUnstandardizedFeatures, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature] = GetProperitiesForHorzcat(varargin)
            %
            % SYNTAX:
            %  [m2dUnstandardizedFeatures, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature] = FeatureValuesByValue.GetProperitiesForHorzcat(oFeatureValues1, oFeatureValues2, ...)
            %
            % DESCRIPTION:
            %  Validates that FeatureValuesByValue objects to be horizontally
            %  concatenated
            %   - No duplicated FeatureNames across objects
            %
            %  Throws an exception otherwise.
            %  From this is produces the properities required to create the
            %  new FeatureValuesByValue object
            %
            % INPUT ARGUMENTS:
            %  oFeatureValuesByValues: At least two FeatureValuesByValue objects
            %
            % OUTPUTS ARGUMENTS:
            %  m2dUnstandardizedFeatures: Feature table with samples along rows and
            %                             features along columns
            %                             (unstandardized) 
            %  vsFeatureNames: a row string array of feature names for each
            %                  column in the m2dFeatures
            %  vbIsDuplicatedSample: Column vector of booleans (one
            %                        for each row, including duplicates)
            %  voFeatureValuesToFeatureExtractionRecordLinks: TODO
            %  vdLinkIndexPerFeature: TODO
            
            
            dNumObjects = nargin;
                     
            
            % validate same sample for each row
            oMasterFeatureValuesByValue = varargin{1};
                        
            % calculate how many columns we'll need for
            % FeatureNames/Features
            
            dNumTotalFeatures = 0;
            
            for dObjectIndex=1:dNumObjects
                dNumTotalFeatures = dNumTotalFeatures + varargin{dObjectIndex}.GetNumberOfFeatures();
            end
            
            % combine all the FeatureNames/FeatureExtractionRecords together
            vsFeatureNames = strings(1,dNumTotalFeatures);
            vbFeatureIsCategorical = false(1,dNumTotalFeatures);
            vdLinkIndexPerFeature = zeros(1,dNumTotalFeatures);
            
            c1vbLinkAdded = cell(dNumObjects,1); % this will keep track of which FeatureExtractionRecords in each object have been accounted for
            
            dMaxNumberLinks = 0;
            
            for dObjectIndex=1:dNumObjects
                dNumLinks = length(varargin{dObjectIndex}.voFeatureValuesToFeatureExtractionRecordLinks);
                dMaxNumberLinks = dMaxNumberLinks + dNumLinks;
                
                c1vbLinkAdded{dObjectIndex} = false(1,dNumLinks);
            end
            
            oMasterLink = oMasterFeatureValuesByValue.voFeatureValuesToFeatureExtractionRecordLinks(1);
            
            voFeatureValuesToFeatureExtractionRecordLinks = repmat(oMasterLink,1,dMaxNumberLinks);
            dNumberOfUniqueLinks = 0;
            
            dCurrentColumnIndex = 1; % this will allow the insert of values into vsConcatenatedFeatureNames and vdFeatureExtractionRecordIndexPerFeature by one FeatureValues object at a time
            
            for dObjectIndex=1:dNumObjects
                oObject = varargin{dObjectIndex};
                dNumLinks = length(oObject.voFeatureValuesToFeatureExtractionRecordLinks);
                
                for dLinkIndex=1:dNumLinks
                    if ~c1vbLinkAdded{dObjectIndex}(dLinkIndex) % still needs to be taken care of
                        oLink = oObject.voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex);
                        oRecord = oLink.GetFeatureExtractionRecord();
                        
                        vsTempFeatureNames = strings(1,dNumTotalFeatures); %need to make sure no feature names are duplicated from the same extraction record
                        dSearchCurrentColumnIndex = dCurrentColumnIndex + oObject.GetNumberOfFeatures();
                        
                        vbFeaturesFromRecord = oObject.vdLinkIndexPerFeature == dLinkIndex;
                        dNumFeaturesFromRecord = sum(vbFeaturesFromRecord);
                        
                        vsTempFeatureNames(1:dNumFeaturesFromRecord) = oObject.vsFeatureNames(vbFeaturesFromRecord);
                        vdLinkIndexPerFeature(dCurrentColumnIndex + find(vbFeaturesFromRecord) - 1) = dNumberOfUniqueLinks + 1;
                        
                        dNumFeatureNames = dNumFeaturesFromRecord; % vsTempFeatureNames is preallocated for the worst case scenario, this will give the true number
                        
                        % gather all feature names across objects with the
                        % same feature extraction record (by UUID). Add
                        % these feature names to vsTempFeatureNames for
                        % uniqueness check later on, and set
                        % vdFeatureExtractionRecordIndexPerFeature values
                        % for if concatenation is succesful
                        for dObjectSearchIndex = dObjectIndex+1:dNumObjects
                            oSearchObject = varargin{dObjectSearchIndex};
                            dNumLinks = length(oSearchObject.voFeatureValuesToFeatureExtractionRecordLinks);
                            
                            for dLinkSearchIndex=1:dNumLinks
                                if ~c1vbLinkAdded{dObjectSearchIndex}(dLinkSearchIndex)
                                    oSearchRecord = oSearchObject.voFeatureValuesToFeatureExtractionRecordLinks(dLinkSearchIndex).GetFeatureExtractionRecord();
                                    
                                    if strcmp(oRecord.GetUuid(), oSearchRecord.GetUuid()) % we have a match!
                                        c1vbLinkAdded{dObjectSearchIndex}(dLinkSearchIndex) = true;
                                        
                                        vbFeatureBelongsToRecord = oSearchObject.vdLinkIndexPerFeature == dLinkSearchIndex;
                                        dNumFeaturesFromRecord = sum(vbFeatureBelongsToRecord);
                                        
                                        vsTempFeatureNames(dNumFeatureNames+1 : dNumFeatureNames+dNumFeaturesFromRecord) = oSearchObject.vsFeatureNames(vbFeatureBelongsToRecord);
                                        dNumFeatureNames = dNumFeatureNames + dNumFeaturesFromRecord;
                                        
                                        vdObjectFeatureIndicesToLinkToRecord = find(vbFeatureBelongsToRecord);                                        
                                        vdLinkIndexPerFeature(dSearchCurrentColumnIndex + vdObjectFeatureIndicesToLinkToRecord - 1) = dNumberOfUniqueLinks + 1;
                                    end
                                end
                            end
                            
                            dSearchCurrentColumnIndex = dSearchCurrentColumnIndex + oSearchObject.GetNumberOfFeatures();
                        end
                        
                        % all feature columns that were associated with the
                        % same feature extraction record across all the
                        % objects have been found. They have received the
                        % same number in
                        % "vdFeatureExtractionRecordIndexPerFeature"
                        % and their feature names are all within
                        % "vsTempFeatureNames"
                        
                        vsTempFeatureNames = vsTempFeatureNames(1:dNumFeatureNames);
                        
                        % check for uniqueness in vsTempFeatureNames
                        if length(vsTempFeatureNames) ~= length(unique(vsTempFeatureNames))
                            error(...
                                'FeatureValuesByValue:GetProperitiesForHorzcat:NonUniqueFeatureNames',...
                                'Feature names associated with the same feature extraction record must be unique.');
                        end
                        
                        % we're good, add the feature extraction record
                        voFeatureValuesToFeatureExtractionRecordLinks(dNumberOfUniqueLinks+1) = oLink;            
                        dNumberOfUniqueLinks = dNumberOfUniqueLinks + 1;
                    end
                end
                    
                dNumFeatures = oObject.GetNumberOfFeatures();
                
                vsFeatureNames(dCurrentColumnIndex : dCurrentColumnIndex + dNumFeatures - 1) = oObject.vsFeatureNames;
                vbFeatureIsCategorical(dCurrentColumnIndex : dCurrentColumnIndex + dNumFeatures - 1) = oObject.vbFeatureIsCategorical;
                
                dCurrentColumnIndex = dCurrentColumnIndex + dNumFeatures;
            end
            
            voFeatureValuesToFeatureExtractionRecordLinks = voFeatureValuesToFeatureExtractionRecordLinks(1:dNumberOfUniqueLinks);
                                    
            % concatenate the actual feature values
            m2dUnstandardizedFeatures = zeros(oMasterFeatureValuesByValue.GetNumberOfSamples(), dNumTotalFeatures);
            dInsertIndex = 1;
                        
            for dObjectIndex=1:dNumObjects
                dNumFeatures = varargin{dObjectIndex}.GetNumberOfFeatures();
                
                m2dUnstandardizedFeatures(:, dInsertIndex : dInsertIndex + dNumFeatures - 1) ...
                    = varargin{dObjectIndex}.m2dUnstandardizedFeatures;
                
                dInsertIndex = dInsertIndex + dNumFeatures;
            end
        end
        
        function [m2dUnstandardizedFeatures, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature] = GetProperitiesForVertcat(varargin)
            %[m2dUnstandardizedFeatures, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature] = GetProperitiesForVertcat(varargin)
            %
            % SYNTAX:
            %  [m2dUnstandardizedFeatures, vsFeatureNames, vbFeatureIsCategorical, voFeatureValuesToFeatureExtractionRecordLinks, vdLinkIndexPerFeature] = FeatureValuesByValue.GetProperitiesForVertcat(oFeatureValues1, oFeatureValues2, ...)
            %
            % DESCRIPTION:
            %  Validates that FeatureValuesByValue objects to be vertically
            %  concatenated
            %   - Same FeatureNames across objects
            %
            %  Throws an exception otherwise.
            %  From this is produces the properities required to create the
            %  new FeatureValuesByValue object
            %
            % INPUT ARGUMENTS:
            %  oFeatureValuesByValues: At least two FeatureValuesByValue objects
            %
            % OUTPUTS ARGUMENTS:
            %  m2dUnstandardizedFeatures: Feature table with samples along rows and
            %                             features along columns
            %                             (unstandardized)            %  
            %  vsFeatureNames: a row string array of feature names for each
            %                  column in the m2dFeatures
            %  c1oFeatureExtractionRecords: TODO
            %  vdFeatureExtractionRecordIndexPerFeature: TODO
            
            
            dNumObjects = nargin;
            
            % validate same features for each column
            oMasterFeatureValuesByValue = varargin{1};
            
            vsMasterFeatureNames = oMasterFeatureValuesByValue.vsFeatureNames;
            vbMasterFeatureIsCategorical = oMasterFeatureValuesByValue.vbFeatureIsCategorical;
                        
            for dObjectIndex = 2:dNumObjects
                oFeatureValuesByValue = varargin{dObjectIndex};
                
                if length(vsMasterFeatureNames) ~= length(oFeatureValuesByValue.vsFeatureNames) ||...
                        ~all(vsMasterFeatureNames == oFeatureValuesByValue.vsFeatureNames)
                    
                    error(...
                        'FeatureValuesByValue:GetProperitiesForVertcat:FeaturesMismatch',...
                        'To concatenate FeatureValuesByValue objects vertically, they all must have the same features in the same columns (specified by the feature name).');
                end
                
                if length(vbMasterFeatureIsCategorical) ~= length(oFeatureValuesByValue.vbFeatureIsCategorical) ||...
                        ~all(vbMasterFeatureIsCategorical == oFeatureValuesByValue.vbFeatureIsCategorical)
                    
                    error(...
                        'FeatureValuesByValue:GetProperitiesForVertcat:FeatureIsCategoricalMismatch',...
                        'To concatenate FeatureValuesByValue objects vertically, they all must have the same features marked as categorical or not in the same column.');
                end
            end
            
            % since we know we have the same features in each column, take
            % any of the feature names
            vsFeatureNames = vsMasterFeatureNames;
            vbFeatureIsCategorical = vbMasterFeatureIsCategorical;
            
                        
            % the feature extraction record links must be
            % concatenated vertically as well (validation will be handled
            % by the FeatureValuesToFeatureExtractionRecord class vertcat)
            
            % validate:
            
            % - check that all objects have the same number of links
            voMasterLinks = oMasterFeatureValuesByValue.voFeatureValuesToFeatureExtractionRecordLinks;
            oMasterNumberOfLinks = length(voMasterLinks);
            
            for dObjectIndex=2:dNumObjects
                if oMasterNumberOfLinks ~= length(varargin{dObjectIndex}.voFeatureValuesToFeatureExtractionRecordLinks)
                    error(...
                        'FeatureValuesByValue:GetProperitiesForVertcat:MismatchedNumberOfLinks',...
                        'All objects being concatenated must have the same number of links.');
                end
            end
                        
            
            % compute links and indices:
            
            voFeatureValuesToFeatureExtractionRecordLinks = repmat(voMasterLinks(1),1,length(voMasterLinks));
            
            for dMasterLinkIndex=1:length(voMasterLinks)
                oLink = voMasterLinks(dMasterLinkIndex);
                dLinkColumnIndex = find(oMasterFeatureValuesByValue.vdLinkIndexPerFeature, dMasterLinkIndex, 'first');
                
                c1oLinksToConcatenate = cell(dNumObjects,1);
                c1oLinksToConcatenate{1} = oLink;
                
                for dObjectSearchIndex = 2:dNumObjects
                    dSearchLinkIndex = varargin{dObjectSearchIndex}.vdLinkIndexPerFeature(dLinkColumnIndex);
                    c1oLinksToConcatenate{dObjectSearchIndex} = varargin{dObjectSearchIndex}.voFeatureValuesToFeatureExtractionRecordLinks(dSearchLinkIndex);
                end
                
                voFeatureValuesToFeatureExtractionRecordLinks(dMasterLinkIndex) = vertcat(c1oLinksToConcatenate{:});
            end
            
            % take the master link indices (since the order of links was
            % also based on the master object)
            vdLinkIndexPerFeature = oMasterFeatureValuesByValue.vdLinkIndexPerFeature;
            
            % calculate how many rows we'll need for
            % Features/Sample Strings 
            
            dNumTotalSamples = 0;
            
            for dObjectIndex=1:dNumObjects
                dNumTotalSamples = dNumTotalSamples + varargin{dObjectIndex}.GetNumberOfSamples();
            end
                        
            % concatenate the actual feature values
            m2dUnstandardizedFeatures = zeros(dNumTotalSamples, oMasterFeatureValuesByValue.GetNumberOfFeatures());
            dInsertIndex = 1;
                        
            for dObjectIndex=1:dNumObjects
                dNumSamples = varargin{dObjectIndex}.GetNumberOfSamples();
                
                m2dUnstandardizedFeatures(dInsertIndex : dInsertIndex + dNumSamples - 1, :) ...
                    = varargin{dObjectIndex}.m2dUnstandardizedFeatures;
                
                dInsertIndex = dInsertIndex + dNumSamples;
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

