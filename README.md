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
## **_Output4Anipose.m_**
* This code takes the camera parameters and 3D predictions from DANNCE and puts them into a format that can be read and used by Anipose for smoothing or imputation of new 3D predictions
1. It loads in the two .mat files
    * One containing camera parameters and camera names
    * One containing 3D predictions from DANNCE
2. Converts the 3D predictions to 2D
3. Outputs the 2D data to excel spreadsheets
4. Creates the calibration.toml file that is used by Anipose
* If you use this code, ensure that you change all the paths to reflect where your files are and where you want to save the specific files
* Make sure you keep the same file names for the outputs so it matches with the code from Anipose
    * Such as calibration.toml
## **_Anipose-triangulate.py_**
* This code takes the output excel spreadsheets from `Output4Anipose.m` and the `calibration.toml` file and runs them through Anipose
* Make sure to make adjustments to the path on this code so it saves the output to the folder you want it to
    * This is in the last line of the code with the variable p3ds
    * The triangulate function takes the `config.toml` file, the path to the calibration folder (meaning it has the `calibration.toml` file in it), the file name dictionary created within the code which has all the names of the excel spreadsheets that were created within `Output4Anipose.m`, and the name of the output excel spreadsheet that contains the newly imputed 3D coordinates
* I had to make some adjustments to the `triangulate.py` code from Anipose because they originally used h5 files instead of excel spreadsheets to load in the 3D coordinates, so copy and paste the `triangulate.py` code from this repository in place of the one from Anipose to use it with the `Anipose_triangulate.py` code
* Here is a link to the Anipose repository:
    * https://github.com/lambdaloop/anipose
* Information about Anipose, how to use it, and how to install it can be found here:
    * https://anipose.readthedocs.io/en/latest/
* You will also need a `config.toml` file. I included the one I created within this repository
    * Information about this file and what it contains can be found using the second link above as well
* I included the Anipose LICENSE for distribution purposes since I am sharing a modified version of their code