clear;clc;

% Loading in excel data
% Change this to the name of the excel spreadsheet that was output from
% Anipose_triangulate.py code
[data] = xlsread("points_3d_triangulate_05_27_MAX.xlsx");
dim = size(data);
k = 1;
for i = 1:22
    for j = 1:dim(1)
        pred(j,1:3,i) = data(j,k:k+2);
    end
    k = k + 6;
end

% Saving the newly formatted 3D coordinates from Anipose
% Make sure to change this path to whatever folder you want to save the
% data to
save('C:\Users\12053\Documents\Dunn_Research\save_data_MAX0527.mat','pred');