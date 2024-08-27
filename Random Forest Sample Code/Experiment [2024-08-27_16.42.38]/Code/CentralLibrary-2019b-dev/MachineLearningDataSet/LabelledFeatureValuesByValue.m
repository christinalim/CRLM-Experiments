classdef LabelledFeatureValuesByValue < FeatureValuesByValue & LabelledFeatureValues
    %LabelledFeatureValuesByValue
    %
    % Stores the Feature Values, Group/Sub-group IDs, and Feature Names and
    % sample labels in a common structure.  The data is passed and copied 
    % by value, meaning that multiple copies of the the data may be stored
    % in memory.
    %
    % See also: FeatureValuesByValue, LabellelFeatureValues
    
    % Primary Author: David DeVries
    % Created: Mar 12, 2019
    %
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
          
    properties (SetAccess = immutable, GetAccess = public)
        oSampleLabels (:,1) SampleLabels = BinaryClassificationSampleLabels(SampleIds(int8(1), int8(1), ""),int8(1),int8(1),int8(0))
    end
    
    properties (Constant = true, GetAccess = private)
        chFeatureValuesXlsSheetName = 'Feature Values'
        chFeatureSourcesXlsSheetName = ''
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
      
    methods (Access = public)
                
        function obj = LabelledFeatureValuesByValue(varargin)
            % obj = LabelledFeatureValuesByValue(varargin)
            %
            % SYNTAX:
            %  obj = LabelledFeatureValuesByValue(oLabelledFeatureValuesByValue, vdRowSelection, vdColSelection)
            %  obj = LabelledFeatureValuesByValue(m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPositiveLabel, iNegativeLabel)
            %  obj = LabelledFeatureValuesByValue(m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPositiveLabel, iNegativeLabel, NameValueArgs)
            %  obj = LabelledFeatureValuesByValue(oSampleIds, m2dFeatures, vsFeatureNames, oSampleLabels)
            %  obj = LabelledFeatureValuesByValue(oSampleIds, m2dFeatures, vsFeatureNames, oSampleLabels, NameValueArgs)
            %  obj = LabelledFeatureValuesByValue(oFeatureValuesByValue, viLabels, iPositiveLabel, iNegativeLabel)
            %  obj = LabelledFeatureValuesByValue(oFeatureValuesByValue, oSampleLabels)
            %  obj = LabelledFeatureValuesByValue('horzcat', oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
            %  obj = LabelledFeatureValuesByValue('vertcat', oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
            %
            %  Name-Value Pair Arguments:
            %   'FeatureExtractionRecord'
            %   'FeatureIsCategorical'
            %
            % DESCRIPTION:
            %  obj = LabelledFeatureValuesByValue(oFeatureValuesByValue, vdRowSelection, vdColSelection)
            %    produces a new LabelledFeatureValuesByValue object for the given row and
            %    column selection from an existing LabelledFeatureValuesByValue object.
            %    This could be reducing or duplicating rows, but only
            %    reducing columns. The produced object will have the same
            %    LabelledFeatureValuesIdentifier as the provided object.
            %  obj = LabelledFeatureValuesByValue(m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPositiveLabel)
            %    produces a new LabelledFeatureValuesByValue object given the required
            %    properties. All of these properties are validated,
            %    assuming that they do not contain any duplicated samples.
            %  obj = LabelledFeatureValuesByValue(oSampleIds, m2dFeatures, vsFeatureNames, oSampleLabels)
            %    produces a new LabelledFeatureValuesByValue object that
            %    contains features that are multiclass
            %  obj = LabelledFeatureValuesByValue(oFeatureValuesByValue, viLabels, iPositiveLabel, iNegativeLabel)
            %    takes a FeatureValuesByValue object WITHOUT labels, and
            %    creates a LabelledFeatureValuesByValue object with the
            %    labels provided.
            %  obj = LabelledFeatureValuesByValue(oFeatureValuesByValue, oSampleLabels)
            %  obj = LabelledFeatureValuesByValue('horzcat', oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
            %    produces a new LabelledFeatureValuesByValue object that concatenates the
            %    provides LabelledFeatureValueByValue objects (oLabelledFeatureValuesByValue1,
            %    oLabelledFeatureValuesByValue2, etc.). Horizontal concatenation 
            %    requires the same samples, but new features (columns).
            %  obj = LabelledFeatureValuesByValue('vertcat', oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
            %    same as "obj = LabelledFeatureValuesByValue('horzcat',...", except for
            %    vertical concatenation. Vertical concatenation requires the
            %    same features, but new samples (rows).
            %
            % INPUT ARGUMENTS:
            %  oLabelledFeatureValuesByValue: A valid FeatureValueByValue object
            %  vdRowSelection: A row vector of row index numbers to select
            %  vdColSelection: A row vector of column index numbers to select
            %  m2dFeatures: feature table with samples along rows and
            %               features along columns
            %  viGroupIds: column vector of Group Ids for each sample. Do
            %              not to be unique
            %  viSubGroupIds: column vector of Sub Group Ids for each
            %                 sample. Need to be unique within a given Group
            %                 Id
            %  vsUserDefinedSampleStrings: a column vector of strings that
            %                              the user may defined for any
            %                              purpose.
            %  vsFeatureNames: a row vector of strings of feature names for
            %                  each column in the m2dFeatures
            %  viLabels: a column vector of integers containing two and
            %            only two uniquely different labels. The number of
            %            rows must match the number of samples/rows of the
            %            feature table.            
            % iPositiveLabel: an integer that sepecifies which label value
            %                 within viLabels marks a "positive" sample
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed class object
             
            if nargin == 3 && isa(varargin{1}, 'LabelledFeatureValuesByValue')
                % For: obj = LabelledFeatureValuesByValue(oLabelledFeatureValuesByValue, vdRowSelection, vdColSelection)
                
                oLabelledFeatureValuesByValue = varargin{1};
                vdRowSelection = varargin{2};
                
                oSampleLabels = oLabelledFeatureValuesByValue.oSampleLabels(vdRowSelection);
                      
                c1oFeatureValuesByValueVarargin = varargin;
                c1oLabelledFeatureValuesVarargin = varargin; 
                
            elseif (nargin == 4 || nargin == 2) && isa(varargin{1}, 'FeatureValuesByValue')
                % For: obj = LabelledFeatureValuesByValue(oFeatureValuesByValue, viLabels, iPositiveLabel, iNegativeLabel)
                %      obj = LabelledFeatureValuesByValue(oFeatureValuesByValue, oSampleIds)
                oFeatureValuesByValue = varargin{1};
                
                if nargin == 4
                    viLabels = varargin{2};
                    iPositiveLabel = varargin{3};
                    iNegativeLabel = varargin{4};
                    
                    oSampleLabels = BinaryClassificationSampleLabels(oFeatureValuesByValue.GetSampleIds(), viLabels, iPositiveLabel, iNegativeLabel);
                else % nargin == 2
                    oSampleLabels = varargin{2};
                end
                
                c1oFeatureValuesByValueVarargin = {oFeatureValuesByValue};
                c1oLabelledFeatureValuesVarargin = {oFeatureValuesByValue.m2dUnstandardizedFeatures}; 
                                
            elseif nargin >= 3 && isa(varargin{1}, 'char') && ( strcmp(varargin{1}, 'horzcat') || strcmp(varargin{1}, 'vertcat') ) && CellArrayUtils.AreAllIndexClassesEqual(varargin(2:end)) && isa(varargin{2}, 'LabelledFeatureValuesByValue')
                %  For: obj = LabelledFeatureValuesByValue('horzcat', oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
                %       obj = LabelledFeatureValuesByValue('vertcat', oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
                
                c1oLabelledFeatureValues = varargin(2:end);
                dNumLabelledFeatureValues = length(c1oLabelledFeatureValues);
                                
                if strcmp(varargin{1}, 'horzcat')
                    % all sample labels must be equal
                    for dLabelledFeatureValuesIndex=1:dNumLabelledFeatureValues
                        MustBeEqual(c1oLabelledFeatureValues{1}.oSampleLabels, c1oLabelledFeatureValues{dLabelledFeatureValuesIndex}.oSampleLabels);
                    end
                    
                    oSampleLabels = c1oLabelledFeatureValues{1}.oSampleLabels; % since they're all equal, any one can be used
                else
                    c1oSampleLabelsToCat = cell(dNumLabelledFeatureValues,1);
                    
                    for dLabelledFeatureValuesIndex=1:dNumLabelledFeatureValues
                        c1oSampleLabelsToCat{dLabelledFeatureValuesIndex} = c1oLabelledFeatureValues{dLabelledFeatureValuesIndex}.oSampleLabels;
                    end
                    
                    oSampleLabels = vertcat(c1oSampleLabelsToCat{:});
                end
                
                c1oFeatureValuesByValueVarargin = varargin;
                c1oLabelledFeatureValuesVarargin = varargin;
                                            
            elseif nargin >= 8 && isnumeric(varargin{1})
                % For: obj = LabelledFeatureValuesByValue(m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPositiveLabel, iNegativeLabel)
                %      obj = LabelledFeatureValuesByValue(m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPositiveLabel, iNegativeLabel, NameValueArgs)
                
                m2dFeatures = varargin{1};
                
                oSampleIds = SampleIds(varargin{2}, varargin{3}, varargin{4});
                
                vsFeatureNames = varargin{5};
                
                viLabels = varargin{6};
                iPositiveLabel = varargin{7};                
                iNegativeLabel = varargin{8};
                
                c1oNameValueArgs = varargin(9:end);
                
                oSampleLabels = BinaryClassificationSampleLabels(oSampleIds, viLabels, iPositiveLabel, iNegativeLabel);
                
                LabelledFeatureValuesByValue.MustBeValidSampleLabels(oSampleIds, oSampleLabels);
                
                c1oFeatureValuesByValueVarargin = [{oSampleIds, m2dFeatures, vsFeatureNames}, c1oNameValueArgs];
                c1oLabelledFeatureValuesVarargin = {m2dFeatures}; 
                
            elseif nargin >= 4 && isa(varargin{1}, 'SampleIds') && isnumeric(varargin{2})
                %  obj = LabelledFeatureValuesByValue(oSampleIds, m2dFeatures, vsFeatureNames, oSampleLabels)
                %  obj = LabelledFeatureValuesByValue(oSampleIds, m2dFeatures, vsFeatureNames, oSampleLabels, NameValueArgs)
                
                oSampleIds = varargin{1};
                
                m2dFeatures = varargin{2};
                vsFeatureNames = varargin{3};
                
                oSampleLabels = varargin{4};
                
                c1oNameValueArgs = varargin(5:end);
                
                LabelledFeatureValuesByValue.MustBeValidSampleLabels(oSampleIds, oSampleLabels);
                
                c1oFeatureValuesByValueVarargin = [{oSampleIds, m2dFeatures, vsFeatureNames}, c1oNameValueArgs];
                c1oLabelledFeatureValuesVarargin = {m2dFeatures}; 
                
            else
                error(...
                    'FeatureValuesByValue:Constructor:InvalidParameters',...
                    'See constructor documentation for usage.');
            end
                        
            % Super-class constructor calls
            obj@FeatureValuesByValue(c1oFeatureValuesByValueVarargin{:});            
            obj@LabelledFeatureValues(c1oLabelledFeatureValuesVarargin{:}); 
            
            % this class:
            obj.oSampleLabels = oSampleLabels;
        end
        
        function SaveToXls(obj, chXlsFilePath, NameValueArgs)
            arguments
                obj (:,:) FeatureValuesByValue
                chXlsFilePath (1,:) char
                NameValueArgs.Overwrite (1,1) logical = true
            end
            
            % clear out file if overwrite flag given
            if NameValueArgs.Overwrite
                if exist(chXlsFilePath, 'File')
                    delete(chXlsFilePath);
                end
            end
            
            % get feature source names/sheet names
            dNumFeatureSources = length(obj.voFeatureValuesToFeatureExtractionRecordLinks);
            
            vsFeatureSourceSheetNames = strings(1,dNumFeatureSources);
            
            for dFeatureSourceIndex=1:dNumFeatureSources
                chSheetName = char(obj.voFeatureValuesToFeatureExtractionRecordLinks(dFeatureSourceIndex).GetFeatureExtractionRecord().GetImageSource());
                chSheetName = chSheetName(1:min(31, length(chSheetName))); % max sheet name length is 31 chars (who knew!)
                
                vsFeatureSourceSheetNames(dFeatureSourceIndex) = string(chSheetName);
            end
            
            % write main FeatureValues sheet
            % - headers
            vsPerSampleHeaders = [...
                "Sample #",...
                "Duplicate?",...
                "Label",...
                "Positive?",...
                "Group ID",...
                "Sub-Group ID",...
                "Sample String"];
            
            writematrix(...
                vsPerSampleHeaders, chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'A3');
            
            for dFeatureSourceIndex=1:dNumFeatureSources
                writematrix(...
                    vsPerSampleHeaders, chXlsFilePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', vsFeatureSourceSheetNames(dFeatureSourceIndex),...
                    'Range', 'A5');
            end
            
            vsPerFeatureHeaders = [...
                "Feature #";...
                "Feature Source";...
                "Feature Name"];
            
            writematrix(...
                vsPerFeatureHeaders, chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'H1');
            
            % - sample #
            dNumSamples = obj.GetNumberOfSamples();
            
            writematrix(...
                (1:dNumSamples)', chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'A4');
            
            for dFeatureSourceIndex=1:dNumFeatureSources
                writematrix(...
                    (1:dNumSamples)', chXlsFilePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', vsFeatureSourceSheetNames(dFeatureSourceIndex),...
                    'Range', 'A6');
            end
            
            % - is duplicate
            vsMarkers = repmat("*",dNumSamples,1);
            vsMarkers(~obj.oSampleIds.IsDuplicatedSample()) = "";
                        
            writematrix(...
                vsMarkers, chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'B4');
            
            for dFeatureSourceIndex=1:dNumFeatureSources
                writematrix(...
                    vsMarkers, chXlsFilePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', vsFeatureSourceSheetNames(dFeatureSourceIndex),...
                    'Range', 'B6');
            end
            
            % - labels
            writematrix(...
                obj.oSampleLabels.GetLabels(), chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'C4');
            
            for dFeatureSourceIndex=1:dNumFeatureSources
                writematrix(...
                    obj.oSampleLabels.GetLabels(), chXlsFilePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', vsFeatureSourceSheetNames(dFeatureSourceIndex),...
                    'Range', 'C6');
            end
            
            % - is positive
            vsMarkers = repmat("*",dNumSamples,1);
            vsMarkers(obj.oSampleLabels.GetLabels() == obj.GetNegativeLabel()) = "";
            
            writematrix(...
                vsMarkers, chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'D4');
            
            for dFeatureSourceIndex=1:dNumFeatureSources
                writematrix(...
                    vsMarkers, chXlsFilePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', vsFeatureSourceSheetNames(dFeatureSourceIndex),...
                    'Range', 'D6');
            end
            
            % - Group ID/Sub-Group ID
            writematrix(...
                obj.oSampleIds.GetGroupIds(), chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'E4');
            
            for dFeatureSourceIndex=1:dNumFeatureSources
                writematrix(...
                    obj.oSampleIds.GetGroupIds(), chXlsFilePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', vsFeatureSourceSheetNames(dFeatureSourceIndex),...
                    'Range', 'E6');
            end
            
            writematrix(...
                obj.oSampleIds.GetSubGroupIds(), chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'F4');
            
            for dFeatureSourceIndex=1:dNumFeatureSources
                writematrix(...
                    obj.oSampleIds.GetSubGroupIds(), chXlsFilePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', vsFeatureSourceSheetNames(dFeatureSourceIndex),...
                    'Range', 'F6');
            end
            
            % - User Defined Sample String
            writematrix(...
                obj.oSampleIds.GetUserDefinedSampleStrings(), chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'G4');
            
            for dFeatureSourceIndex=1:dNumFeatureSources
                writematrix(...
                    obj.oSampleIds.GetUserDefinedSampleStrings(), chXlsFilePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', vsFeatureSourceSheetNames(dFeatureSourceIndex),...
                    'Range', 'G6');
            end
            
            % - Feature #
            dNumFeatures = obj.GetNumberOfFeatures();
            
            writematrix(...
                1:dNumFeatures, chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'I1');
            
            % - Feature Sources
            vsFeatureSourceStrings = strings(1,dNumFeatures);
            
            for dFeatureIndex=1:dNumFeatures
                dLinkIndex = obj.vdLinkIndexPerFeature(dFeatureIndex);
                
                vsFeatureSourceStrings(dFeatureIndex) = ...
                    num2str(dLinkIndex) +...
                    ": " + ...
                    obj.voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex).GetFeatureExtractionRecord().GetImageSource();
            end
            
            writematrix(...
                vsFeatureSourceStrings, chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'I2');
            
            % - Feature Names
            writematrix(...
                obj.vsFeatureNames, chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'I3');
            
            % - Feature Values Data
            writematrix(...
                obj.GetFeatures(), chXlsFilePath,...
                'FileType', 'spreadsheet',...
                'Sheet', LabelledFeatureValuesByValue.chFeatureValuesXlsSheetName,...
                'Range', 'I4');
            
            
            % write feature source links
            for dFeatureSourceIndex=1:length(obj.voFeatureValuesToFeatureExtractionRecordLinks)
                sSheetName = vsFeatureSourceSheetNames(dFeatureSourceIndex);
                oRecord = obj.voFeatureValuesToFeatureExtractionRecordLinks(dFeatureSourceIndex).GetFeatureExtractionRecord();
                
                vsHighLevelMetadata = [...
                    "Feature Source:", oRecord.GetImageSource();...
                    "UUID:", oRecord.GetUuid();...
                    "Created On:", datestr(oRecord.GetCreationTimestamp(), "mmm dd, yyyy HH:MM:SS")];
                    
                writematrix(...
                    vsHighLevelMetadata, chXlsFilePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', sSheetName,...
                    'Range', 'A1');
                
                obj.voFeatureValuesToFeatureExtractionRecordLinks(dFeatureSourceIndex).WritePerSampleDataToXls(chXlsFilePath, sSheetName);
            end
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
            
            disp@LabelledFeatureValues(obj);
        end
        
        function varargout = subsref(obj, stSelection)
            %varargout = subsref(obj, stSelection)
            %
            % SYNTAX:
            %  varargout = subsref(obj, stSelection)
            %
            % DESCRIPTION:
            %  Overloading subsref to allow selections (e.g. a(1:3,4)) to
            %  be made on matrix containers. Also handles a.FnName() calls.
            %  Operates for FeatureValuesByValue by calling the
            %  MatrixContainer implementation and then applying this
            %  selection.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  stSelection: Selection struct. Refer to Matlab documentation
            %               on "subsef"
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: If is was a selection, a MatrixContainer object
            %             will be returned. If it was a a.FnName() call,
            %             anything could be returned
                       
            
            % call super-class method that has this call figured out
            switch stSelection(1).type
                case '.' % allow built in function to run (member methods, etc.)
                    [varargout{1:nargout}] = builtin('subsref',obj, stSelection); 
                case '()'
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
                    varargout{1} = subsref@LabelledFeatureValues(varargout{1}, stSelection);
                    
                    % if it was a selection, don't want to store the whole matrix
                    % as MatrixContainer does, since this is a waste of memory
                    % if we're passing by value
                    % We'll take the choosen selection, and apply it behind the
                    % scenes
                    varargout{1} = LabelledFeatureValuesByValue(obj, varargout{1}.GetRowSelection(), varargout{1}.GetColumnSelection());                
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
            end
        end
        
        function newObj = horzcat(varargin)
            %newObj = horzcat(varargin)
            %
            % SYNTAX:
            %  newObj = [oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...]
            %  newObj = horzcat(oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
            %
            % DESCRIPTION:
            %  Overloading horzcat allows for LabelledFeatureValuesByValue objects
            %  to join their feature values horizontally (e.g. add multiple
            %  features together). This requires each object to have the
            %  same sample in each row (specified by the Group/Sub-Group
            %  ID), as well as unique features in their columns (specified
            %  by the Feature Names).
            %  LabelledFeatureValuesByValue objects that have been standardized or
            %  do/have contained duplicated samples are not valid to be
            %  concatenated
            %
            % INPUT ARGUMENTS:
            %  oLabelledFeatureValuesByValue: LabelledFeatureValuesByValue object that is
            %                                 unstandardized and contains no
            %                                 duplicated samples
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Class object that contains the concatenated values
            
            
            % just pass the given values on to the constructor for
            % validation and concatenation  
            if numel(varargin) == 1
                newObj = varargin{1};
            else
                newObj = LabelledFeatureValuesByValue('horzcat', varargin{:});        
            end
        end
        
        function newObj = vertcat(varargin)
            %newObj = vertcat(varargin)
            %
            % SYNTAX:
            %  newObj = [oLabelledFeatureValuesByValue1; oLabelledFeatureValuesByValue2; ...]
            %  newObj = vertcat(oLabelledFeatureValuesByValue1, oLabelledFeatureValuesByValue2, ...)
            %
            % DESCRIPTION:
            %  Overloading vertcat allows for LabelledFeatureValuesByValue objects
            %  to join their feature values vertically (e.g. add multiple
            %  samples together). This requires each object to have the
            %  same features in each column (specified by the Feature
            %  Name), as well as unique samples in their rows (specified
            %  by the Group/Sub-Group ID pairs).
            %  LabelledFeatureValuesByValue objects that have been standardized or
            %  do/have contained duplicated samples are not valid to be
            %  concatenated
            %
            % INPUT ARGUMENTS:
            %  oLabelledFeatureValuesByValue: LabelledFeatureValuesByValue object that is
            %                                 unstandardized and contains no
            %                                 duplicated samples
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Class object that contains the concatenated values
            
            
            % just pass the given values on to the constructor for
            % validation and concatenation    
            if numel(varargin) == 1
                newObj = varargin{1};
            else
                newObj = LabelledFeatureValuesByValue('vertcat', varargin{:});        
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>>> VALIDATORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustBeValidForBinaryClassification(obj)
            if ~isa(obj.oSampleLabels, 'BinaryClassificationSampleLabels')
                error(...
                    'LabelledFeatureValuesByValue:MustBeValidForBinaryClassification:Invalid',...
                    'The SampleLabels must be for Binary Classification for the LabelledFeatureValuesByValue to be used for binary classification..');
            end
        end
        
    end
    
    
    methods (Access = public, Sealed = true) 
        % Sealed since sub-classes should not have to adjust these functions
               
        function viLabels = GetLabels(obj)
            %viLabels = GetLabels(obj)
            %
            % SYNTAX:
            %  viLabels = GetLabels(obj)
            %
            % DESCRIPTION:
            %  Provides the sample labels (positive/negative)
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viLabels: Column vector of integers (one for each row)
            
            arguments
                obj (:,:) LabelledFeatureValuesByValue {MustBeValidForBinaryClassification}
            end
            
            viLabels = obj.oSampleLabels.GetLabels();
        end 
        
        function iPositiveLabel = GetPositiveLabel(obj)
            %iPositiveLabel = GetPositiveLabel(obj)
            %
            % SYNTAX:
            %  iPositiveLabel = GetPositiveLabel(obj)
            %
            % DESCRIPTION:
            %  Provides the positive label
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  iPositiveLabel: The positive label
            
            arguments
                obj (:,:) LabelledFeatureValuesByValue {MustBeValidForBinaryClassification}
            end
            
            iPositiveLabel = obj.oSampleLabels.GetPositiveLabel();
        end    
        
        function iNegativeLabel = GetNegativeLabel(obj)
            %iNegativeLabel = GetNegativeLabel(obj)
            %
            % SYNTAX:
            %  iNegativeLabel = GetNegativeLabel(obj)
            %
            % DESCRIPTION:
            %  Provides the negative label
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  iNegativeLabel: The negative label
            
            arguments
                obj (:,:) LabelledFeatureValuesByValue {MustBeValidForBinaryClassification}
            end
            
            iNegativeLabel = obj.oSampleLabels.GetNegativeLabel;
        end 
    end
    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    

    methods (Access = protected)

        function newObj = AddDuplicateRowIndices(obj, vdDuplicateRowIndices)
            %newObj = AddDuplicateRowIndices(obj, vdDuplicateRowIndices)
            %
            % SYNTAX:
            %  newObj = AddDuplicateRowIndices(obj, vdDuplicateRowIndices)
            %
            % DESCRIPTION:
            %  Produces a new LabelledFeatureValuesByValue object with the
            %  provided rows duplicated.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  vdDuplicateRowIndices: Numeric row vector of row indices to
            %                         duplicate in the produced object
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Produced class object with duplicated rows
            
            
            % validate vdDuplicateRowIndices
            if ~isrow(vdDuplicateRowIndices) || ~isnumeric(vdDuplicateRowIndices)
                error(...
                    'LabelledFeatureValuesByValue:AddDuplicateRowIndices:InvalidRowIndices',...
                    'Row indices to duplicate must be given as a row vector of type double.');
            end
            
            % create new object using constructor
            vdDims = size(obj);
            
            vdRowIndices = [1:vdDims(1), vdDuplicateRowIndices];
            vdColIndices = 1:vdDims(2);
            
            newObj = LabelledFeatureValuesByValue(obj, vdRowIndices, vdColIndices); 
            
            % extra validation that the object was flagged.
            % (This should always pass, especially with unit testing in
            % place, but it's important to be sure!)
            if ~newObj.ContainsDuplicatedSamples
                error(...
                    'LabelledFeatureValues:AddDuplicateRowIndices:ConsistencyCheckFailure',...
                    'Even though duplicate indices were added to the LabelledFeatureValuesByValue object, it was not flagged as containing duplicate values. This is a programming failure.');
            end
        end
        
        function [viGroupIds, vdNumSamplesMatchingLabel] = GetGroupIdsAndNumberOfSamplesMatchingLabel(obj, iLabel)
            %[viGroupIds, vdNumSamplesMatchingLabel] = GetGroupIdsAndNumberOfSamplesMatchingLabel(obj, iLabel)
            %
            % SYNTAX:
            %  [viGroupIds, vdNumSamplesMatchingLabel] = obj.GetGroupIdsAndNumberOfSamplesMatchingLabel(iLabel)
            %
            % DESCRIPTION:
            %  Returns all the Group IDs that have one or more samples that
            %  match the provided labels. If a Group ID is returned, the number
            %  of samples that match that label is also given
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  iLabel: The label to match to. Must exactly match either the
            %          positive or negative label of the object
            %
            % OUTPUTS ARGUMENTS:
            %  viGroupIds: Column vector of Group IDs that have at least one
            %              sample with a matching label
            %  vdNumSamplesMatchingLabel: Column vector of the same size of
            %                             viGroupIds that holds the number of
            %                             samples within the group that match
            %                             the label
            
            viUniqueGroupIds = unique(obj.oSampleIds.GetGroupIds());
            dNumGroups = length(viUniqueGroupIds);
            
            vdNumSamplesMatchingLabel = zeros(dNumGroups,1);
            
            viGroupIdsPerSample = obj.GetSampleIds().GetGroupIds();
            viLabelsPerSample = obj.GetSampleLabels().GetLabels();
            dNumSamples = obj.GetNumberOfSamples();
            
            for dSampleIndex=1:dNumSamples
                if viLabelsPerSample(dSampleIndex) == iLabel
                    iGroupId = viGroupIdsPerSample(dSampleIndex);
                    
                    dGroupIdIndex = find(viUniqueGroupIds == iGroupId);
                    
                    vdNumSamplesMatchingLabel(dGroupIdIndex) = vdNumSamplesMatchingLabel(dGroupIdIndex) + 1;
                end
            end
            
            viGroupIds = viUniqueGroupIds(vdNumSamplesMatchingLabel ~= 0);
            vdNumSamplesMatchingLabel = vdNumSamplesMatchingLabel(vdNumSamplesMatchingLabel ~= 0);
        end
        
        function vdSampleIndices = GetRandomSampleIndicesWithinGroupIdMatchingLabel(obj, iGroupId, iLabel, dNumSamplesToSelect, dNumSamplesInGroupMatchingLabel)
            %vdSampleIndices = GetRandomSampleIndicesWithinGroupIdMatchingLabel(obj, iGroupId, iLabel, dNumSamplesToSelect, dNumSamplesInGroupMatchingLabel)
            %
            % SYNTAX:
            %  vdSampleIndices = obj.GetRandomSampleIndicesWithinGroupIdMatchingLabel(iGroupId, iLabel, dNumSamplesToSelect, dNumSamplesInGroupMatchingLabel)
            %
            % DESCRIPTION:
            %  Randomly returns the number of sample indices (rows in the
            %  LabelledFeatureValues table) requested, such that:
            %   - the samples' Group IDs match the one given
            %   - the samples' labels match the one given
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  iGroupId: The Group ID to select samples from
            %  iLabel: The label the samples must match
            %  dNumSamplesToSelect: The number of samples to randomly select.
            %                       dNumSamplesToSelect < dNumSamplesInGroupMatchingLabel
            %  dNumSamplesInGroupMatchingLabel: The number of samples with the
            %                                   group that are known to have
            %                                   the matching label.
            %                                   **NOTE**: This value could
            %                                   easily be misused. It is
            %                                   included to save computational
            %                                   overhead, since GetGroupIdsAndNumberOfSamplesMatchingLabel
            %                                   has probably been called before
            %                                   this and that value has already
            %                                   been calculated. Please
            %                                   CAREFULLY pass that value back
            %                                   in here.
            %
            % OUTPUTS ARGUMENTS:
            %  vdSampleIndices: The selected row indices of the
            %                   LabelledFeatureValues object
            
            if dNumSamplesToSelect > dNumSamplesInGroupMatchingLabel
                error(...
                    'LabelledFeatureValuesByValue:GetRandomSampleIndicesWithinGroupIdMatchingLabel:InvalidNumberOfSamplesToSelect',...
                    'The number of samples to select must be less than the number of samples in the group and matching the label.');
            end
            
            vdSampleIndices = zeros(1,dNumSamplesToSelect);
            
            vdMatchingSamplesToSelect = randperm(dNumSamplesInGroupMatchingLabel, dNumSamplesToSelect);
            
            dNumMatchingSamples = 0;
            dNumSamplesSelected = 0;
            dSampleIndex = 1;
            
            viGroupIdsPerSample = obj.GetSampleIds().GetGroupIds();
            viLabelsPerSample = obj.GetSampleLabels().GetLabels();
            
            while dNumSamplesSelected < dNumSamplesToSelect
                iGroupIdSelected = viGroupIdsPerSample(dSampleIndex);
                iLabelSelected = viLabelsPerSample(dSampleIndex);
                                
                if iGroupIdSelected == iGroupId && iLabelSelected == iLabel
                    % e.g. we've found the nth sample with the same Group ID and label
                    dNumMatchingSamples = dNumMatchingSamples + 1; 
                    
                    % check if this is one for us to select
                    if any(vdMatchingSamplesToSelect == dNumMatchingSamples)
                        dNumSamplesSelected = dNumSamplesSelected + 1;
                        vdSampleIndices(dNumSamplesSelected) = dSampleIndex;
                    end
                end
                
                dSampleIndex = dSampleIndex + 1;
            end
        end
    end
    
    methods (Access = {?LabelledFeatureValues, ?LabelledFeatureValuesOnDiskIdentifier}, Sealed = true)
        % Access to sub-classes of LabelledFeatureValues and
        % LabelledFeatureValuesIdentifier
        % LabelledFeatureValuesIdentifier needs these functions to retrieve the
        % data for checksums and saving
        % Sealed since they shouldn't have to be over-written by
        % sub-classes
        
        function viLabels = GetNonDuplicatedLabels(obj)
            %viLabels = GetNonDuplicatedLabels(obj)
            %
            % SYNTAX:
            %  viLabels = obj.GetNonDuplicatedLabels()
            %
            % DESCRIPTION:
            %  Returns the labels without any duplicated
            %  samples
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  viLabels: Labels without duplicates
            %
            % TODO:
            %  Code is deprecated. To be removed.
            
            vdRowIndices = obj.GetNonDuplicatedRowIndices();
            
            viLabels = obj.viLabels(vdRowIndices);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
        
        function MustBeValidSampleLabels(oSampleIds, oSampleLabels)
            SampleIds.MustBeEqual(oSampleIds, oSampleLabels.GetSampleIds());
        end               
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)
        function newObj = AddDuplicateRowIndices_UnitTest(obj, vdDuplicateRowIndices)
            newObj = AddDuplicateRowIndices(obj, vdDuplicateRowIndices);
        end
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

