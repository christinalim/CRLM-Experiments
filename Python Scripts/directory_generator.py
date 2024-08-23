# import os

# # Specify the directory where you want to create the folders
# directory = "/Users/clim/Developer/MAR/Primo_nii"

# # Ensure the directory exists, if not create it
# if not os.path.exists(directory):
#     os.makedirs(directory)

# # Generate folders labeled from "002" to "101"
# for i in range(2, 102):
#     folder_name = "{:03d}".format(i)  # Ensure folder names are 3 digits with leading zeros
#     folder_path = os.path.join(directory, folder_name)
#     os.makedirs(folder_path)

# print("Folders created successfully!")

import os

def generate_folders(directory, num_folders):
    # Ensure the directory exists, if not, create it
    if not os.path.exists(directory):
        os.makedirs(directory)

    # Generate folders
    for i in range(2, num_folders + 2):  # Start from 002_Volume
        folder_name = f"{i:03d}_Volume"
        folder_path = os.path.join(directory, folder_name)
        os.makedirs(folder_path)
        print(f"Created folder: {folder_path}")

if __name__ == "__main__":
    directory = "/Users/clim/Developer/MAR/Primo_nii"  # Specify the directory where you want to create the folders
    num_folders = 100  # Number of folders to generate
    generate_folders(directory, num_folders)


