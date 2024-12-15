classdef (Abstract) FeatureValues < MachineLearningDataSet
    %FeatureValues
    %
    % FeatureValues is an ABSTRACT class (cannot be instianted) that
    % describes a common functionality that all implementations of a
    % FeatureValues object should provide. It also provides validation
    % functions for the data that would likely be stored with a
    % FeatureValues object
    
    % Primary Author: David DeVries
    % Created: Mar 8, 2019
    % Modified: Aug 31, 2022 - C.Johnson - Inherit from MachineLearningDataSet
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************
        
    properties (SetAccess = immutable, GetAccess = public)
        bContainsDuplicatedSamples (1,1) logical = false % set to true if a sample is or has ever been duplicated with the FeatureValues object
    end
    
    properties (SetAccess = protected, GetAccess = public)
        % store the state of the FeatureValue object's standardization
        vdFeatureStandardizationMeans (1,:) double = []
        vdFeatureStandardizationStDevs (1,:) double = []
        bIsStandardized (1,1) logical = false
        bIsPerturbed (1,1) logical = false
        m2dPerturbationMatrix (:,:) double = []
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Abstract = true)
        
        viGroupIds = GetGroupIds(obj)
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
        
        viSubGroupIds = GetSubGroupIds(obj)
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
        
        vsUserDefinedSampleStrings = GetUserDefinedSampleStrings(obj)
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
                
        vsFeatureNames = GetFeatureNames(obj)
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
        %  vsFeatureNames: String row vector (one for each column)
        
        vdDims = size(obj, varargin)
        %vdDims = size(obj, varargin)
        %
        % SYNTAX:
        %  vdDims = size(obj)
        %  vdDims = size(obj, dDim)
        %
        % DESCRIPTION:
        %  Returns the size of the FeatureValues object, where the number
        %  rows is the number of samples and the number of columns is the
        %  number of features. There should be no further dimensions
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %  dDim: Dimension number
        %
        % OUTPUTS ARGUMENTS:
        %  vdDims: Scalar or vector of dimensions
        
    end

    
    methods (Access = public)
        
        function obj = FeatureValues(varargin)
            %obj = FeatureValues(varargin)
            %
            % SYNTAX:
            %   obj = FeatureValues(oFeatureValues, vdRowSelection, vdColSelection)
            %   obj = FeatureValues(m2dUnstandardizedFeatures)
            %   obj = FeatureValues('horzcat', oFeatureValues1, oFeatureValues2, ...)
            %   obj = FeatureValues('vertcat', oFeatureValues1, oFeatureValues2, ...)
            %
            % DESCRIPTION:
            %  obj = FeatureValues() can only be used if through the
            %    inheritance structure, the FeatureValues constructor has
            %    already been called. This allows for a solution around the
            %    "Diamond Problem" and allows for computationally intensive
            %    constructors to be avoided from being called multiple
            %    times. If it wasn't called before, the constructor will
            %    know.
            %  obj = FeatureValues(oFeatureValuesOnDiskIdentifier) uses a 
            %    oFeatureValuesOnDiskIdentifier object to load the
            %    neccesary data FeatureValues requires
            %  obj = FeatureValues(oFeatureValues, vdRowSelection, vdColSelection)
            %    produces a new FeatureValues object for the given row and
            %    column selection from an existing FeatureValues object.
            %    This could be reducing or duplicating rows, but only
            %    reducing columns. The produced object will have the same
            %    FeatureValuesIdentifier as the provided object.
            %  obj = FeatureValues(oFeatureValues)
            %    produces a new FeatureValues object that is a copy of the
            %    oFeatureValues object
            %  obj = FeatureValues(m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames)
            %    produces a new FeatureValues object given the required
            %    properties. All of these properties are validated,
            %    assuming that they do not contain any duplicated samples.
            %  obj = FeatureValues('horzcat', m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, oFeatureValues1, oFeatureValues2, ...)
            %    produces a new FeatureValues object that concatenates the
            %    provides FeatureValue objects (oFeatureValues1,
            %    oFeatureValues2, etc.). It also takes in what the
            %    sub-class implementation anticipates using as it's key
            %    properties. These properties should not contain duplciated
            %    samples. Horizontal concatenation requires the same
            %    samples, but new features (columns).
            %  obj = FeatureValues('vertcat', m2dUnstandardizedFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, oFeatureValues1, oFeatureValues2, ...)
            %    same as "obj = FeatureValues('horzcat',...", except for
            %    vertical concatenation. Vertical concatenation requires the
            %    same features, but new samples (rows).
            %
            % INPUT ARGUMENTS:
            %  oFeatureValuesOnDiskIdentifier: A valid FeatureValuesOnDiskIdentifier
            %                                  object
            %  oFeatureValues: A valid FeatureValue object
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
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed class object
            
            obj@MachineLearningDataSet();
            
            if nargin == 0
                % For: obj = FeatureValues()
                
                if isempty(obj.chUuid)
                    error(...
                        'FeatureValues:Constructor:InvalidEmptyCall',...
                        'The FeatureValues constructor was called without any parameters, suggesting the sub-class wanted to skip the constructor because it has already been called by a different inheritance path (e.g. the diamond problem). This did not occur though. Please check the order of your super-class constructor calls.');                
                end
                
            elseif nargin == 3 && isa(varargin{1}, 'FeatureValues')                
                % For: obj = FeatureValues(oFeatureValues, vdRowSelection, vdColSelection)
                
                oFeatureValues = varargin{1};
                vdRowSelection = varargin{2};
                vdColSelection = varargin{3};
                
                oFeatureValues.MustBeValidRowAndColumnSelections(vdRowSelection, vdColSelection);
                                                
                % transfer standardization
                if oFeatureValues.bIsStandardized
                    obj.vdFeatureStandardizationMeans = oFeatureValues.vdFeatureStandardizationMeans(vdColSelection);
                    obj.vdFeatureStandardizationStDevs = oFeatureValues.vdFeatureStandardizationStDevs(vdColSelection);
                end
                
                obj.bIsStandardized = oFeatureValues.bIsStandardized;
                
                % check for duplications
                
                % row check
                if length(unique(vdRowSelection)) == length(vdRowSelection) % no row duplciates
                    obj.bContainsDuplicatedSamples = false || oFeatureValues.bContainsDuplicatedSamples; % if it at one point contained duplicate samples, the flag will always be true
                else
                    obj.bContainsDuplicatedSamples = true;
                end
                
                % transfer perturbation
                obj.bIsPerturbed = oFeatureValues.bIsPerturbed;
                
                if obj.bIsPerturbed
                    obj.m2dPerturbationMatrix = oFeatureValues.m2dPerturbationMatrix(vdRowSelection, vdColSelection);
                end
                
            elseif nargin == 1 && isa(varargin{1}, 'FeatureValues')
                % For: obj = FeatureValues(oFeatureValues)
                oFeatureValues = varargin{1};
                
                obj.bContainsDuplicatedSamples = oFeatureValues.bContainsDuplicatedSamples;
                obj.vdFeatureStandardizationMeans = oFeatureValues.vdFeatureStandardizationMeans;
                obj.vdFeatureStandardizationStDevs = oFeatureValues.vdFeatureStandardizationStDevs;
                obj.bIsStandardized = oFeatureValues.bIsStandardized;
                obj.bIsPerturbed = oFeatureValues.bIsPerturbed;
                obj.m2dPerturbationMatrix = oFeatureValues.m2dPerturbationMatrix;
                
            elseif nargin >= 2 && isa(varargin{1}, 'char') && (strcmp(varargin{1}, 'horzcat') || strcmp(varargin{1}, 'vertcat')) && CellArrayUtils.AreAllIndexClassesEqual(varargin(2:end)) && isa(varargin{2}, 'FeatureValues')
                % For: obj = FeatureValues('horzcat', oFeatureValues1, oFeatureValues2, ...)
                %      obj = FeatureValues('vertcat', oFeatureValues1, oFeatureValues2, ...)
                
                c1oFeatureValues = varargin(2:end);
                dNumFeatureValues = length(c1oFeatureValues);
                
                % bContainsDuplicatedSamples
                % - validate all FeatureValues do NOT contain duplicated samples
                for dFeatureValuesIndex=1:dNumFeatureValues
                    if c1oFeatureValues{dFeatureValuesIndex}.bContainsDuplicatedSamples
                        error(...
                            'FeatureValues:Constructor:InvalidSampleDuplicationForConcatenation',...
                            'FeatureValue objects cannot be standardized before concatenation.');
                    end
                end
                
                % - set value
                obj.bContainsDuplicatedSamples = false;
                
                % bIsStandardized
                % vdFeatureStandardizationMeans
                % vdFeatureStandardizationStDevs
                % - validate all FeatureValues are NOT standardized
                for dFeatureValuesIndex=1:dNumFeatureValues
                    if c1oFeatureValues{dFeatureValuesIndex}.IsStandardized()
                        error(...
                            'FeatureValues:Constructor:InvalidIsStandardizedForConcatenation',...
                            'FeatureValue objects cannot be standardized before concatenation.');
                    end
                end
                
                % - set values
                obj.bIsStandardized = false;
                obj.vdFeatureStandardizationMeans = [];
                obj.vdFeatureStandardizationStDevs = [];
                
                % bIsPerturbed
                % m2dPerturbationMatrix
                % - validate all FeatureValues are NOT perturbed
                for dFeatureValuesIndex=1:dNumFeatureValues
                    if c1oFeatureValues{dFeatureValuesIndex}.bIsPerturbed
                        error(...
                            'FeatureValues:Constructor:InvalidIsPerturbedForConcatenation',...
                            'FeatureValue objects cannot be perturbed before concatenation.');
                    end
                end
                
                % - set values
                obj.bIsPerturbed = false;
                obj.m2dPerturbationMatrix = [];
                                
            elseif nargin == 1 && isa(varargin{1},'double')
                % For: obj = FeatureValues(m2dUnstandardizedFeatures)
                
                m2dUnstandardizedNonDuplicatedFeatures = varargin{1};
                
                % set values           
                obj.bIsStandardized = false;
                obj.vdFeatureStandardizationMeans = [];
                obj.vdFeatureStandardizationStDevs = [];
                
                obj.bContainsDuplicatedSamples = false;
                
                obj.bIsPerturbed = false;
                obj.m2dPerturbationMatrix = [];
            else
                error(...
                    'FeatureValues:Constructor:InvalidParameters',...
                    'See constructor documentation for usage.');
            end
            
        end
    end
    
    
    methods (Access = public, Sealed = true)
        
        function vdSampleIndices = GetSampleIndicesFromGroupAndSubGroupIds(obj, viGroupIds, viSubGroupIds)
            arguments
                obj (:,:) FeatureValues {MustNotContainDuplicatedSamples(obj)}
                viGroupIds (:,1) {ValidationUtils.MustBeIntegerClass(viGroupIds)}
                viSubGroupIds (:,1) {ValidationUtils.MustBeIntegerClass(viSubGroupIds), ValidationUtils.MustBeSameSize(viGroupIds, viSubGroupIds)}
            end
            
            dNumIds = length(viGroupIds);
            
            vdSampleIndices = zeros(1,dNumIds);
            
            viCurrentGroupIds = obj.GetGroupIds();
            viCurrentSubGroupIds = obj.GetSubGroupIds();
            
            for dIdIndex=1:dNumIds
                vdGroupIdMatches = find(viCurrentGroupIds == viGroupIds(dIdIndex) & viCurrentSubGroupIds == viSubGroupIds(dIdIndex));
                
                if isscalar(vdGroupIdMatches)
                    vdSampleIndices(dIdIndex) = vdGroupIdMatches(1);
                else
                    error(...
                        'FeatureValues:GetSampleIndicesFromGroupAndSubGroupIds:NoMatchFound',...
                        ['No unique match found for Group ID ' , num2str(viGroupIds(dIdIndex)), ' and Sub-Group ID ', num2str(viSubGroupIds(dIdIndex)), '.']);
                end
            end
        end
        
        function oFeatureExtractionRecord = GetFeatureExtractionRecord(obj, dFeatureIndex)
            arguments
                obj
                dFeatureIndex (1,1) double {mustBeInteger, mustBePositive, ValidateFeatureIndexMax(obj, dFeatureIndex)}
            end
            
            voFeatureValuesToFeatureExtractionRecordLinks = obj.GetFeatureValuesToFeatureExtractionRecordLinks();
            vdLinkIndexPerFeature = obj.GetLinkIndexPerFeature();
            
            oFeatureExtractionRecord = voFeatureValuesToFeatureExtractionRecordLinks(vdLinkIndexPerFeature(dFeatureIndex)).GetFeatureExtractionRecord();
        end
        
        function [oImageVolume, dRoiNumber] = GetImageVolumeAndRegionOfInterestNumberForIndex(obj, dSampleIndex, dFeatureIndex)
            voFeatureValuesToFeatureExtractionRecordLinks = obj.GetFeatureValuesToFeatureExtractionRecordLinks();
            vdLinkIndexPerFeature = obj.GetLinkIndexPerFeature();
            
            dLinkIndex = vdLinkIndexPerFeature(dFeatureIndex);            
            oLink = voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex);
                        
            [oImageVolume, dRoiNumber] = oLink.GetImageVolumeAndRegionOfInterestNumberForSampleIndex(dSampleIndex);
        end
        
        function [oImageVolumeHandler, dExtractionIndex] = GetImageVolumeHandlerAndExtractionIndexForIndex(obj, dSampleIndex, dFeatureIndex)
            voFeatureValuesToFeatureExtractionRecordLinks = obj.GetFeatureValuesToFeatureExtractionRecordLinks();
            vdLinkIndexPerFeature = obj.GetLinkIndexPerFeature();
            
            dLinkIndex = vdLinkIndexPerFeature(dFeatureIndex);            
            oLink = voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex);
                        
            [oImageVolumeHandler, dExtractionIndex] = oLink.GetImageVolumeHandlerAndExtractionIndexForSampleIndex(dSampleIndex);
        end
        
        function [voImageVolumeHandlers, vdExtractionIndices] = GetAllImageVolumeHandlersAndExtractionIndicesForFeatureSource(obj, sFeatureSource)
            arguments
                obj
                sFeatureSource (1,1) string
            end
            
            voFeatureValuesToFeatureExtractionRecordLinks = obj.GetFeatureValuesToFeatureExtractionRecordLinks();
                        
            oLink = [];
            
            for dLinkIndex=1:length(voFeatureValuesToFeatureExtractionRecordLinks)
                if sFeatureSource == voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex).GetFeatureExtractionRecord().GetImageSource()
                    oLink = voFeatureValuesToFeatureExtractionRecordLinks(dLinkIndex);
                    break;
                end
            end
            
            if isempty(oLink)
                error(...
                    'FeatureValues:GetAllImageVolumeHandlersAndExtractionIndicesForFeatureSource:InvalidFeatureSource',...
                    ['Not matching FeatureExtractionRecord for FeatureSource "', sFeatureSource, '".']);
            end
            
            oFirstHandler = oLink.GetImageVolumeHandlerAndExtractionIndexForSampleIndex(1);
            
            dNumSamples = obj.GetNumberOfSamples();
            
            voImageVolumeHandlers = repmat(oFirstHandler, dNumSamples, 1);
            vdExtractionIndices = zeros(dNumSamples,1);
            
            for dSampleIndex=1:dNumSamples
                [oImageVolumeHandler, dExtractionIndex] = oLink.GetImageVolumeHandlerAndExtractionIndexForSampleIndex(dSampleIndex);
                
                voImageVolumeHandlers(dSampleIndex) = oImageVolumeHandler;
                vdExtractionIndices(dSampleIndex) = dExtractionIndex;
            end
        end
        
        function DisplayFeatureSourceExtractionSummary(obj)
            FeatureValuesToFeatureExtractionRecordLink.DisplayFeatureSourceExtractionSummary(...
                obj.GetFeatureValuesToFeatureExtractionRecordLinks());
        end
        
        function DisplayFeatureSourceSummaryForSamples(obj)
            FeatureValuesToFeatureExtractionRecordLink.DisplayFeatureSourceSummaryForSamples(...
                obj.GetFeatureValuesToFeatureExtractionRecordLinks(),...
                obj.GetGroupIds(), obj.GetSubGroupIds());            
        end
        
        function bContainDuplicatedSamples = ContainsDuplicatedSamples(obj)
            %bContainDuplicatedSamples = ContainsDuplicatedSamples(obj)
            %
            % SYNTAX:
            %  bContainDuplicatedSamples = obj.ContainsDuplicatedSamples()
            %
            % DESCRIPTION:
            %  Returns if the FeatureValues object contains duplicated
            %  samples (or if it did a one point). Once a FeatureValues
            %  object has been marked as contained duplicated values, this
            %  cannot not be undone. This prevents accidental invalid
            %  testing on duplicated samples.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  bContainDuplicatedSamples: True if the FeatureValues
            %                             does/has contained duplicated
            %                             samples
            
            bContainDuplicatedSamples = obj.bContainsDuplicatedSamples;
        end
        
        function m2dFeatures = GetFeatures(obj)
            %m2dFeatures = GetFeatures(obj)
            %
            % SYNTAX:
            %  m2dFeatures = obj.GetFeatures()
            %
            % DESCRIPTION:
            %  Returns the 2D feature table
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  m2dFeatures: Feature table where features run across the
            %               columns and samples run across the rows
            
            if obj.IsStandardized
                m2dFeatures = obj.GetUnstandardizedFeatures();
                vbFeatureIsCategorical = obj.IsFeatureCategorical();
                
                % only apply standarization to non-categorical features
                m2dFeatures(:, ~vbFeatureIsCategorical) = (m2dFeatures(:, ~vbFeatureIsCategorical) - obj.vdFeatureStandardizationMeans(~vbFeatureIsCategorical)) ./ obj.vdFeatureStandardizationStDevs(~vbFeatureIsCategorical);
            else
                m2dFeatures = obj.GetUnstandardizedFeatures();
            end
            
            if obj.bIsPerturbed
                m2dFeatures = m2dFeatures + obj.m2dPerturbationMatrix;
            end
            
            % check for any NaNs, Inf, -Inf (don't worry, no copying
            % happens during this check)
            if any(isnan(m2dFeatures(:)))
                error(...
                    'FeatureValues:GetFeatures:InvalidNaN',...
                    'A NaN value was detected on output.');
            end
            
            if any(isinf(m2dFeatures(:)))
                error(...
                    'FeatureValues:ValidateFeatures:InvalidInf',...
                    'An Inf value was detected on output.');
            end
        end
        
        function dNumGroups = GetNumberOfGroups(obj)
            %dNumGroups = GetNumberOfGroups(obj)
            %
            % SYNTAX:
            %   dNumGroups = obj.GetNumberOfGroups()
            %
            % DESCRIPTION:
            %  Returns the number of unique groups with the feature values
            %  object
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  dNumGroups: The number of groups
            
            dNumGroups = length(unique(obj.GetGroupIds()));
        end
        
        function bIsStandardized = IsStandardized(obj)
            %bIsStandardized = IsStandardized(obj)
            %
            % SYNTAX:
            %   bIsStandardized = obj.IsStandardized()
            %
            % DESCRIPTION:
            %  Returns the if the FeatureValues object is standardized
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  bIsStandardized: Boolean (true if standardized)
            
            bIsStandardized = obj.bIsStandardized;
        end
        
        function vdFeatureStandardizationMeans = GetFeatureStandardizationMeans(obj)
            %vdFeatureStandardizationMeans = GetFeatureStandardizationMeans(obj)
            %
            % SYNTAX:
            %   vdFeatureStandardizationMeans = obj.GetFeatureStandardizationMeans()
            %
            % DESCRIPTION:
            %  Returns the Feature Standardization Mean for each column of the
            %  featue table
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdFeatureStandardizationMeans: Double row vector (one for each column)
            
            vdFeatureStandardizationMeans = obj.vdFeatureStandardizationMeans;
        end
        
        function vdFeatureStandardizationStDevs = GetFeatureStandardizationStDevs(obj)
            %vdFeatureStandardizationStDevs = GetFeatureStandardizationStDevs(obj)
            %
            % SYNTAX:
            %   vdFeatureStandardizationStDevs = obj.GetFeatureStandardizationStDevs()
            %
            % DESCRIPTION:
            %  Returns the Feature Standardization Standard Deviation for each
            %  column of the featue table
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdFeatureStandardizationStDevs: Double row vector (one for each column)
            
            vdFeatureStandardizationStDevs = obj.vdFeatureStandardizationStDevs;
        end
        
        function obj = Standardize(obj)
            %obj = Standardize(obj)
            %
            % SYNTAX:
            %  obj = Standardize(obj)
            %
            % DESCRIPTION:
            %  Standardizes (mean = 0, variance = 1) the data in each feature
            %  column
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Class object (standardized)
            
            if ~obj.bIsStandardized
                obj.vdFeatureStandardizationMeans = mean(obj.GetUnstandardizedFeatures(),1);
                obj.vdFeatureStandardizationStDevs = std(obj.GetUnstandardizedFeatures(),0,1);
                
                % categorical features don't get standardized
                obj.vdFeatureStandardizationMeans(obj.IsFeatureCategorical()) = NaN;
                obj.vdFeatureStandardizationStDevs(obj.IsFeatureCategorical()) = NaN;
                
                if any(obj.vdFeatureStandardizationStDevs(:) == 0)
                    error(...
                        'FeatureValues:Standardize:InvalidStDev',...
                        'Cannot standardize if any features have a standard deviation of zero.');
                end
                
                obj.bIsStandardized = true;
            else
                error(...
                    'FeatureValues:Standardize:InvalidRequest',...
                    'The FeatureValues object is already standardized and cannot be standardized again');
            end
        end
        
        function obj = TransferStandardization(obj, oFeatureValues)
            % obj = TransferStandardization(obj, oFeatureValues)
            %
            % SYNTAX:
            %  obj = TransferStandardization(obj, oFeatureValues)
            %
            % DESCRIPTION:
            %  Transfer the standardization of oFeatureValues to obj. This
            %  allows for an new data set to be standardized in the same
            %  manner as a previous data set used for training/testing. obj
            %  and oFeatureValues MUST have the same feature in each and
            %  every column. oFeatureValues must also be already
            %  standardized, and obj must be un-standardized
            %
            % INPUT ARGUMENTS:
            %  obj: Class object (un-standardized)
            %  oFeatureValues: Standardized FeatureValues object            %  
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Class object (standardized)
            
            arguments
                obj
                oFeatureValues (:,:) FeatureValues
            end
            
            % validate standardization status
            if obj.IsStandardized()
                error(...
                    'FeatureValues:TransferStandardization:AlreadyStandardized',...
                    'Cannot transfer standardization values to a FeatureValues object already standardized. Use the ".Destandardize()" function first and then apply this function.');
            end
            
            if ~oFeatureValues.IsStandardized()
                error(...
                    'FeatureValues:TransferStandardization:SourceNotStandardized',...
                    'Cannot transfer standardization values to from a FeatureValues object that is not standardized. Use the ".Standardize()" function to standardize the source FeatureValues object.');
            end
            
            if ~FeatureValues.AreFeaturesEqual(obj, oFeatureValues)
                error(...
                    'FeatureValues:TransferStandardization:FeaturesNotEqual',...
                    'The features were not found to be in the same order, have the same name, or from the same source, and so transferring standardization values would be a scientific error.');
            end
            
            % transfer the standardization
            obj.vdFeatureStandardizationMeans = oFeatureValues.vdFeatureStandardizationMeans;
            obj.vdFeatureStandardizationStDevs = oFeatureValues.vdFeatureStandardizationStDevs;
            obj.bIsStandardized = true;
        end
        
        function obj = Destandardize(obj)
            %obj = Destandardize(obj)
            %
            % SYNTAX:
            %  obj = Destandardize(obj)
            %
            % DESCRIPTION:
            %  Detandardizes the data in each feature column according to the
            %  stored means and variance from when the data was originally
            %  standardized
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Class object (destandardized)
            
            if obj.bIsStandardized
                obj.vdFeatureStandardizationMeans = [];
                obj.vdFeatureStandardizationStDevs = [];
                
                obj.bIsStandardized = false;
            else
                error(...
                    'FeatureValues:Destandardize:InvalidRequest',...
                    'The FeatureValues object is already destandardized and cannot be destandardized again');
            end
        end
        
        function [obj, vsRemovedFeatures, vbRemovedFeaturesMask] = RemoveFeaturesWithZeroVariance(obj)
            %[obj, vsRemovedFeatures, vbRemovedFeaturesMask] = RemoveFeaturesWithZeroVariance(obj)
            %
            % SYNTAX:
            %   [obj, vsRemovedFeatures, vbRemovedFeaturesMask] = obj.RemoveFeaturesWithZeroVariance()
            %
            % DESCRIPTION:
            %  This method removes features that have zero variance within their values. Zero
            %  variance almost surely means that the feature is constant. The removal of such 
            %  features is very important because these features do no add useful information
            %  for machine learning, add unnecessary computation time, and cause methods that assume 
            %  a normal distribution to behave unexpectedly, auch as the MATLAB naive-bayes classifier.
            %  
            %
            % INPUT ARGUMENTS:
            %  obj: this class object
            %
            % OUTPUTS ARGUMENTS:
            %  obj: this class object with the features that have zero variance removed
            %  vsRemovedFeatures: list of the names of the features which were removed
            %  vbRemovedFeaturesMask: mask with as many columns as the
            %    original feature values object, with true values showing
            %    which features were removed
            %
            % Author: Salma 
            
            % Create a mask that starts with all features being retained
            vbRetainedFeaturesnMask = true(1, obj.GetNumberOfFeatures());
                 
            % Loop through features and check the variance within their values
            for dFeature = 1:obj.GetNumberOfFeatures()                
                
                 oCurrentFeatureValues = obj.SelectRowsAndColumns(':',dFeature);
                 vdCurrentFeatureValues = oCurrentFeatureValues.GetFeatures();                 
                 
                 % If the variance is zero, set the retention value to false for the corresponding
                 % feature
                 if var(vdCurrentFeatureValues) == 0
                    vbRetainedFeaturesnMask(dFeature) = false; 
                 end                
            end
            vbRemovedFeaturesMask = ~vbRetainedFeaturesnMask;            
            
            % Grab the list of names of features, and modify (or not) according to the different scenarios
            vsRemovedFeatures = obj.GetFeatureNames();
                
            % If the user called this function and it did nothing, let them know
            if sum(vbRemovedFeaturesMask) == 0
                warning("FeatureValues:RemoveConstantFeatures:NoneRemoved",...
                    "No constant features were found, therefore, none were removed.")
                
            
            elseif sum(vbRetainedFeaturesnMask) == 0                
                error("FeatureValues:RemoveConstantFeatures:AllRemoved",...
                    "All the features had zero variance and were all removed. This object now has no features.")
            
            elseif sum(vbRemovedFeaturesMask) ~= 0               
                % Then remove the flagged features
                obj = obj.SelectRowsAndColumns(':',find(vbRetainedFeaturesnMask));
                vsRemovedFeatures = vsRemovedFeatures(vbRemovedFeaturesMask);                
            end 
        end
        
        function dNumFeatures = GetNumberOfFeatures(obj)
            %dNumFeatures = GetNumberOfFeatures(obj)
            %
            % SYNTAX:
            %  dNumFeatures = obj.GetNumberOfFeatures()
            %
            % DESCRIPTION:
            %  Returns the number of features
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  dNumFeatures: The number of features (columns)
            
            dNumFeatures = size(obj,2);
        end
        
        function dNumSamples = GetNumberOfSamples(obj)
            %dNumSamples = GetNumberOfSamples(obj)
            %
            % SYNTAX:
            %  dNumSamples = obj.GetNumberOfSamples()
            %
            % DESCRIPTION:
            %  Returns the number of samples
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  dNumSamples: The number of samples (rows)
            
            dNumSamples = size(obj,1);
        end
    end
    
    
    methods (Access = public)
        
        
        % >>>>>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj)
            %
            % DESCRIPTION:
            %  displays FeatureValues as a column of Group IDs, column of
            %  Sub Group Ids, and then the feature table with Feature Name
            %  headings
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            
            % print headings
            obj.GetSampleIds().PrintHeaders();
            obj.PrintFeatureHeaders();
            fprintf(newline);
            
            % print rows
            obj.PrintRowsForDisp();
            
            % print footer for duplicate samples and feature sources
            obj.PrintFooterForDisp();
            
        end
        
        function varargout = subsref(obj, stSelection)
            %varargout = subsref(obj, stSelection)
            %
            % SYNTAX:
            %  varargout = subsref(obj, stSelection)
            %
            % DESCRIPTION:
            %  Overloading subsref to allow selections (e.g. a(1:3,4)) to
            %  be made on FeatureValue objects. While most of the heavy
            %  lifting is left to the sub-class, this function checks that
            %  now row or column duplication is happening through
            %  selection, only sub-selection. To duplicate rows, see
            %  specific functionality of sub-classes.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  stSelection: Selection struct. Refer to Matlab documentation
            %               on "subsef"
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Class object
                        
            varargout = {obj};
            
            % sub-class specific
%             if strcmp(stSelection(1).type, '()')
%                 for dDimIndex=1:length(stSelection(1).subs)                
%                     if ~strcmp(stSelection(1).subs{dDimIndex}, ':') &&...
%                             ~islogical(stSelection(1).subs{dDimIndex}) && ...
%                             length(stSelection(1).subs{dDimIndex}) ~= length(unique(stSelection(1).subs{dDimIndex}))
%                         
%                         error(...
%                             'FeatureValues:subsref:NonUniqueSelection',...
%                             'When selecting rows or columns from a FeatureValues object, the select indices for each dimension must be unique. Use the provided balancing functionality to insert duplicate values.');
%                     end
%                 end
%             end
        end
        
        function newObj = Label(obj, oSampleLabels)
            %newObj = Label(obj, oSampleLabels)
            %
            % SYNTAX:
            %  newObj = Label(obj, oSampleLabels)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: FeatureValues object
            %  oSampleLabels: SampleLabels object
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: 
            
            newObj = LabelledFeatureValues(obj, oSampleLabels);
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        function oSampleIds = GetSampleIds(obj)
            %oSampleIds = GetSampleIds(obj)
            %
            % SYNTAX:
            %  oSampleIds = obj.GetSampleIds()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oSampleIds = obj.oSampleIds;
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
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oRecord = FeatureValuesRecordForModel(obj);
        end
    end
    
    
    methods (Access = public, Static = true)
        function bBool = AreFeaturesEqual(oFeatureValues1, oFeatureValues2)
            %bBool = AreFeaturesEqual(oFeatureValues1, oFeatureValues2)
            %
            % SYNTAX:
            %  bBool = FeatureValues.AreFeaturesEqual(oFeatureValues1, oFeatureValues2)
            %
            % DESCRIPTION:
            %  Returns true if the features in each of the FeatureValue
            %  objects are equal. This does NOT mean that the objects are
            %  equal or that the values of each feature/sample are equal.
            %  Rather, it means that each feature/column has the same name,
            %  comes from the same source/feature extraction version,
            %  appears in the same order from left to right, and is marked
            %  as categorical or not.
            %  The FeatureValue objects do NOT need to both be standardized or
            %  un-standardized for their features to be considered equal
            %
            % INPUT ARGUMENTS:
            %  oFeatureValues1: Class object
            %  oFeatureValues2: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  bBool: true if features are equal, false otherwise
            
            
            arguments
                oFeatureValues1 (:,:) FeatureValues
                oFeatureValues2 (:,:) FeatureValues
            end
            
            bBool = true;
            
            if oFeatureValues1.GetNumberOfFeatures() ~= oFeatureValues2.GetNumberOfFeatures()
                bBool = false;
            else
                dNumFeatures = oFeatureValues1.GetNumberOfFeatures();
                
                vsFeatureNames1 = oFeatureValues1.GetFeatureNames();
                vsFeatureNames2 = oFeatureValues2.GetFeatureNames();
                
                if any(vsFeatureNames1 ~= vsFeatureNames2)
                    bBool = false;
                elseif any(oFeatureValues1.IsFeatureCategorical() ~= oFeatureValues2.IsFeatureCategorical())
                    bBool = false;
                else
                    for dFeatureIndex=1:dNumFeatures                        
                        % check feature sources are equal
                        oExtractionRecord1 = oFeatureValues1.GetFeatureExtractionRecord(dFeatureIndex);
                        oExtractionRecord2 = oFeatureValues2.GetFeatureExtractionRecord(dFeatureIndex);
                        
                        if ~strcmp(oExtractionRecord1.GetUuid(), oExtractionRecord2.GetUuid())
                            bBool = false;
                            break;
                        end
                    end
                end
            end
        end
    end
    
        
        
   
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract = true)
              
        m2dFeatures = GetFeaturesForDisp(obj)
        
        m2dFeatures = GetUnstandardizedFeatures(obj)
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
        
        vbIsDuplicatedSample = GetIsDuplicatedSample(obj)
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
    end
    
    
    methods (Access = {?FeatureValues, ?FeatureValuesOnDiskIdentifier}, Abstract = true)
        % Only accessible to sub-classes and the FeatureValuesIdentifier class
        
        m2dFeatures = GetNonDuplicatedUnstandardizedFeatures(obj)
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
        
        viGroupIds = GetNonDuplicatedGroupIds(obj)
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
        
        viSubGroupIds = GetNonDuplicatedSubGroupIds(obj)
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
        
        vsUserDefinedSampleStrings = GetNonDuplicatedUserDefinedSampleStrings(obj)
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
                
        vdRowSelection = GetRowSelectionForNonDuplicatedProperties(obj)
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
    end
        
    
    methods (Access = protected, Abstract = false)
        
        function MustBeValidRowAndColumnSelections(obj, vdRowSelection, vdColSelection)
            arguments
                obj
                vdRowSelection (1,:) double {mustBeInteger, mustBePositive}
                vdColSelection (1,:) double {mustBeInteger, mustBePositive}
            end
            
            mustBeLessThanOrEqual(vdRowSelection, GetNumberOfSamples(obj));
            mustBeLessThanOrEqual(vdColSelection, GetNumberOfFeatures(obj));
                        
            % col check
            if length(unique(vdColSelection)) ~= length(vdColSelection)
                error(...
                    'FeatureValues:MustBeValidRowAndColumnSelections:InvalidColumnSelection',...
                    'When creating a new FeatureValues object from an existing FeatureValues object, the column selection must contain only unique values.');
            end
        end
        
        function newObj = SelectRowsAndColumns(obj, vdRowSelection, vdColSelection)
            stSelection = struct(...
                'type', '()',...
                'subs', {{vdRowSelection, vdColSelection}});
            
            newObj = obj.subsref(stSelection);
        end
        
        function PrintFeatureHeaders(obj)
            %PrintFeatureHeaders(obj)
            %
            % SYNTAX:
            %  PrintFeatureHeaders(obj)
            %
            % DESCRIPTION:
            %  function to define and print header columns displaying the
            %  feature names for each feature
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            vsFeatureNames = obj.GetFeatureNames();
            vdLinkIndices = obj.GetLinkIndexPerFeature();
            
            for dFeatureIndex=1:length(vsFeatureNames)
                vsFeatureNames(dFeatureIndex) = strcat(...
                    num2str(vdLinkIndices(dFeatureIndex)), ":",...
                    vsFeatureNames(dFeatureIndex));
            end
            
            c1chDispFeatureHeaderValues = {vsFeatureNames};
            chDispFeatureHeaderFormat = repmat('%17s ',1,obj.GetNumberOfFeatures());            

            fprintf(chDispFeatureHeaderFormat, c1chDispFeatureHeaderValues{:});
        end
        
        
        function chFeatureRowFormat = GetFeatureRowFormatForDisp(obj)
            %chFeatureRowFormat = GetFeatureRowFormatForDisp(obj)
            %
            % SYNTAX:
            %  chFeatureRowFormat = GetFeatureRowFormatForDisp(obj)
            %
            % DESCRIPTION:
            %  Function to define the format for each sample row of
            %  feature values used in the fprintf function
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  chFeatureRowFormat: character array defining format for
            %       each row of the feature display
            
            chFeatureRowFormat = repmat('%17.2f ',1,obj.GetNumberOfFeatures());
        end
        
        function c1chFeatureRowValues = GetFeatureRowValuesForDisp(obj, dSampleIndex, m2dFeatures)
            %c1chFeatureRowValues = GetFeatureRowValuesForDisp(obj, dSampleIndex, m2dFeatures)
            %
            % SYNTAX:
            %  c1chFeatureRowValues = GetFeatureRowValuesForDisp(obj, dSampleIndex, m2dFeatures)
            %
            % DESCRIPTION:
            %  Function to collect the feature values for one sample row to be
            %  to be used in the disp function when printing the features.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  dSampleIndex: value of type double holding the index to the
            %       sample row to display.
            %  m2dFeatures:  2D matrix of double values holding the
            %       features for the sample row to display
            %
            % OUTPUTS ARGUMENTS:
            %  c1chFeatureRowValues: cell array holding the feature values
            %       to be displayed for the sample row 
            
            c1chFeatureRowValues = { m2dFeatures(dSampleIndex,:)};
        end
        
        function PrintRowsForDisp(obj)
            %PrintRowsForDisp(obj)
            %
            % SYNTAX:
            %  PrintRowsForDisp(obj)
            %
            % DESCRIPTION:
            %  Function to coordinate printing each sample row which
            %  consists of the sample id properties followed by the
            %  features.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            m2dFeatures = obj.GetFeatures();
            chFeatureRowFormat = obj.GetFeatureRowFormatForDisp();
            
            % print line by line of Index #/Group ID/Sub Group ID/Feature Values
            for dSampleIndex=1:obj.GetNumberOfSamples()
                obj.GetSampleIds().PrintRowForSample(dSampleIndex);
                c1chFeatureRowValues = obj.GetFeatureRowValuesForDisp(dSampleIndex,m2dFeatures);
                
                fprintf(chFeatureRowFormat, c1chFeatureRowValues{:});
                fprintf(newline);
            end
        end
        
        function PrintFooterForDisp(obj)
            %PrintFooterForDisp(obj)
            %
            % SYNTAX:
            %  PrintFooterForDisp(obj)
            %
            % DESCRIPTION:
            %  Function to coordinate printing the footer which includes
            %  the legend for the duplicate samples indicator and the links
            %  to the source for each of the features.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            % print legend for duplicate samples if needed           
            if obj.ContainsDuplicatedSamples()
                fprintf(newline);
                fprintf('* - Duplicated Samples');
                fprintf(newline);
            end
            
            % print feature sources
            fprintf(newline);            
            fprintf('Feature Sources:');
            fprintf(newline);
            
            voLinks = obj.GetFeatureValuesToFeatureExtractionRecordLinks();
            
            for dLinkIndex=1:length(voLinks)
                oRecord = voLinks(dLinkIndex).GetFeatureExtractionRecord();
                
                fprintf(strcat(" ", num2str(dLinkIndex), ": ", oRecord.GetImageSource(), " [UUID: ", oRecord.GetUuid(), "]"));
                fprintf(newline);
            end
        end
        
        function ValidateFeatureIndexMax(obj, dFeatureIndex)
            if dFeatureIndex > obj.GetNumberOfFeatures()
                error(...
                    'FeatureValues:ValidateFeatureIndexMax:Invalid',...
                    'dFeatureIndex must be less than or equal to the number of features.');
            end
        end
        
        function sStr = GetMultiModalityDataSetDispSummaryString(obj)
            sStr = "Image Source: " + obj.GetImageSource();
        end
        
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
                
        function MustNotContainDuplicatedSamples(obj)
            if obj.ContainsDuplicatedSamples()
                error(...
                    'FeatureValues:MustNotContainDuplicatedSamples:Invalid',...
                    'The FeatureValues object may not contain duplicated samples.');
            end
        end
    end
    
    
    methods (Access = private, Static = true)
        
    end
      
    methods (Access = {?Classifier, ?FeatureValues}, Static = false)
        
        function obj = PerturbeValuesByMinisculeAmount(obj, dSizeOfMinisculeAmount)
        %  dSizeOfMinisuleAmount: e.g. 1/1000, 10^-10, 0.003
        
        % Multiply by 10 because rand already returns 0.XXX values
        obj.m2dPerturbationMatrix = rand( obj.GetNumberOfSamples() , obj.GetNumberOfFeatures ) * dSizeOfMinisculeAmount * 10;
        obj.bIsPerturbed = true;
        
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

