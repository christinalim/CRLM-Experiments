classdef ImageVolumeWithSampleIds < matlab.mixin.Copyable
    %ImageVolumeWithSampleIds
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Jun 4, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        oRASImageVolume ImageVolume {ValidationUtils.MustBeEmptyOrScalar} = MATLABImageVolume.empty
                
        oRegionsOfInterestRepresentativeFieldsOfView = []        
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)
        vdSampleOrderRegionOfInterestNumbers (1,:) double {mustBeInteger, mustBePositive}
              
        sImageSource (1,1) string
        
        oSampleIds (1,:) SampleIds 
    end
    
    
    properties (Constant = true, GetAccess = public)
        dMisalignmentFromTargetUnifiedImageVolumeGeometryErrorLimit_deg (1,1) double {mustBePositive, mustBeFinite} = 20
        
        % this ImageVolumeGeometry is the target geometry that all volumes
        % are transformed onto. This allows for all volumes to be aligned
        % in the same way, allowing for easier display, as well as
        % alignment of all feature calculations offset with respect to
        % patient anatomy. This target geometry aligns with the RAS (+x:
        % right, +y: anterior, +z: superier) coordinate system of 
        % BOLT, that is, matrix coordinate axes i = +x = right, j
        % = +y = anterior, k = +z = superior, where a matrix is indexed as
        % m3xMatrix(x,y,z)
        oTargetUnifiedImageVolumeGeometry (1,1) ImageVolumeGeometry = ImageVolumeGeometry.GetRASImageVolumeGeometry();
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ImageVolumeWithSampleIds(oImageVolume, sImageSource, oSampleIds, NameValueArgs)
            %obj = ImageVolumeWithSampleIds(oImageVolume, sImageSource, oSampleIds, NameValueArgs)
            %
            % SYNTAX:
            %  obj = ImageVolumeWithSampleIds(oImageVolume, sImageSource, oSampleIds)
            %  obj = ImageVolumeWithSampleIds(oImageVolume, sImageSource, oSampleIds, NameValueArgs)
            %
            % DESCRIPTION:
            %  Constructor for ImageVolumeWithSampleIds
            %
            % INPUT ARGUMENTS:
            %  oImageVolume: object of type ImageVolume
            %  sImageSource: string describing the source of the
            %       ImageVolume object
            %  oSampleIds: object of type SampleIds
            %
            %  Name-Value Pairs:
            % 'SampleOrder': (Optional) This is a vector of Region of
            %                    Interest numbers (see "RegionsOfInterest")
            %                    that specify in which order the regions of
            %                    interest will have their features
            %                    extracted. This also allows for ROIs
            %                    within the ImageVolume to be excluded from
            %                    having features extracted. **NOTE** This
            %                    vector also determines with
            %                    Group/Sub-Group IDs are linked up with
            %                    each sample. E.g if 'SampleOrder' =
            %                    [4,3,1] and 'GroupIds' = [6,7,8], then ROI
            %                    #4 in the ImageVolume object will be
            %                    assigned Group ID 6, ROI #3 will be ID 7,
            %                    and ROI #1 will be ID 8. ROI #2 will not
            %                    be processed.
            %                    If this value is not specified, the
            %                    default behaviour will be to extract
            %                    features for all ROIs within
            % 'SetRepresentativeFieldsOfView': (Optional) Values:
            %                    true/false
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                oImageVolume (1,1) ImageVolume {MustHaveRegionsOfInterest(oImageVolume)}
                sImageSource (1,1) string {mustBeNonempty}
                oSampleIds (:,1) SampleIds
                NameValueArgs.SampleOrder (:,1) double = []
                NameValueArgs.SetRepresentativeFieldsOfView (1,1) logical = true
            end
                                    
            vdSampleOrder = NameValueArgs.SampleOrder;

            % Validation and setting of empty values            
            oImageVolume = copy(oImageVolume);
            oImageVolume.ReassignFirstVoxelToAlignWithRASCoordinateSystem();
            
            ImageVolumeWithSampleIds.ValidateRASImageVolume(oImageVolume);
            ImageVolumeWithSampleIds.ValidateSampleOrderRegionOfInterestNumbers(vdSampleOrder, oImageVolume);
            
            if isempty(vdSampleOrder)
                dNumRois = oImageVolume.GetNumberOfRegionsOfInterest();
            else
                dNumRois = length(vdSampleOrder);
            end 
            
            % Set Properities
            
            obj.oRASImageVolume = oImageVolume;
            obj.vdSampleOrderRegionOfInterestNumbers = vdSampleOrder;
                        
            obj.sImageSource = sImageSource;            
            obj.oSampleIds = oSampleIds;
            
            if length(obj.oSampleIds) ~= dNumRois
                error(...
                    'ImageVolumeWithSampleIds:Constructor:InvalidSampleIds',...
                    'The number of samples must match the number of ROIs to be used.');
            end
            
            if isa(oImageVolume.GetRegionsOfInterest(), 'LabelMapRegionsOfInterest')
                if NameValueArgs.SetRepresentativeFieldsOfView
                    bWasVolumeDataLoaded = oImageVolume.IsVolumeDataLoaded();

                    if isempty(vdSampleOrder)
                        vdSampleOrder = 1:obj.oRASImageVolume.GetNumberOfRegionsOfInterest();
                    end

                    obj.oRegionsOfInterestRepresentativeFieldsOfView = LabelMapRegionsOfInterestFieldsOfView(oImageVolume, vdSampleOrder);
                
                    if ~bWasVolumeDataLoaded
                        obj.oRASImageVolume.UnloadVolumeData();
                    end
                end
            elseif isa(oImageVolume.GetRegionsOfInterest(), 'ParametricRegionsOfInterest')
                obj.oRegionsOfInterestRepresentativeFieldsOfView = ParametricRegionsOfInterestFieldsOfView(oImageVolume, vdSampleOrder);
            else
                error(...
                    'ImageVolumeWithSampleIds:Constructor:InvalidRegionsOfInterestType',...
                    'The regions of interest objects within oImageVolume must of type "LabelMapRegionsOfInterest" of "ParametricRegionsOfInterest".');
            end
                
        end
        
        function SetImageDataDisplayThresholdForAllRepresentativeFieldsOfView(obj, vdDisplayThreshold)
            obj.oRegionsOfInterestRepresentativeFieldsOfView.SetImageDataDisplayThresholdForAllRepresentativeFieldsOfView(vdDisplayThreshold);
        end
        
        function LoadVolumeData(obj)
            obj.oRASImageVolume.LoadVolumeData();
        end
        
        function oSampleIds = GetSampleIds(obj)
            oSampleIds = obj.oSampleIds;
        end
        
        function UnloadVolumeData(obj)
            obj.oRASImageVolume.UnloadVolumeData();
        end
        
        function MustBeValidExtractionIndex(obj, dExtractionIndex)
            arguments
                obj (1,1) ImageVolumeWithSampleIds
                dExtractionIndex (1,1) double {mustBePositive, mustBeInteger}
            end
            
            if dExtractionIndex > obj.GetNumberOfRegionsOfInterest()
                error(...
                    'ImageVolumeWithSampleIds:MustBeValidExtractionIndex:Invalid',...
                    'The extraction index must not be greater than the number of regions of interest within the ImageVolumeWithSampleIds.');
            end
        end
        
        function SetMatFilePathOfRASImageVolume(obj, chNewMatFilePath)
            arguments
                obj (1,1) ImageVolumeWithSampleIds
                chNewMatFilePath (1,:) char
            end
            
            obj.oRASImageVolume.SetMatFilePath(chNewMatFilePath);
        end
        
        function SetMatFilePathOfRASRegionsOfInterest(obj, chNewMatFilePath)
            arguments
                obj (1,1) ImageVolumeWithSampleIds
                chNewMatFilePath (1,:) char
            end
            
            obj.oRASImageVolume.GetRegionsOfInterest().SetMatFilePath(chNewMatFilePath);
        end
        
        function RenderRepresentativeImageOnAxesByExtractionIndex(obj, hAxes, dExtractionIndex, NameValueArgs)
            arguments
                obj (1,1) ImageVolumeWithSampleIds
                hAxes (1,1) {ValidationUtils.MustBeAxes}
                dExtractionIndex (1,1) double {MustBeValidExtractionIndex(obj, dExtractionIndex)}
                NameValueArgs.ForceImagingPlaneType ImagingPlaneTypes {ValidationUtils.MustBeEmptyOrScalar} = ImagingPlaneTypes.empty
                NameValueArgs.ShowAllRegionsOfInterest (1,1) logical = true
                NameValueArgs.LineWidth (1,1) double {mustBePositive} = 1
                NameValueArgs.RegionOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [1 0 0] % red
                NameValueArgs.OtherRegionsOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [0 0.4 1] % blue 
                NameValueArgs.SetImageDataDisplayThreshold (1,2) double {mustBeFinite, ValidationUtils.MustBeIncreasing}
            end
            
            oImagePlaneAxes = ImagingPlaneAxes(hAxes);
            
            chCurUnits = hAxes.Units;
            
            hAxes.Units = 'pixels';
            
            vdPosition = hAxes.Position;
            
            oFov = ImageVolumeFieldOfView2D([0 0], vdPosition(4), vdPosition(3));
            oImagePlaneAxes.SetFieldOfView(oFov);
            
            hAxes.Units = chCurUnits;
            
            
            
            if isempty(obj.oRegionsOfInterestRepresentativeFieldsOfView) % hasn't been set yet, so default it
                obj.oRegionsOfInterestRepresentativeFieldsOfView = LabelMapRegionsOfInterestFieldsOfView(obj.oRASImageVolume, obj.vdSampleOrderRegionOfInterestNumbers);
            end
            
            if isfield(NameValueArgs, 'SetImageDataDisplayThreshold')
                obj.SetImageDataDisplayThresholdForAllRepresentativeFieldsOfView(NameValueArgs.SetImageDataDisplayThreshold);
                NameValueArgs = rmfield(NameValueArgs, 'SetImageDataDisplayThreshold');
            end
            
            varargin = namedargs2cell(NameValueArgs);
            
            obj.oRegionsOfInterestRepresentativeFieldsOfView.RenderFieldOfViewOnAxesByExtractionIndex(...
                oImagePlaneAxes, dExtractionIndex,...
                varargin{:});
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function oRASImageVolume = GetRASImageVolume(obj)
            oRASImageVolume = obj.oRASImageVolume;
        end
        
        function sImageSource = GetImageSource(obj)
            sImageSource = obj.sImageSource;
        end
        
        
        % >>>>>>>>>>>>>>>>>> REGIONS OF INTERESTS (ROIs) <<<<<<<<<<<<<<<<<<
        
        function dRoiNumber = GetRegionOfInterestNumberFromExtractionIndex(obj, dRegionOfInterestExtractionIndex)
            arguments
                obj (1,1) ImageVolumeWithSampleIds
                dRegionOfInterestExtractionIndex (1,1) double {MustBeValidSampleIndex(obj, dRegionOfInterestExtractionIndex)}
            end
            
            if isempty(obj.vdSampleOrderRegionOfInterestNumbers)
                dRoiNumber = dRegionOfInterestExtractionIndex;
            else
                dRoiNumber = obj.vdSampleOrderRegionOfInterestNumbers(dRegionOfInterestExtractionIndex);
            end
        end
        
        function vdRoiNumbers = GetRegionOfInterestNumbersInSampleOrder(obj)
            if isempty(obj.vdSampleOrderRegionOfInterestNumbers)
                vdRoiNumbers = transpose(1:obj.oRASImageVolume.GetNumberOfRegionsOfInterest());
            else
                vdRoiNumbers = obj.vdSampleOrderRegionOfInterestNumbers;
            end
        end
        
        function oFieldOfView3D = GetRepresentativeFieldsOfViewForExtractionIndex(obj, dExtractionIndex)
            oFieldOfView3D = obj.oRegionsOfInterestRepresentativeFieldsOfView.GetFieldOfViewByExtractionIndex(dExtractionIndex);
        end
        
        function SetRepresentativeFieldsOfViewForExtractionIndex(obj, dExtractionIndex, oFieldOfView3D)
            obj.oRegionsOfInterestRepresentativeFieldsOfView.SetFieldOfViewByExtractionIndex(dExtractionIndex, oFieldOfView3D);
        end
               
        function dNumRegionsOfInterest = GetNumberOfRegionsOfInterest(obj)
            if isempty(obj.vdSampleOrderRegionOfInterestNumbers)
                dNumRegionsOfInterest = obj.oRASImageVolume.GetNumberOfRegionsOfInterest();
            else
                dNumRegionsOfInterest = length(obj.vdSampleOrderRegionOfInterestNumbers);
            end
        end
        
        function vdSampleOrder = GetSampleOrder(obj)
            dTotalNumRois = obj.oRASImageVolume.GetNumberOfRegionsOfInterest();
            
            if isempty(obj.vdSampleOrderRegionOfInterestNumbers)
                vdSampleOrder = 1:dTotalNumRois;
            else
                vdSampleOrder = 1:dTotalNumRois;
                vdSampleOrder = vdSampleOrder(obj.vdSampleOrderRegionOfInterestNumbers);
            end
        end
        
        function viGroupIds = GetRegionsOfInterestGroupIds(obj)
            viGroupIds = obj.oSampleIds.viGroupIds;
        end
        
        function viSubGroupIds = GetRegionsOfInterestSubGroupIds(obj)
            viSubGroupIds = obj.oSampleIds.viSubGroupIds;
        end
        
        function vsUserDefinedSampleStrings = GetRegionsOfInterestUserDefinedSampleStrings(obj)
            vsUserDefinedSampleStrings = obj.oSampleIds.vsUserDefinedSampleStrings;
        end
        
        function sUserDefinedSampleString = GetUserDefinedSampleStringByExtractionIndex(obj, dExtractionIndex)
            sUserDefinedSampleString = obj.oSampleIds.vsUserDefinedSampleStrings(dExtractionIndex);
        end
        
        function m3xImageData = GetFullImageData(obj)
            m3xImageData = obj.oRASImageVolume.GetImageData();
        end
    end
    
    
    methods (Access = public, Static = true)
         
        function oSampleIds = GetSampleIdsForAll(voImageVolumeWithSampleIds)
            arguments
                voImageVolumeWithSampleIds (1,:) ImageVolumeWithSampleIds
            end
            
            dNumHandlers = length(voImageVolumeWithSampleIds);
            c1oSampleIdsPerHandler = cell(1, dNumHandlers);
            
            sMasterImageSource = voImageVolumeWithSampleIds(1).sImageSource;
            
            for dHandlerIndex=1:dNumHandlers
                if sMasterImageSource ~= voImageVolumeWithSampleIds(dHandlerIndex).sImageSource
                    error(...
                        'ImageVolumeWithSampleIds:GetSampleIdsForAll:Invalid',...
                        'All ImageVolumeWithSampleIds objects must have the same Image Source value to have their Sample IDs combined.');
                end
                
                c1oSampleIdsPerHandler{dHandlerIndex} = voImageVolumeWithSampleIds(dHandlerIndex).GetSampleIds();
            end
            
            oSampleIds = vertcat(c1oSampleIdsPerHandler{:});
        end
        
        function hFig = CreateCollageOfRepresentativeFieldsOfView(voImageVolumeWithSampleIds, vdGridDimensions, NameValueArgs)
            arguments
                voImageVolumeWithSampleIds (1,:) ImageVolumeWithSampleIds
                vdGridDimensions (1,2) double {mustBePositive, mustBeInteger}
                NameValueArgs.DimensionUnits (1,:) char = 'pixels' % one of 'pixels' | 'normalized' | 'inches' | 'centimeters' | 'points' | 'characters'
                NameValueArgs.TileDimensions (1,2) double {mustBePositive, mustBeFinite} = [200, 200] % px
                NameValueArgs.TilePadding (1,1) double {mustBeNonnegative, mustBeFinite} = 2 % px
                NameValueArgs.TileLabelFontSize (1,1) double {mustBePositive, mustBeFinite} = 10 % px
                NameValueArgs.ShowTileLabels (1,1) logical = true
                NameValueArgs.TileLabelSource (1,:) char {mustBeMember(NameValueArgs.TileLabelSource, {'Id','UserDefinedSampleString','Both'})} = 'Id'
                NameValueArgs.ForceImagingPlaneType ImagingPlaneTypes {ValidationUtils.MustBeEmptyOrScalar} = ImagingPlaneTypes.empty
                NameValueArgs.ShowAllRegionsOfInterest (1,1) logical = true
                NameValueArgs.LineWidth (1,1) double {mustBePositive} = 1
                NameValueArgs.RegionOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [1 0 0] % red
                NameValueArgs.OtherRegionsOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [0 0.8 1] % blue        
                NameValueArgs.ExtractionIndicesPerHandler (1,:) cell = {} % cell array of double vectors that contain the extraction indices for each handler
                NameValueArgs.SetImageDataDisplayThreshold (1,2) double {mustBeFinite, ValidationUtils.MustBeIncreasing}
                NameValueArgs.DisplayOrderGroupIds (:,1) double {mustBeInteger}
                NameValueArgs.DisplayOrderSubGroupIds (:,1) double {mustBeInteger}
                NameValueArgs.TilesToHighlight (:,1) logical
                NameValueArgs.HighlightColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [0 1 0] % green
                NameValueArgs.HighlightColourPerTileToHighlight (:,3) double {ValidationUtils.MustBeValidRgbVector}
                NameValueArgs.TileOutlineColour (1,3) double {ValidationUtils.MustBeValidRgbVector} = [1 1 1] % white
                NameValueArgs.CustomLabels (:,1) string
            end
            
            c1vdExtractionIndicesPerHandler = NameValueArgs.ExtractionIndicesPerHandler;
            
            dNumHandlers = length(voImageVolumeWithSampleIds);
            
            if isempty(c1vdExtractionIndicesPerHandler)
                if isfield(NameValueArgs, 'DisplayOrderGroupIds') && isfield(NameValueArgs, 'DisplayOrderSubGroupIds')
                    dNumRois = length(NameValueArgs.DisplayOrderGroupIds);
                    
                    vdNewHandlerIndices = zeros(1,dNumRois);
                    c1vdExtractionIndicesPerHandler = cell(1,dNumRois);
                    
                    for dRoiIndex=1:dNumRois
                        dGroupId = NameValueArgs.DisplayOrderGroupIds(dRoiIndex);
                        dSubGroupId = NameValueArgs.DisplayOrderSubGroupIds(dRoiIndex);
                        
                        dHandlerIndexMatch = [];
                        dExtractionIndexMatch = [];
                        
                        for dHandlerSearchIndex=1:dNumHandlers
                            oHandler = voImageVolumeWithSampleIds(dHandlerSearchIndex);
                            
                            dMatchIndex = find(oHandler.viGroupIds == dGroupId & oHandler.viSubGroupIds == dSubGroupId);
                            
                            if ~isempty(dMatchIndex)
                                dHandlerIndexMatch = dHandlerSearchIndex;
                                dExtractionIndexMatch = dMatchIndex;
                                
                                break;
                            end
                        end
                        
                        if isempty(dHandlerIndexMatch) || isempty(dExtractionIndexMatch)
                            error(...
                                'ImageVolumeWithSampleIds:CreateCollageOfRepresentativeFieldsOfView:NoMatchForGroupAndSubGroupId',...
                                'No match found in handler list for the given Group and Sub-Group ID.');
                        else
                            vdNewHandlerIndices(dRoiIndex) = dHandlerIndexMatch;
                            c1vdExtractionIndicesPerHandler{dRoiIndex} = dExtractionIndexMatch;
                        end
                    end
                    
                    voImageVolumeWithSampleIds = voImageVolumeWithSampleIds(vdNewHandlerIndices);
                else                
                    dNumRois = 0;
                    
                    c1vdExtractionIndicesPerHandler = cell(1,dNumHandlers);
                    
                    for dHandlerIndex=1:dNumHandlers
                        dNumRois = dNumRois + voImageVolumeWithSampleIds(dHandlerIndex).GetNumberOfRegionsOfInterest();
                        c1vdExtractionIndicesPerHandler{dHandlerIndex} = 1:voImageVolumeWithSampleIds(dHandlerIndex).GetNumberOfRegionsOfInterest();
                    end
                end
            else
                dNumRois = 0;
                
                for dHandlerIndex=1:dNumHandlers
                    dNumRois = dNumRois + length(c1vdExtractionIndicesPerHandler{dHandlerIndex});
                end
            end
            
            
            dNumGridRows = vdGridDimensions(1);
            dNumGridCols = vdGridDimensions(2);
            
            if dNumRois > dNumGridRows * dNumGridCols
                error(...
                    'ImageVolumeWithSampleIds:CreateMontageOfRepresentativeFieldsOfView:InvalidGridSize',...
                    'The given grid size cannot fit the number of images provided.');
            end
            
            dTileHeight = NameValueArgs.TileDimensions(1);
            dTileWidth = NameValueArgs.TileDimensions(2);
            
            dPadding = NameValueArgs.TilePadding;
            
            dFigureWidth = dNumGridCols*(dTileWidth+dPadding) + dPadding;
            dFigureHeight = dNumGridRows*(dTileHeight+dPadding+NameValueArgs.ShowTileLabels*NameValueArgs.TileLabelFontSize) + dPadding;
            
            % create figure to hold the montage
            hFig = figure('Color', [0 0 0],'Resize', 'off');
            
            % set units in figure
            hFig.Units = NameValueArgs.DimensionUnits;
            
            % adjust width and height of figure
            vdCurrentPosition = hFig.Position;
            
            dFigTop = vdCurrentPosition(2) + vdCurrentPosition(4);
            
            vdCurrentPosition(2) = dFigTop - dFigureHeight; 
            vdCurrentPosition(3) = dFigureWidth;
            vdCurrentPosition(4) = dFigureHeight;
            
            hFig.Position = vdCurrentPosition;
            
            % subplot works with normalized units...why me?
            % so everything needs to be divided by the total figure width
            % and height
            
            dNormalizedTileHeight = dTileHeight / dFigureHeight;
            dNormalizedTileWidth = dTileWidth / dFigureWidth;
            
            dNormalizedVerticalPadding = dPadding / dFigureHeight;
            dNormalizedHorizontalPadding = dPadding / dFigureWidth;
            
            dNormalizedVerticalSpaceBetweenTiles = (NameValueArgs.ShowTileLabels*NameValueArgs.TileLabelFontSize + dPadding) / dFigureHeight;
           
            dNormalizedFontSize = NameValueArgs.TileLabelFontSize / dFigureHeight;
                        
            dRowIndex = 1;
            dColIndex = 1;
            
            dHandlerIndex = 1;
            dExtractionIndicesIndex = 1;
            oCurrentHandler = voImageVolumeWithSampleIds(1);
            bVolumeDataWasAlreadyLoaded = oCurrentHandler.GetRASImageVolume().IsVolumeDataLoaded();
            vdExtractionIndices = c1vdExtractionIndicesPerHandler{1};
            
            for dImageIndex=1:dNumRois
                % create sub-plot for image to be rendered in
                dNormalizedAxesBottomLeftX = dNormalizedHorizontalPadding + (dColIndex - 1) * (dNormalizedTileWidth + dNormalizedHorizontalPadding);
                dNormalizedAxesBottomLeftY = 1 - (dNormalizedVerticalPadding + dNormalizedTileHeight) - (dRowIndex - 1) * (dNormalizedTileHeight + dNormalizedVerticalSpaceBetweenTiles);
                
                hAxes = subplot(...
                    'Position', [...
                    dNormalizedAxesBottomLeftX,...
                    dNormalizedAxesBottomLeftY,...
                    dNormalizedTileWidth,...
                    dNormalizedTileHeight]);
                
                % call image volume to do the render
                if isfield(NameValueArgs, 'SetImageDataDisplayThreshold')
                    c1xVarargin = {'SetImageDataDisplayThreshold', NameValueArgs.SetImageDataDisplayThreshold};
                else
                    c1xVarargin = {};
                end
                
                oCurrentHandler.RenderRepresentativeImageOnAxesByExtractionIndex(...
                    hAxes,...
                    vdExtractionIndices(dExtractionIndicesIndex),...
                    'ForceImagingPlaneType', NameValueArgs.ForceImagingPlaneType,...
                    'ShowAllRegionsOfInterest', NameValueArgs.ShowAllRegionsOfInterest,...
                    'LineWidth', NameValueArgs.LineWidth,...
                    'RegionOfInterestColour', NameValueArgs.RegionOfInterestColour,...
                    'OtherRegionsOfInterestColour', NameValueArgs.OtherRegionsOfInterestColour,...
                    c1xVarargin{:});
                
                % change units to pixels
                hAxes.Units = 'pixels';
                
                % turn box on
                axis(hAxes, 'on');
                hAxes.Box = 'on';
                
                if isfield(NameValueArgs, 'TilesToHighlight') && NameValueArgs.TilesToHighlight(dImageIndex)
                    if ~isempty(NameValueArgs.HighlightColourPerTileToHighlight)
                        vdColour = NameValueArgs.HighlightColourPerTileToHighlight(dImageIndex,:);
                    else
                        vdColour = NameValueArgs.HighlightColour;
                    end
                    
                    hAxes.XColor = vdColour;
                    hAxes.YColor = vdColour;
                else
                    hAxes.XColor = NameValueArgs.TileOutlineColour ;
                    hAxes.YColor = NameValueArgs.TileOutlineColour ;
                end
                
                
                hAxes.LineWidth = 2.5;
                xticks(hAxes, []);
                yticks(hAxes, []);
                
                % render the image label
                if NameValueArgs.ShowTileLabels
                    if isfield(NameValueArgs, 'CustomLabels')
                        chLabel = char(NameValueArgs.CustomLabels(dImageIndex));
                    else
                        if strcmp(NameValueArgs.TileLabelSource, 'Id')
                            iGroupId = oCurrentHandler.oSampleIds.viGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                            iSubGroupId = oCurrentHandler.oSampleIds.viSubGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                            
                            chLabel = [num2str(iGroupId), '-', num2str(iSubGroupId)];
                        elseif strcmp(NameValueArgs.TileLabelSource, 'UserDefinedSampleString')
                            chLabel = char(oCurrentHandler.oSampleIds.vsUserDefinedSampleStrings(vdExtractionIndices(dExtractionIndicesIndex)));
                        else
                            iGroupId = oCurrentHandler.oSampleIds.viGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                            iSubGroupId = oCurrentHandler.oSampleIds.viSubGroupIds(vdExtractionIndices(dExtractionIndicesIndex));
                            
                            chSampleString = char(oCurrentHandler.oSampleIds.vsUserDefinedSampleStrings(vdExtractionIndices(dExtractionIndicesIndex)));
                            
                            chLabel = [num2str(iGroupId), '-', num2str(iSubGroupId), ' (', chSampleString, ')'];
                        end
                    end
                    
                    vdAxesPosition = hAxes.Position;
                    dAxesWidth = vdAxesPosition(3);
                    
                    hText = text(...
                        hAxes,...
                        dAxesWidth/2, 0,...
                        chLabel,...
                        'Units', 'pixels',...
                        'Color', [1 1 1],...
                        'Margin', eps,...
                        'FontSize', NameValueArgs.TileLabelFontSize,...
                        'FontUnits', NameValueArgs.DimensionUnits,...
                        'HorizontalAlignment', 'center',...
                        'VerticalAlignment', 'middle');
                    
                    hText.FontUnits = 'pixels';
                    
                    dFontSizePixels = hText.FontSize;
                    
                    vdCurrentTextPosition = hText.Position;
                    vdCurrentTextPosition(2) = (-dFontSizePixels/2) + 1;
                    hText.Position = vdCurrentTextPosition;
                end
                

                % increment handler/extraction index
                if dExtractionIndicesIndex < length(vdExtractionIndices)
                    dExtractionIndicesIndex = dExtractionIndicesIndex + 1;
                elseif dImageIndex ~= dNumRois
                    if ~bVolumeDataWasAlreadyLoaded 
                        oCurrentHandler.GetRASImageVolume().UnloadVolumeData();
                    end
                        
                    dHandlerIndex = dHandlerIndex + 1;
                    oCurrentHandler = voImageVolumeWithSampleIds(dHandlerIndex);
                    bVolumeDataWasAlreadyLoaded = oCurrentHandler.GetRASImageVolume().IsVolumeDataLoaded();
                    vdExtractionIndices = c1vdExtractionIndicesPerHandler{dHandlerIndex};
                    dExtractionIndicesIndex = 1;
                end                    
                
                % increment index in montage grid
                if dColIndex == dNumGridCols % jump to next row
                    dColIndex = 1;
                    dRowIndex = dRowIndex + 1;
                else
                    dColIndex = dColIndex + 1; % run along row left to right
                end
            end
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            
            % local call
            cpObj.oRASImageVolume = copy(obj.oRASImageVolume);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = private)

        function MustBeValidSampleIndex(obj, dSampleIndex)
            arguments
                obj (1,1) ImageVolumeWithSampleIdsForFeatureExtraction
                dSampleIndex (1,1) double {mustBeInteger, mustBePositive}
            end
            
            if dSampleIndex > obj.GetNumberOfRegionsOfInterest()
                error(...
                    'ImageVolumeWithSampleIdsForFeatureExtraction:MustBeValidSampleIndex:Invalid',...
                    'The sample index must not exceed to the number of regions of interest.');
            end
        end
    end
    
    methods (Access = private, Static = true)
        
        function ValidateImageVolume(oImageVolume)
            if ~isscalar(oImageVolume) || ~isa(oImageVolume, 'ImageVolume')
                error(...
                    'ImageVolumeWithSampleIds:ValidateRASImageVolume:InvalidType',...
                    'The Image Volume must be given as a scalar of type ImageVolume.');
            end
            
            if oImageVolume.GetNumberOfRegionsOfInterest() == 0
                error(...
                    'ImageVolumeWithSampleIds:ValidateRASImageVolume:InvalidNumberOfRegionsOfInterest',...
                    'The Image Volume must have at least one region of interest.');
            end
        end
        
        function ValidateRASImageVolume(oRASImageVolume)
            vdMisalignmentAngles_deg = ImageVolumeGeometry.GetEulerAnglesAboutCartesianAxesBetweenGeometries(oRASImageVolume.GetImageVolumeGeometry(), ImageVolumeWithSampleIds.oTargetUnifiedImageVolumeGeometry);
            
            if any(abs(vdMisalignmentAngles_deg) > ImageVolumeWithSampleIds.dMisalignmentFromTargetUnifiedImageVolumeGeometryErrorLimit_deg)
                error(...
                    'ImageVolumeWithSampleIds:ValidateRASImageVolume:HighlyObliqueImageVolume',...
                    ['The given image volume was acquired in an oblique geometry, deviating by more than ', num2str(ImageVolume.dMisalignmentFromTargetUnifiedImageVolumeGeometryErrorLimit_deg), ' degrees, and therefore cannot be processed. Please interpolate the data into an non-oblique volume.']);
            elseif any(abs(vdMisalignmentAngles_deg) > ImageVolumeGeometry.GetPrecisionBound())
                warning(...
                    'ImageVolumeWithSampleIds:ValidateRASImageVolume:MarginallyObliqueImageVolume',...
                    ['The given image volume was acquired with a slightly oblique geometry, deviating by at most ', num2str(max(abs(vdMisalignmentAngles_deg))), ' degrees from the desired acquisition geometry. This image volume can be processed, but care should be taken.']);
            end
        end
        
        function ValidateSampleOrderRegionOfInterestNumbers(vdSampleOrderRegionOfInterestNumbers, oImageVolume)
            if isempty(vdSampleOrderRegionOfInterestNumbers) && isa(vdSampleOrderRegionOfInterestNumbers, 'double')
                % we're good
            else
                if ~iscolumn(vdSampleOrderRegionOfInterestNumbers) || ~isa(vdSampleOrderRegionOfInterestNumbers, 'double')
                    error(...
                        'ImageVolumeWithSampleIds:ValidateSampleOrderRegionOfInterestNumbers:InvalidType',...
                        'ValidateSampleOrderRegionOfInterestNumbers must be a column vector of type double.');
                end
                
                dNumRois = oImageVolume.GetNumberOfRegionsOfInterest();
                
                if ...
                        any(vdSampleOrderRegionOfInterestNumbers < 1) ||...
                        any(vdSampleOrderRegionOfInterestNumbers > dNumRois) ||...
                        length(vdSampleOrderRegionOfInterestNumbers) > dNumRois ||...
                        any(round(vdSampleOrderRegionOfInterestNumbers) ~= vdSampleOrderRegionOfInterestNumbers)
                    error(...
                        'ImageVolumeWithSampleIds:ValidateSampleOrderRegionOfInterestNumbers:InvalidValue',...
                        'ValidateSampleOrderRegionOfInterestNumbers must only contain unique, integer values between 1 and the number of regions of interest within the image volume object.');
                end
            end
        end
    end
    
    
    methods (Access = {?Feature, ?ImageVolumeWithSampleIds}, Static = true)
        
        function dNumTotalRois = GetNumberOfRegionsOfInterestForAll(voImageVolumeWithSampleIds)
            dNumTotalRois = 0;
            
            for dImageIndex=1:length(voImageVolumeWithSampleIds)
                dNumTotalRois = dNumTotalRois + voImageVolumeWithSampleIds(dImageIndex).GetNumberOfRegionsOfInterest();
            end
        end
        
        function oSampleIds = GetSampleIdsForImageVolumesWithSampleIds(voImageVolumeWithSampleIds)
            
            dNumImageVolumeObjects = length(voImageVolumeWithSampleIds);
            
            if dNumImageVolumeObjects == 0
                oSampleIds = SampleIds.empty;
            elseif dNumImageVolumeObjects == 1
                oSampleIds = voImageVolumeWithSampleIds.GetSampleIds();
            else
                c1xSampleIds = cell(1,dNumImageVolumeObjects);
                
                for dInd = 1:dNumImageVolumeObjects
                    c1xSampleIds{dInd} = voImageVolumeWithSampleIds(dInd).GetSampleIds();
                end
            
                oSampleIds = vertcat(c1xSampleIds{:});
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