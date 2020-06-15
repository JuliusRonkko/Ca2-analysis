# Ca2-analysis

The scripts used for Ca2+ analysis are published here.

For the masking the cells from tiff files, we used MatLab script "CaAn1.m".
- this scipt recognizes the cells from the input data, analyzes the intensity changes in the images and prodices a MatLab matrix of the traces.

For the normalizing and thresholding the resulted data, we used MatLab script "Ca2+ analysis.m"
- This script normalizes and threshold the traces, and produces a tab delimited files with the resulting data

For the peak analysis, we used R-script "analyzeAverages.R"
- This script detects peaks from the traces and analyzes the averages in multiple ways, including AUC, peak detect and time of the peak analysis; and produces results as Excel files.
