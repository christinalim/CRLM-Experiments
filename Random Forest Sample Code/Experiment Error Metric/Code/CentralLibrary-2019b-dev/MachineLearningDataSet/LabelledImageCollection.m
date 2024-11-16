classdef LabelledImageCollection < ImageCollection & LabelledMachineLearningDataSet
    %ImageCollection
    %
    % Joins up ImageVolume objects with SampleIds and SampleLabels
    
    % Primary Author: David DeVries
    % Created: June 4, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)        
        oSampleLabels (:,1) SampleLabels = BinaryClassificationSampleLabels(SampleIds(int8(1), int8(1), ""),int8(1),int8(1),int8(0)) % TODO figure out BinaryClassifcationSampleLabels.empty
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = LabelledImageCollection(varargin)
            %obj = LabelledImageCollection(varargin)
            %
            % SYNTAX:
            %  obj = LabelledImageCollection(voLabelledImageVolumeWithSampleIds)
            %  obj = LabelledImageCollection(obj, vdRowSelection)
            %  obj = LabelledImageCollection(obj, oSampleLabels)
            %
            % DESCRIPTION:
            %  Constructor for LabelledImageCollection
            %
            % INPUT ARGUMENTS:
            %  voLabelledImageVolumeWithSampleIds: TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
           
            if nargin == 1
                % For:
                %  obj = LabelledImageCollection(voLabelledImageVolumeWithSampleIds)
                
                voLabelledImageVolumeWithSampleIds = varargin{1};
                
                ValidationUtils.MustBeA(voLabelledImageVolumeWithSampleIds, 'LabelledImageVolumeWithSampleIds');
                ValidationUtils.MustBeRowVector(voLabelledImageVolumeWithSampleIds);
                
                % get sample IDs across all ImageVolumeWithSampleIds objects
                oSampleLabels = LabelledImageVolumeWithSampleIds.GetSampleLabelsForAll(voLabelledImageVolumeWithSampleIds);
                
                % prepare inputs for super-class constructors
                vararginForImageCollectionConstructor = varargin;                
            
            elseif nargin == 2 && isa(varargin{2}, 'SampleLabels')
                % For:
                %  obj = LabelledImageCollection(obj, oSampleLabels)
                
                objCurrent = varargin{1};
                oSampleLabels = varargin{2};
                
                ValidationUtils.MustBeA(objCurrent, 'ImageCollection');
                
                ValidationUtils.MustBeA(oSampleLabels, 'SampleLabels');
                                
                SampleIds.MustBeEqual(objCurrent.GetSampleIds(), oSampleLabels.GetSampleIds());
                
                % prepare inputs for super-class constructors
                vararginForImageCollectionConstructor = {objCurrent};
                
            elseif nargin == 2
                % For:
                %  obj = LabelledImageCollection(objCurrent, vdRowSelection)
                
                objCurrent = varargin{1};
                vdRowSelection = varargin{2};
                
                ValidationUtils.MustBeA(objCurrent, 'LabelledImageCollection');
                
                ValidationUtils.MustBeA(vdRowSelection, 'double');
                mustBeInteger(vdRowSelection);
                mustBePositive(vdRowSelection);
                
                if max(vdRowSelection) > objCurrent.GetNumberOfSamples()
                    error(...
                        'LabelledImageCollection:Constructor:InvalidRowSelection',...
                        'The row selection indices must not exceed the number of samples.');
                end
                
                
                oSampleLabels = objCurrent.oSampleLabels(vdRowSelection);
                
                % prepare inputs for super-class constructors
                vararginForImageCollectionConstructor = varargin; 
            else
                error(...
                    'LabelledImageCollection:Constructor:InvalidNumberOfArguments',...
                    'See constructor documentation for more details.');
            end
            
            % super-class constructor
            obj@ImageCollection(vararginForImageCollectionConstructor{:});
            
            % local constructor
            obj.oSampleLabels = oSampleLabels;
        end      
                
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        function oSampleLabels = GetSampleLabels(obj)
            %oSampleLabels = GetSampleLabels(obj)
            %
            % SYNTAX:
            %  oSampleLabels = obj.GetSampleLabels()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: LabelledImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oSampleLabels = obj.oSampleLabels;
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
            %  obj: LabelledImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oRecord = LabelledImageCollectionRecordForModel(obj);
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj)
            %
            % DESCRIPTION:
            %  Displays a LabelledImageCollection
            %
            % INPUT ARGUMENTS:
            %  obj: LabelledImageCollection object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            % Headers
            obj.GetSampleIds().PrintHeaders();
            obj.GetSampleLabels().PrintHeaders();
            obj.PrintHeaders();
            
            fprintf(newline);
            
            % Print row by row
            for dSampleIndex=1:obj.GetNumberOfSamples()
                obj.GetSampleIds().PrintRowForSample(dSampleIndex);
                obj.GetSampleLabels().PrintRowForSample(dSampleIndex);
                obj.PrintRowForSample(dSampleIndex);
                
                fprintf(newline);
            end     
            
            fprintf(newline);
            obj.PrintFooter();
            fprintf(newline);
            
            obj.GetSampleIds().PrintFooter();
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
            %  varargout: If is was a selection, a LabelledImageCollection object
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
                    varargout{1} = LabelledImageCollection(obj, varargout{1}.GetRowSelection());
                otherwise
                    [varargout{1:nargout}] = subsref@MatrixContainer(obj, stSelection);
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MISC <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function objBalanced = BalanceLabels(obj, NameValueArgs)
            arguments
                obj (:,1) LabelledImageCollection {MustNotContainDuplicatedSamples(obj)}
                NameValueArgs.SuppressWarnings (1,1) logical
            end
            
            varargin = namedargs2cell(NameValueArgs);
            vdRowSelectionIndicesToBalance = obj.oSampleLabels.GetRowSelectionIndicesToBalanceLabels(varargin{:});
            
            objBalanced = LabelledImageCollection(obj, vdRowSelectionIndicesToBalance);
        end
        
        function MustNotContainDuplicatedSamples(obj)
            if obj.GetSampleIds().ContainsDuplicatedSamples()
                error(...
                    'LabelledImageCollection:MustNotContainDuplicatedSamples:Invalid',...
                    'The LabelledImageCollection object must not contain duplicated samples.');
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

