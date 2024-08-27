classdef UniformRectilinearRegionsOfInterest < ParametricRegionsOfInterest
    %UniformRectilinearRegionsOfInterest
    %
    % Description of the UniformRectilinearRegionsOfInterest
    %
    % As long as there are unbroken lines of comments, they will appear on
    % a "help" call
    
    % Primary Author: Ryan Au
    % Created: May 30, 2022
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
               
    properties (SetAccess = private, GetAccess = public)
        vdPatchSizePerDim (:,1) double {mustBePositive, mustBeInteger} % the number of voxels for each patch dimension, the order of dimensions is in reference to the image matrix (e.g. first dimension is row, second dim is col, third dim is slice)
        m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch (:,3) double {mustBePositive, mustBeInteger} % provides the location of each patch's corner that is closest to (1,1,1) in the image matrix. The patch then extends in the direction of the row, col and slice axes of the image matrix
    end
                
    properties (Access = private, Constant = true) % DELETE IF UNUSED  
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
            
    methods (Access = public, Static = false) % DELETE IF UNUSED
        
        function obj = UniformRectilinearRegionsOfInterest(oGeometricalImagingObject, vdPatchSizePerDim, m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch)
            %obj = UniformRectilinearRegionsOfInterest(oGeometricalImagingObject, vdPatchSizePerDim, m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch)
            %
            % SYNTAX:
            %  obj = UniformRectilinearRegionsOfInterest(oGeometricalImagingObject, vdPatchSizePerDim, m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch)
            %
            % DESCRIPTION:
            %  Constructor for UniformRectilinearRegionsOfInterest
            %
            % INPUT ARGUMENTS:
            %  oGeometricalImagingObject: oGeometricalImagingObject object
            %  vdPatchSizePerDim: patch dimensions
            %  m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch:
            %           voxel indicies of the corner nearest image matrix
            %           origin of all the patches to be created
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % Primary Author: Ryan Au
            % Created: May 30, 2022
            
            arguments
                oGeometricalImagingObject (1,1) GeometricalImagingObject 
                vdPatchSizePerDim (:,1) double {mustBePositive, mustBeInteger}
                m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch (:,3) double {mustBePositive, mustBeInteger}
            end
            
            % validation of inputs
            UniformRectilinearRegionsOfInterest.MustBeValidPatchSizeAndVoxelIndiciesForImagingObject(oGeometricalImagingObject, vdPatchSizePerDim, m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch);
            
            % super-class constructor call
            obj@ParametricRegionsOfInterest(oGeometricalImagingObject.GetImageVolumeGeometry(), size(m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch,1));
            
            % set properities
            obj.vdPatchSizePerDim = vdPatchSizePerDim;
            obj.m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch = m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch;
        end
        
        function LoadVolumeData(obj)
            % No volume data stored on disk, so no behaviour required
        end
        
        function UnloadVolumeData(obj)
            % No volume data stored on disk, so no behaviour required
        end
        
        function chOriginalFilePath = GetOriginalFilePath(obj)
            %chOriginalFilePath = GetOriginalFilePath(obj)
            %
            % SYNTAX:
            %  chOriginalFilePath = obj.GetOriginalFilePath()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: UniformRectilinearRegionsOfInterest object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            chOriginalFilePath = obj.GetMatFilePath(); % this ROI object is not derived from a medical image format (e.g. Dicom, Nifti) and so the "original" file path is just the Mat file path
        end
                  
        function m3bMask = GetMaskByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            %m3bMask = GetMaskByRegionOfInterestNumber(obj)
            %
            % SYNTAX:
            %  m3bMask = obj.GetMaskByRegionOfInterestNumber()
            %
            % DESCRIPTION:
            %  Get the mask for a specific ROI patch
            %
            % INPUT ARGUMENTS:
            %  obj: UniformRectilinearRegionsOfInterest object
            %  dRegionOfInterestNumber: ROI patch number for which mask is
            %           to be extracted
            %
            % OUTPUTS ARGUMENTS:
            %  m3bMask: mask of the desired ROI patch. Dimensions are the
            %  same as the image.
            
            arguments
                obj UniformRectilinearRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            obj.ForceApplyAllTransforms();
            
            [vdRowBounds, vdColumnBounds, vdSliceBounds] = obj.GetMinimalBoundsByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            % Make the mask volume, which has the same dimensions as the
            % image stored within the UniformRectilinearRegionsOfInterest
            % object
            m3bMask = false(obj.GetImageVolumeGeometry.GetVolumeDimensions());
            m3bMask(vdRowBounds(1):vdRowBounds(2), vdColumnBounds(1):vdColumnBounds(2), vdSliceBounds(1):vdSliceBounds(2)) = true;
        end
        
        function vdCentreVoxelIndices = GetCentreOfRegionVoxelIndicesByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            %vdCentreVoxelIndices = GetCentreOfRegionVoxelIndicesByRegionOfInterestNumber(obj)
            %
            % SYNTAX:
            %  vdCentreVoxelIndices = obj.GetCentreOfRegionVoxelIndicesByRegionOfInterestNumber()
            %
            % DESCRIPTION:
            %  Get the centre voxel indicies of the desired ROI patch
            %
            % INPUT ARGUMENTS:
            %  obj: UniformRectilinearRegionsOfInterest object
            %  dRegionOfInterestNumber: ROI patch number for which mask is
            %           to be extracted
            %
            % OUTPUTS ARGUMENTS:
            %  vdCentreVoxelIndices: centre voxel indicies of the desired
            %           ROI patch
            
            arguments
                obj UniformRectilinearRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            obj.ForceApplyAllTransforms();
            
            [vdRowBounds, vdColumnBounds, vdSliceBounds] = obj.GetMinimalBoundsByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            % Calculate the indicies of the centre voxel within the ROI
            % patch. This would simply the mean between the outer bounds.
            vdCentreVoxelIndices = [mean(vdRowBounds), mean(vdColumnBounds), mean(vdSliceBounds)];
        end
        
        function vdSliceIndices = GetCentreSliceIndicesByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            %vdSliceIndices = GetCentreSliceIndicesByRegionOfInterestNumber(obj)
            %
            % SYNTAX:
            %  vdSliceIndices = obj.GetCentreSliceIndicesByRegionOfInterestNumber()
            %
            % DESCRIPTION:
            %  Get the slice indicies of the desired ROI patch
            %
            % INPUT ARGUMENTS:
            %  obj: UniformRectilinearRegionsOfInterest object
            %  dRegionOfInterestNumber: ROI patch number for which mask is
            %           to be extracted
            %
            % OUTPUTS ARGUMENTS:
            %  vdSliceIndices: slice indicies of the desired ROI patch
            
            arguments
                obj UniformRectilinearRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            obj.ForceApplyAllTransforms();
            
            vdCentreVoxelIndices = obj.GetCentreOfRegionVoxelIndicesByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            % Calculate the slice indicies of the desired ROI patch. This
            % would simply the centre slice indicies, but rounded.
            vdSliceIndices = round(vdCentreVoxelIndices);
        end
        
        function [vdRowBounds, vdColumnBounds, vdSliceBounds] = GetMinimalBoundsByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            %[vdRowBounds, vdColumnBounds, vdSliceBounds] = GetMinimalBoundsByRegionOfInterestNumber(obj)
            %
            % SYNTAX:
            %  [vdRowBounds, vdColumnBounds, vdSliceBounds] = obj.GetMinimalBoundsByRegionOfInterestNumber()
            %
            % DESCRIPTION:
            %  Get the min and max bounds of the desired ROI patch
            %
            % INPUT ARGUMENTS:
            %  obj: UniformRectilinearRegionsOfInterest object
            %  dRegionOfInterestNumber: ROI patch number for which mask is
            %           to be extracted
            %
            % OUTPUTS ARGUMENTS:
            %  vdRowBounds: row bounds of the desired ROI patch
            %  vdColumnBounds: column bounds of the desired ROI patch
            %  vdSliceBounds: slice bounds of the desired ROI patch
            
            arguments
                obj UniformRectilinearRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            obj.ForceApplyAllTransforms();
            
            vdVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch = obj.m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(dRegionOfInterestNumber,:);
            
            vdRowBounds = [vdVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(1), (vdVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(1) + obj.vdPatchSizePerDim(1) - 1)];
            vdColumnBounds = [vdVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(2), (vdVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(2) + obj.vdPatchSizePerDim(2) - 1)];
            vdSliceBounds = [vdVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(3), (vdVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(3) + obj.vdPatchSizePerDim(3) - 1)];
        end
        
        function [m3bMask, vdRowBounds, vdColumnBounds, vdSliceBounds] = GetMinimallyBoundedMaskByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            %[m3bMask, vdRowBounds, vdColumnBounds, vdSliceBounds] = GetMinimallyBoundedMaskByRegionOfInterestNumber(obj)
            %
            % SYNTAX:
            %  [m3bMask, vdRowBounds, vdColumnBounds, vdSliceBounds] = obj.GetMinimallyBoundedMaskByRegionOfInterestNumber()
            %
            % DESCRIPTION:
            %  Get the mask, and min and max bounds of the desired ROI patch
            %
            % INPUT ARGUMENTS:
            %  obj: UniformRectilinearRegionsOfInterest object
            %  dRegionOfInterestNumber: ROI patch number for which mask is
            %           to be extracted
            %
            % OUTPUTS ARGUMENTS:
            %  m3bMask: mask of the desired ROI patch. Dimensions are the
            %  same as the ROI.
            %  vdRowBounds: row bounds of the desired ROI patch
            %  vdColumnBounds: column bounds of the desired ROI patch
            %  vdSliceBounds: slice bounds of the desired ROI patch
            
            arguments
                obj UniformRectilinearRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            obj.ForceApplyAllTransforms();
            
            [vdRowBounds, vdColumnBounds, vdSliceBounds] = obj.GetMinimalBoundsByRegionOfInterestNumber(dRegionOfInterestNumber);
            
            m3bMask = true(obj.vdPatchSizePerDim);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        function vdPatchSizePerDim = GetPatchSize(obj)
            %vdPatchSizePerDim = vdPatchSizePerDim(obj)
            %
            % SYNTAX:
            %  vdPatchSizePerDim = obj.GetPatchSize()
            %
            % DESCRIPTION:
            % Get patch dimensions to be used to patch image
            %
            % INPUT ARGUMENTS:
            %  obj: UniformRectilinearRegionsOfInterest object
            %
            % OUTPUTS ARGUMENTS:
            %  vdPatchSizePerDim: patch dimensions
            
            vdPatchSizePerDim = obj.vdPatchSizePerDim;
        end
        
        function dNumRegionsOfInterest = GetNumberOfRegionsOfInterest(obj)
            %dNumRegionsOfInterest = dNumRegionsOfInterest(obj)
            %
            % SYNTAX:
            %  dNumRegionsOfInterest = obj.GetNumberOfRegionsOfInterest()
            %
            % DESCRIPTION:
            % Get number of patches to be created
            %
            % INPUT ARGUMENTS:
            %  obj: UniformRectilinearRegionsOfInterest object
            %
            % OUTPUTS ARGUMENTS:
            %  dNumRegionsOfInterest: number of patches
            
            dNumRegionsOfInterest = obj.dNumberOfRegionsOfInterest();
        end
    end
    
    
    methods (Access = public, Static = true) % DELETE IF UNUSED        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Static = false)
        
        function c1xRoiDataNameValuePairs = GetNameValuePairsForSave(obj, chMatFilePath)
            c1xRoiDataNameValuePairs = {};
        end
        
        function MustBeValidMatFilePath_ChildClass(obj, chMatFilePath)
            % no additional fields required in .mat file so no validation
            % required
        end
    end
    
    
    methods (Access = protected, Static = true) % DELETE IF UNUSED        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = false) % DELETE IF UNUSED  
        
    end
    
    
    methods (Access = private, Static = true) 
        
        function MustBeValidPatchSizeAndVoxelIndiciesForImagingObject(oGeometricalImagingObject, vdPatchSizePerDim, m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch)
            %MustBeValidPatchSizeAndVoxelIndiciesForImagingObject(oGeometricalImagingObject, vdPatchSizePerDim, m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch)
            %
            % SYNTAX:
            %  MustBeValidPatchSizeAndVoxelIndiciesForImagingObject(oGeometricalImagingObject, vdPatchSizePerDim, m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch)
            %
            % DESCRIPTION:
            %  Validate the patch size and voxel indicies fall within the
            %  image volume
            %
            % INPUT ARGUMENTS:
            %  oGeometricalImagingObject: oGeometricalImagingObject object
            %  vdPatchSizePerDim: patch dimensions
            %  m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch:
            %           voxel indicies of the corner nearest image matrix
            %           origin of all the patches to be created
            %
            % OUTPUTS ARGUMENTS:
            %  
            
            vdVolumeDims = oGeometricalImagingObject.GetImageVolumeGeometry().GetVolumeDimensions();
            
            m2dVoxelIndicesOfCornerFarthestFromImageMatrixOriginPerPatch = vdPatchSizePerDim' + m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch;
            
            % If the largest possible combination of patch size and
            % location is bigger than the image, throw an error
            if ...
                    any(m2dVoxelIndicesOfCornerFarthestFromImageMatrixOriginPerPatch(:,1) > vdVolumeDims(1)) ||...
                    any(m2dVoxelIndicesOfCornerFarthestFromImageMatrixOriginPerPatch(:,2) > vdVolumeDims(2)) ||...
                    any(m2dVoxelIndicesOfCornerFarthestFromImageMatrixOriginPerPatch(:,3) > vdVolumeDims(3))
                error(...
                    'UniformRectilinearRegionsOfInterest:MustBeValidPatchSizeAndVoxelIndiciesForImagingObject:InvalidPatches',...
                    'One or more patches fall outside of the geometrical imaging object volume bounds.');
            end
        end
    end
    
    
    methods (Access = {?GeometricalImagingObject, ?ImagingObjectTransform})
        
        function ApplyReassignFirstVoxel(obj, oTargetImageVolumeGeometry)
            [~,oNewImageVolumeGeometry,vdVolumeDimensionReassignment] = obj.GetCurrentImageVolumeGeometry().ReassignFirstVoxel(...
                0, oTargetImageVolumeGeometry);   
            
            [vdX1_mm, vdY1_mm, vdZ1_mm] = obj.GetCurrentImageVolumeGeometry().GetPositionCoordinatesFromVoxelIndices(...
                obj.m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(:,1),...
                obj.m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(:,2),...
                obj.m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(:,3));
            
            [vdX2_mm, vdY2_mm, vdZ2_mm] = obj.GetCurrentImageVolumeGeometry().GetPositionCoordinatesFromVoxelIndices(...
                obj.m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(:,1) + obj.vdPatchSizePerDim(1),...
                obj.m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(:,2) + obj.vdPatchSizePerDim(2),...
                obj.m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch(:,3) + obj.vdPatchSizePerDim(3));
            
            [vdRow1, vdCol1, vdSlice1] = oNewImageVolumeGeometry.GetVoxelIndicesFromPositionCoordinates(vdX1_mm, vdY1_mm, vdZ1_mm);
            [vdRow2, vdCol2, vdSlice2] = oNewImageVolumeGeometry.GetVoxelIndicesFromPositionCoordinates(vdX2_mm, vdY2_mm, vdZ2_mm);
            
            vdRow = min([vdRow1,vdRow2],[],2);
            vdCol = min([vdCol1,vdCol2],[],2);
            vdSlice = min([vdSlice1,vdSlice2],[],2);
            
            obj.m2dVoxelIndicesOfCornerNearestImageMatrixOriginPerPatch = round([vdRow, vdCol, vdSlice]);            
            obj.vdPatchSizePerDim = obj.vdPatchSizePerDim(vdVolumeDimensionReassignment);
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

