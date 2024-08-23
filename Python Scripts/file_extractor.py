import csv
import os
import shutil

def copy_folders(csv_file, output_directory):
    # Create the output directory if it doesn't exist
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    with open(csv_file, 'r') as file:
        csv_reader = csv.reader(file)
        for row in csv_reader:
            folder_path = row[0]
            if os.path.exists(folder_path) and os.path.isdir(folder_path):
                # Get the parent folder two tiers up
                parent_folder = os.path.abspath(os.path.join(folder_path, '..', '..'))
                parent_folder_name = os.path.basename(parent_folder)
                output_path = os.path.join(output_directory, parent_folder_name)
                # Copy the folder to the output directory
                shutil.copytree(folder_path, output_path)
                print(f"Folder '{parent_folder_name}' copied successfully to '{output_directory}'")
            else:
                print(f"Folder '{folder_path}' does not exist or is not a directory.")

if __name__ == "__main__":
    csv_file = input("Enter the path to the CSV file: ")
    output_directory = input("Enter the path to the output directory: ")
    copy_folders(csv_file, output_directory)
