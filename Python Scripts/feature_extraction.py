import csv
import re

# Dictionary to map feature codes to feature names
feature_mapping = {
    "F010001": "Mean",
    "F010002": "Median",
    "F010003": "Range",
    "F010004": "Minimum",
    "F010005": "Maximum",
    "F010006": "Variance",
    "F010007": "Standard Deviation",
    "F010008": "Mean Absolute Deviation",
    "F010009": "Median Absolute Deviation",
    "F010010": "Uniformity",
    "F010011": "Energy",
    "F010012": "Entropy",
    "F010013": "Skewness",
    "F010014": "Kurtosis",
    "F010015": "1 Percentile",
    "F010016": "10 Percentile",
    "F010017": "90 Percentile",
    "F010018": "99 Percentile",
    "F010019": "Root Mean Square",
    "F010021": "Bimodality Coefficient",
    "F030001": "GLCM Contrast",
    "F030002": "GLCM Difference Average",
    "F030003": "GLCM Joint Energy",
    "F030004": "GLCM Joint Entropy",
    "F030005": "GLCM Autocorrelation",
    "F030006": "GLCM Inverse Difference",
    "F030007": "GLCM Inverse Difference Moment",
    "F030008": "GLCM Correlation",
    "F030009": "GLCM Cluster Prominence",
    "F030010": "GLCM Cluster Shade",
    "F030011": "GLCM Cluster Tendency",
    "F030012": "GLCM Sum Of Squares",
    "F030013": "GLCM Max Probability",
    "F030014": "GLCM Inverse Variance",
    "F030015": "GLCM Sum Average",
    "F030016": "GLCM Sum Entropy",
    "F030017": "GLCM Difference Entropy",
    "F030018": "GLCM IMC1",
    "F030019": "GLCM IMC2",
    "F030020": "GLCM Diagonal Moment",
    "F030021": "GLCM IDM",
    "F040001": "GLRLM Short Run Emphasis",
    "F040002": "GLRLM Long Run Emphasis",
    "F040003": "GLRLM Gray Level Non Uniformity",
    "F040004": "GLRLM Run Length Non Uniformity",
    "F040005": "GLRLM Run Percentage",
    "F040006": "GLRLM Low Gray Level Run Emphasis",
    "F040007": "GLRLM High Gray Level Run Emphasis",
    "F040008": "GLRLM Short Run Low Gray Level Emphasis",
    "F040009": "GLRLM Short Run High Gray Level Emphasis",
    "F040010": "GLRLM Long Run Low Gray Level Emphasis",
    "F040011": "GLRLM Long Run High Gray Level Emphasis",
    "F020001": "Volume",
    "F020002": "Surface Area",
    "F020003": "Sphericity",
    "F020004": "Spherical Disproportion",
    "F020005": "Surface Area To Volume Ratio",
    "F020006": "Max Diameter",
    "F020007": "Compactness1",
    "F020008": "Compactness2",
    "F020009": "Compactness3",
    "F020010": "Mean Radial Length",
    "F020011": "Spiculation",
    "F020012": "NRL Mean",
    "F020013": "NRL Entropy",
    "F020014": "NRL Sphericity",
    "F020015": "NRL Roughness",
    "F020016": "NRL Ratio",
    "F020017": "Axial Recist 3D",
    "F020018": "Sagittal Recist 3D",
    "F020019": "Coronal Recist 3D",
    "F020020": "Area",
    "F020021": "Perimeter",
    "F020022": "Recist 2D",
    "F020023": "Major Axis Length",
    "F020024": "Minor Axis Length",
    "F020025": "Least Axis Length",
    "F020026": "Elongation",
    "F020027": "Flatness"
}

def extract_feature_code_and_suffix(full_code):
    # Use regular expression to extract the feature code and text after underscore
    match = re.match(r'([A-Z0-9]+)(?:_(.*))?', full_code)
    if match:
        feature_code = match.group(1)
        suffix = match.group(2) if match.group(2) else ""
        return feature_code, suffix
    return full_code, ""

def generate_feature_names(input_csv, output_csv):
    # Read the input CSV and generate the output CSV with feature names and suffixes
    with open(input_csv, 'r') as csvfile:
        reader = csv.reader(csvfile)
        header = next(reader)  # Skip header if there is one

        # Create the output CSV
        with open(output_csv, 'w', newline='') as outfile:
            writer = csv.writer(outfile)
            writer.writerow(["Code", "Feature Name", "Suffix"])  # Write header

            # Iterate through the input rows
            for row in reader:
                full_code = row[0]  # Assuming the code is in the first column
                feature_code, suffix = extract_feature_code_and_suffix(full_code)
                
                # Match the code to the feature name
                feature_name = feature_mapping.get(feature_code, "Unknown Feature")
                
                # Write to the output file
                writer.writerow([feature_code, feature_name, suffix])

# Example usage
input_csv = '/Users/clim/Developer/GitHub/CRLM-Experiments/Random Forest Sample Code/Experiment [2024-08-20_16.19.19]/Results/Used_Features.csv'  # Replace with your input CSV file path
output_csv = '/Users/clim/Developer/GitHub/CRLM-Experiments/Random Forest Sample Code/Experiment [2024-08-20_16.19.19]/Results/Used_Features_Labelled.csv'  # Replace with your desired output CSV file path
generate_feature_names(input_csv, output_csv)
