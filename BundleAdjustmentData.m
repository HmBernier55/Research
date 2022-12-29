%% Loading the .mat file
clear;clc;
% Loading in the .mat file with the parameters needed for bundle adjustment
load("20220603_110308_Label3D.mat")

%% Selecting the body parts labeled within the Label3D.mat file
list = {'EarL','EarR','Snout','SpineF','SpineM','Tail(base)','Tail(mid)',...
    'Tail(end)','ForepawL','WristL','ElbowL','ShoulderL','ForepawR',...
    'WristR','ElbowR','ShoulderR','HindpawL','AnkleL','KneeL','HindpawR',...
    'AnkleR','KneeR'};
[indx, tf] = listdlg('PromptString', {'Select the body parts that were labeled:',...
    '(Hold ctrl to select multiple labels)'},'ListString', list,'ListSize', [200 300]);

%% Creating points_2D matrix
dim_2D = size(data_2D);
points_2D_x = [];

% (matrix set up: goes in order of frame1 left ear x and y, 
% frame1 right ear x and y, etc.)

% X values for points_2D
for a = 1:dim_2D(4)
    for b = indx
        if a == 1 && b == indx(1)
            points_2D_x = data_2D(b,:,1,a)';
        else
            points_2D_x = [points_2D_x;data_2D(b,:,1,a)'];
        end
    end
end

% Y values for points_2D
for c = 1:dim_2D(4)
    for d = indx
        if c == 1 && d == indx(1)
            points_2D_y = data_2D(d,:,2,c)';
        else
            points_2D_y = [points_2D_y;data_2D(d,:,2,c)'];
        end
    end
end

% Concatenating the x and y vectors
points_2D = [points_2D_x,points_2D_y];

%% Creating points_3D matrix 
% (matrix set up like:[frame1_leftear; frame1_rightear; etc.])
indx1 = (indx*3)-2;
k = 1;
for i = 1:dim_2D(4)
    for j = indx1
        if k == 1
            new_data3D = data_3D(i,j:j+2);
            k = k + 1;
        else
            new_data3D = [new_data3D; data_3D(i,j:j+2)];
        end
    end
end
%% Creating vector for camera_ind
% Used for indexing which camera saw which 2D point
% Should be same length as points_2D
% (numbers should range from 0 to number of cameras - 1)

cam = [0 1 2 3 4 5];
cam_ind =repmat(cam,[1,dim_2D(4)*length(indx)])';

%% Creating vector for point_ind
% Used for indexing which 3D point the 2D points belong to
% Should be same length as points_2D 
% (numbers range from 0 to number of 3D points - 1)

q = 0;
dim_3D = size(new_data3D);
for m = 1:dim_3D(1)
    if q == 0
        point_ind = ones(1,6)*q;
    else
        point_ind = [point_ind, ones(1,6)*q];
    end
    q = q + 1;
end
point_ind = point_ind';

%% Creating camera_Param matrix

% converting rotation matrices to rotation vectors for each camera
rotation_vec1 = rotationMatrixToVector(camParams{1}.r);
rotation_vec2 = rotationMatrixToVector(camParams{2}.r);
rotation_vec3 = rotationMatrixToVector(camParams{3}.r);
rotation_vec4 = rotationMatrixToVector(camParams{4}.r);
rotation_vec5 = rotationMatrixToVector(camParams{5}.r);
rotation_vec6 = rotationMatrixToVector(camParams{6}.r);

% obtaining translation vectors for each camera
translation_vec1 = camParams{1}.t;
translation_vec2 = camParams{2}.t;
translation_vec3 = camParams{3}.t;
translation_vec4 = camParams{4}.t;
translation_vec5 = camParams{5}.t;
translation_vec6 = camParams{6}.t;

% obtaining focal lengths from each camera
for n = 1:6
    focal_len(n) = camParams{n}.K(1,1);
end

% obtaining two distortion variables
r_dist1 = camParams{1}.RDistort;
r_dist2 = camParams{2}.RDistort;
r_dist3 = camParams{3}.RDistort;
r_dist4 = camParams{4}.RDistort;
r_dist5 = camParams{5}.RDistort;
r_dist6 = camParams{6}.RDistort;

% final camera array
camera_Array = [rotation_vec1,translation_vec1,focal_len(1),r_dist1;...
    rotation_vec2,translation_vec2,focal_len(2),r_dist2;...
    rotation_vec3,translation_vec3,focal_len(3),r_dist3;...
    rotation_vec4,translation_vec4,focal_len(4),r_dist4;...
    rotation_vec5,translation_vec5,focal_len(5),r_dist5;...
    rotation_vec6,translation_vec6,focal_len(6),r_dist6];

%% Obtaining the principle offset values for each camera
prin_off1 = camParams{1}.K(3,1:2);
prin_off2 = camParams{2}.K(3,1:2);
prin_off3 = camParams{3}.K(3,1:2);
prin_off4 = camParams{4}.K(3,1:2);
prin_off5 = camParams{5}.K(3,1:2);
prin_off6 = camParams{6}.K(3,1:2);
prin_off = [prin_off1; prin_off2; prin_off3; prin_off4; prin_off5; prin_off6];

save('BundleAdjustment.mat','camera_Array','point_ind','cam_ind','new_data3D',...
    'points_2D', 'prin_off')

% thiscam = cameraParameters('IntrinsicMatrix',camParams{1}.K,'RadialDistortion',...
%     camParams{1}.RDistort,'TangentialDistortion',camParams{1}.TDistort);
% worldToImage(thiscam, camParams{1}.r, camParams{1}.t, new_data3D)