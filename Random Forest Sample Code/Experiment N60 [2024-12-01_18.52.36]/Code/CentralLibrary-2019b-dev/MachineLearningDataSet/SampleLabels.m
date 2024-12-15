classdef (Abstract) SampleLabels < MatrixContainer
    %SampleLabels
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 4, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
                       
    properties (SetAccess = immutable, GetAccess = public)
        sLabelsSource (1,1) string = ""
        oSampleIds (:,1) SampleIds = SampleIds(0,0)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
        oRecord = GetRecordForModel(obj)
        
        PrintClassesFooter(obj)
        
    end
    
    methods (Access = public, Static = false)
        
        function obj = SampleLabels(oSampleIds, m2xLabels, sLabelsSource)
            %obj = SampleLabels(oSampleIds, m2xLabels, sLabelsSource)
            %
            % SYNTAX:
            %  obj = SampleLabels(oSampleIds, m2xLabels, sLabelsSource)
            %
            % DESCRIPTION:
            %  Constructor for SampleLabels
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
               
            arguments
                oSampleIds (:,1) SampleIds
                m2xLabels (:,:) {mustBeNumericOrLogical, ValidationUtils.MustBeSameSize(oSampleIds, m2xLabels)}
                sLabelsSource (1,1) string = ""
            end
            
            % super-class constructor
            obj@MatrixContainer(m2xLabels)
            
            % set properities
            obj.oSampleIds = oSampleIds;
            obj.sLabelsSource = sLabelsSource;
        end      
        
        
        % >>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
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
            %  obj: SampleLabels obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            dNumSamples = length(obj); % used overloaded length function
        end
        
        function sLabelsSource = GetLabelsSource(obj)
            %sLabelsSource = GetLabelsSource(obj)
            %
            % SYNTAX:
            %  sLabelsSource = obj.GetLabelsSource()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: SampleLabels obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            sLabelsSource = obj.sLabelsSource;
        end
        
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
            %  obj: SampleLabels obj
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oSampleIds = obj.oSampleIds;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>> OVERLOADED <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj)
            %
            % DESCRIPTION:
            %  Function to coordinate printing the header, rows and footer
            %  for the SampleLabels object.
            %
            % INPUT ARGUMENTS:
            %  obj: SampleLabels object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            % Headers
            obj.GetSampleIds().PrintHeaders();
            obj.PrintHeaders();
            
            fprintf(newline);
            
            % Print row by row
            for dSampleIndex=1:obj.GetNumberOfSamples()
                obj.GetSampleIds().PrintRowForSample(dSampleIndex);
                obj.PrintRowForSample(dSampleIndex);
                
                fprintf(newline);
            end     
            
            obj.GetSampleIds().PrintFooter();
            
            % print classes
            fprintf(newline);
            fprintf('Classes:');
            fprintf(newline);
            obj.PrintClassesFooter();
        end
        
        function PrintHeaders(obj)
            %PrintHeaders(obj)
            %
            % SYNTAX:
            %  PrintHeaders(obj)
            %
            % DESCRIPTION:
            %  Function to define and print header column for the labels.
            %  This column is concatenated after the display of headers
            %   for the sample ids.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            fprintf(' %5s |', 'Label');
        end
        
        function PrintRowForSample(obj, dSampleIndex)
            %PrintRowForSample(obj, dSampleIndex)
            %
            % SYNTAX:
            %  PrintRowForSample(obj, dSampleIndex)
            %
            % DESCRIPTION:
            %  Function to coordinate printing each sample row defined by
            %  the index given. The row consists of the value of the label
            %  for the row.
            %  This column is concatenated after the display of the row
            %   for the sample ids.
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  dSampleIndex: an integer of type double that represents the
            %    row to be printed.
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            fprintf(' %5i |', obj.viLabels(dSampleIndex));
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

