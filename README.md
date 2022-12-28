# Code Explanations
This respository contains all the code I wrote and used for my graduate research
## **_Error-Testing.m_**
* This code contains multiple sections that run calculations for errors, pmax values, and imputations
1. The first section titled "Calculating Errors and PMax Values" is the main section that must be run before any other section
    * Each time you want to run a section below the first section, I would recommend rerunning the first section to avoid any problems with overwriting previous variable names
    * It loads in all of the ground truth and prediction files that are used for calculating errors and corresponding pmax values
    * Folder organization is important for running this code:
        1. I have a parent folder named `Error_Testing` that contains two sub-folders: `Ground_Truth_Labels` and `Prediction_Labels`
        2. Within the `Ground_Truth_Labels` folder are .mat files containing 3D coordinates of hand-labeled markers which are used as "ground truth" or baseline values when calculating errors
        3. Within the `Prediction_Labels` folder are .mat files containing 3D coordinates and pmax values output from DANNCE with COM already added back to the predictions
        4. Ensure that your naming convention for each file is consistent so that the .mat files, within the ground truth and prediction folders, that correspond to the same video have the same index
            * Meaning: For the first video that is being analyzed, the ground truth .mat file and prediction .mat file that corresponds to that video should both be the first file within their respective folders
    * Add the paths to the parent folder, ground truth folder, and prediction folder in the code to analyze the files
    * Once this section is run, you will have a cell array of error values and pmax values
2. The second section titled "Averaging Errors based on a threshold" is an analysis section
    * This section calculates the average of the errors (between the ground truth and prediction values) at a given pmax threshold and plots the results
3. The third section titled "Average Precision to Determine Best Pmax Threshold" is used to determine and visualize the most optimum pmax threshold value based on the percentage of good and bad frames removed or kept based on a range of pmax thresholds and an error threshold
    * The error threshold is used to determine if a marker is good or bad and the pmax threshold is used to determine if the marker is kept or deleted
    * Variables at the end of the section can be used to visualize the results
4. The fourth section titled "Imputation of New Coordinates Based on Thresholding" is used to impute new 3D coordinates based on pmax threshold values
    * The output at the end of the loops is a cell array of newly calculated errors based on the newly imputed 3D coordinates that can be used to compare to the old errors
5. The rest of the sections I used for plotting and visualization. They can be deleted or reused.


