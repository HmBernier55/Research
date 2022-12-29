clear;clc;

% Loading in .mat files

% Load in the camera parameters file for the video being analyzed
% Change this to whatever your file is named
load("label3d_dannce.mat");

% Load in the .mat file that contains the prediction 3D coordinates and
% pmax values
% Change this to whatever your file is named
load("predict_window.mat");

% Datasets for each camera
cam1_dataset = convert3D_2D(params,1,pred);
cam2_dataset = convert3D_2D(params,2,pred);
cam3_dataset = convert3D_2D(params,3,pred);
cam4_dataset = convert3D_2D(params,4,pred);
cam5_dataset = convert3D_2D(params,5,pred);
cam6_dataset = convert3D_2D(params,6,pred);
data = {cam1_dataset;cam2_dataset;cam3_dataset;cam4_dataset;cam5_dataset;cam6_dataset};


% Making excel spreadsheets for each camera (6 of them)
% Adjust the paths to where you want to save the excel files
% If you change the name of the excel files here then make sure to adjust
% the python code that uses Anipose
convertDataToExcel(data{1},'C:\Users\12053\anaconda3\envs\Hunter_research\New-Project\2022-05-27-MAX-camA.xlsx');
convertDataToExcel(data{2},'C:\Users\12053\anaconda3\envs\Hunter_research\New-Project\2022-05-27-MAX-camB.xlsx');
convertDataToExcel(data{3},'C:\Users\12053\anaconda3\envs\Hunter_research\New-Project\2022-05-27-MAX-camC.xlsx');
convertDataToExcel(data{4},'C:\Users\12053\anaconda3\envs\Hunter_research\New-Project\2022-05-27-MAX-camD.xlsx');
convertDataToExcel(data{5},'C:\Users\12053\anaconda3\envs\Hunter_research\New-Project\2022-05-27-MAX-camE.xlsx');
convertDataToExcel(data{6},'C:\Users\12053\anaconda3\envs\Hunter_research\New-Project\2022-05-27-MAX-camF.xlsx');

% Making the calibration file using the function below
% The format for this step is important so the only thing that needs to be
% adjusted within the function below is the path describing where the calibration.toml file will be
% saved
camparamsToTxt(params);



% Function of converting data to excel files and camera parameters to txt
% files
function convertDataToExcel(data,filename)
% Converts data from MATLAB and writes to an excel spreadsheet
    dim = size(data);
    bodyp = ["EarL","EarR","Snout","SpineF","SpineM","TailB","TailM","TailE",...
        "ForepawL","WristL","ElbowL","ShoulderL","ForepawR","WristR","ElbowR",...
        "ShoulderR","HindpawL","AnkleL","KneeL","HindpawR","AnkleR","KneeR"];
    dim1 = size(bodyp);

% Making cells and matrices to be outputted
    j = 2;
    for i = 1:dim1(2)
        if i == 1
            bodyparts{1,i} = "bodyparts";
            bodyparts{1,j} = bodyp(i);

            coords{1,i} = "coords";
            coords{1,j} = "x";
            coords{1,j+1} = "y";
            coords{1,j+2} = "likelihood";
            j = j + 3;
        else
            bodyparts{1,j} = bodyp(i);
            coords{1,j} = "x";
            coords{1,j+1} = "y";
            coords{1,j+2} = "likelihood";
            j = j + 3;
        end
    end
    file = filename;

% Writing to excel spreadsheet
    writecell(bodyparts,file,'Sheet',1,'Range','A1');
    writecell(coords,file,'Sheet',1,'Range','A2');
    writematrix(data,file,'Sheet',1,'Range','B3');
end




function dataset = convert3D_2D(param, camind, predict)
% Storing camera parameters
    thiscam = cameraParameters('IntrinsicMatrix',param{camind}.K,'RadialDistortion',...
        param{camind}.RDistort,'TangentialDistortion',param{camind}.TDistort);

% Converting 3D to 2D using worldToImage function
    EarL = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,1));
    EarR = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,2));
    Snout = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,3));
    SpineF = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,4));
    SpineM = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,5));
    TailB = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,6));
    TailM = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,7));
    TailE = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,8));
    ForepawL = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,9));
    WristL = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,10));
    ElbowL = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,11));
    ShoulderL = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,12));
    ForepawR = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,13));
    WristR = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,14));
    ElbowR = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,15));
    ShoulderR = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,16));
    HindpawL = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,17));
    AnkleL = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,18));
    KneeL = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,19));
    HindpawR = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,20));
    AnkleR = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,21));
    KneeR = worldToImage(thiscam, param{camind}.r, param{camind}.t, predict(:,:,22));
    
% Likelihood values for each point
    dim = size(KneeR);
    lhood = repmat(0.999, [dim(1),1]);

% Combining all body parts 2D points into one matrix
    dataset = [EarL,lhood,EarR,lhood,Snout,lhood,SpineF,lhood,SpineM,lhood,TailB,lhood,...
        TailM,lhood,TailE,lhood,ForepawL,lhood,WristL,lhood,ElbowL,lhood,ShoulderL,lhood,...
        ForepawR,lhood,WristR,lhood,ElbowR,lhood,ShoulderR,lhood,HindpawL,lhood,...
        AnkleL,lhood,KneeL,lhood,HindpawR,lhood,AnkleR,lhood,KneeR,lhood];
end

function camparamsToTxt(params)
    cam_name = ["A","B","C","D","E","F"];
    cam_num = ["cam_0","cam_1","cam_2","cam_3","cam_4","cam_5"];
    size = [1150,1020];

    for i = 1:6
        % Cam name and number
        % Change these paths to wherever you plan to have the
        % calibration.toml file (make sure to keep the same file name
        % though)
        if i == 1
            fileID = fopen('C:\Users\12053\anaconda3\envs\Hunter_research\New-Project\calibration.toml','w');
        else
            fileID = fopen('C:\Users\12053\anaconda3\envs\Hunter_research\New-Project\calibration.toml', 'a');
        end
        fprintf(fileID, '[%s]\n',cam_num(i));
        fprintf(fileID, 'name = "%s"\n',cam_name(i));
        fprintf(fileID, 'size = [ %d, %d,]\n',size(1),size(2));

        % Intrinsic Matrix
        intrin = params{i}.K';
        fprintf(fileID, 'matrix = [ [ %f, %f, %f,]',intrin(1,1:3));
        fprintf(fileID, ', [ %f, %f, %f,]',intrin(2,1:3));
        fprintf(fileID, ', [ %f, %f, %f,],]\n',intrin(3,1:3));

        % Distortions
        fprintf(fileID, 'distortions = [ %1.15f, %1.15f, %1.15f, %1.15f,]\n',params{i}.RDistort, params{i}.TDistort);

        % Rotation Matrix
        rotate = rotationMatrixToVector(params{i}.r);
        fprintf(fileID, 'rotation = [ %1.15f, %1.15f, %1.15f,]\n', rotate);

        % Translation Vector
        fprintf(fileID, 'translation = [ %3.15f, %3.15f, %3.15f,]\n', params{i}.t);

        % Fisheye
        fprintf(fileID, 'fisheye = false\n');
        fprintf(fileID, '\n');
    end
    fclose(fileID);
end