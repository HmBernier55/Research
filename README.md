# Code Explanations
This respository contains all the code I wrote and used for my graduate research
## **_Error-Testing.m_**
* This code contains multiple sections that run calculations for errors, pmax values, and imputations
### How the code works:
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
    * The error threshold is used to determine if a marker is good or bad and the pmax threshold is used to determine if the marker is kept or needs to be recalculated
    * Variables at the end of the section can be used to visualize the results
4. The fourth section titled "Imputation of New Coordinates Based on Thresholding" is used to impute new 3D coordinates based on pmax threshold values
    * The output at the end of the loops is a cell array of newly calculated errors based on the newly imputed 3D coordinates that can be used to compare to the old errors
5. The rest of the sections I used for plotting and visualization. They can be deleted or reused.
## **_Output4Anipose.m_**
* This code takes the camera parameters and 3D predictions from DANNCE and puts them into a format that can be read and used by Anipose for smoothing or imputation of new 3D predictions
### How the code works:
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
    * This is in the last line of the code with the variable "p3ds"
    * The triangulate function takes the `config.toml` file, the path to the calibration folder (meaning it has the `calibration.toml` file in it), the file name dictionary created within the code which has all the names of the excel spreadsheets that were created within `Output4Anipose.m`, and the name of the output excel spreadsheet that contains the newly imputed 3D coordinates
* I had to make some adjustments to the `triangulate.py` code from Anipose because they originally used h5 files instead of excel spreadsheets to load in the 3D coordinates, so copy and paste the `triangulate.py` code from this repository in place of the one from Anipose to use it with the `Anipose_triangulate.py` code
* Here is a link to the Anipose repository:
    * https://github.com/lambdaloop/anipose
* Information about Anipose, how to use it, and how to install it can be found here:
    * https://anipose.readthedocs.io/en/latest/
* You will also need a `config.toml` file. I included the one I created within this repository
    * Information about this file and what it contains can be found using the second link above as well
* I included the Anipose LICENSE for distribution purposes since I am sharing a modified version of their code
## **_AniposeOutput-Formatting.m_**
* This code takes the output excel spreadsheet from `Anipose_triangulate.py` and reformats it into a .mat file for analysis
* All three codes (`Output4Anipose.m`, `Anipose_triangulate.py`, and `AniposeOutput_Formatting`) could probably be condensed into one python code, but at the time I felt more comfortable in MATLAB
* The sequence that I ran to use Anipose was:
    1. Run `Output4Anipose.m`
    2. Run `Anipose_triangulate.py`
    3. Run `AniposeOutput_Formatting.m`
## **_BundleAdjustmentData.m_**
* This code takes a .mat file that contains camera parameters and hand-labeled marker coordinates where the person only labeled specific body parts of the mouse purely for Bundle Adjustment purposes
* The markers must all be hand-labeled meaning the short cut of pressing `t` for triangulate when hand-labeling is turned off
    * This is done to get more accurate results for Bundle Adjustment
### How the code works:
1. It loads in the .mat file
2. Asks the user to select which marker positions were labeled through a GUI
    * Hold CTRL to select multiple marker positions
3. Creates all the needed outputs like matrix of 2D coordinates, matrix of 3D coordinates, index arrays for cameras and 3D coordinates, camera matrices, and principle offset values
4. Saves all the outputs into one .mat file called `BundleAdjustment.mat`
## **_BundleAdj.py_**
* This code takes the output .mat file from `BundleAdjustmentData.m` and runs bundle adjustment on the input data
* The bundle adjustment code PySBA can be found here:
    * https://github.com/jahdiel/pySBA
## **_Velocity-threshold3D.m_**
* This code takes an input .mat file that contains 3D predictions, calculates the velocity of each marker frame by frame, and thresholds the velocities based on a set value
* I also tried to utilize segment lengths between each marker as another form of thresholding that could help the accuracy of the analysis, but the average values for segment lengths was never constant
    * All of this analysis has been commented out of the code
### How the code works:
1. It loads in a .mat file
2. Calculates the velocity of each marker frame by frame
3. Smooths the data using an optimized window size
    * This window size is determined by running the section of code titled "Determining the best window size for filtering"
    * It runs through an array of threshold values and determines the best window size for that threshold value based on the percent of bad frames removed and percent of good frames kept
4. Thresholds the velocity values of each marker and saves their index into a variable called "index"
5. This matrix "index" can be used with Anipose to interpolate new values for bad marker predictions
    * Just need to uncomment the save command at the end of the section
