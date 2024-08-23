import os

# Define the base directory
base_directory = "/Users/clim/Developer/MAR,Primo/Primo 4 - A/DICOM/SEGMENTEDFILE,Primo_nii/"

# Define the list of changes for "Primo 4 - A"
changes = [
    "Primo 6 - F",
    "Primo 7 - F",
    "Primo 8 - A",
    "Primo 9 - A",
    "Primo 10 - A",
    "Primo 11 - F",
    "Primo 12 - F",
    "Primo 13 - F",
    "Primo 14 - A",
    "Primo 15 - F",
    "Primo 16 - F",
    "Primo 17 - A",
    "Primo 18 - A",
    "BLANK",
    "Primo 20 - F",
    "Primo 21 - A",
    "Primo 22 - F",
    "Primo 23 - F",
    "Primo 24 - A",
    "Primo 25 - A",
    "Primo 26 - F",
    "BLANK",
    "Primo 28 - A",
    "Primo 29 - A",
    "Primo 30 - A",
    "Primo 31 - F",
    "Primo 32 - F",
    "Primo 33 - F",
    "Primo 34 - F",
    "Primo 35 - F",
    "Primo 36 - A",
    "Primo 37 - F",
    "Primo 38 - A",
    "Primo 39 - A",
    "Primo 40 - F",
    "Primo 41 - A",
    "Primo 42 - F",
    "BLANK",
    "Primo 44 - A",
    "Primo 45 - A"
]

# Generate and print paths with changes applied
for i, change in enumerate(changes, start=6):
    folder_name = "{:03d}".format(i)
    folder_path = os.path.join(base_directory.replace("Primo 4 - A", change), folder_name)
    print(folder_path)
