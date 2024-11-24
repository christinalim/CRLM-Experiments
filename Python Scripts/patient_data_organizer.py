import os
import shutil

def organize_files(directory):
    # Define the input folders
    segmentation_folder = os.path.join(directory, "Segmentation_nii")
    volume_folder = os.path.join(directory, "Volume_nii")
    
    # Ensure the source folders exist
    if not os.path.exists(segmentation_folder) or not os.path.exists(volume_folder):
        print("Error: Source folders 'Segmentation_nii' or 'Volume_nii' are missing.")
        return
    
    # Get the list of files from each folder
    segmentation_files = sorted(f for f in os.listdir(segmentation_folder) if f.endswith("_Segmentation.nii"))
    volume_files = sorted(f for f in os.listdir(volume_folder) if f.endswith("_Volume.nii"))
    
    # Create a set of patient IDs from the filenames
    patient_ids = set()
    for f in segmentation_files:
        patient_id = f.split('_')[0]
        patient_ids.add(patient_id)
    for f in volume_files:
        patient_id = f.split('_')[0]
        patient_ids.add(patient_id)
    
    # Process each patient ID
    for patient_id in sorted(patient_ids):
        # Define expected filenames
        seg_filename = f"{patient_id}_Segmentation.nii"
        vol_filename = f"{patient_id}_Volume.nii"
        
        # Paths to the files
        seg_file_path = os.path.join(segmentation_folder, seg_filename)
        vol_file_path = os.path.join(volume_folder, vol_filename)
        
        # Check if the files exist
        if not os.path.exists(seg_file_path):
            print(f"Warning: Segmentation file missing for patient {patient_id}.")
            continue
        if not os.path.exists(vol_file_path):
            print(f"Warning: Volume file missing for patient {patient_id}.")
            continue
        
        # Create the PTxxx folder
        patient_folder = os.path.join(directory, f"PT{patient_id}")
        os.makedirs(patient_folder, exist_ok=True)
        
        # Create the Segmentation and Volume subfolders
        seg_folder = os.path.join(patient_folder, "Segmentation")
        vol_folder = os.path.join(patient_folder, "Volume")
        os.makedirs(seg_folder, exist_ok=True)
        os.makedirs(vol_folder, exist_ok=True)
        
        # Move files into the appropriate folders
        shutil.move(seg_file_path, os.path.join(seg_folder, seg_filename))
        shutil.move(vol_file_path, os.path.join(vol_folder, vol_filename))
        
        print(f"Organized files for patient PT{patient_id}.")

    print("File organization complete.")

# Example usage
if __name__ == "__main__":
    # Specify the directory containing 'Segmentation_nii' and 'Volume_nii' folders
    directory = "/Users/clim/Developer/Patient Data"
    organize_files(directory)
