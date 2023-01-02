%% Loading in the files
clear;clc;

% Load in the .mat file that contains the 3D marker predictions
load("predict_window.mat");


%% Calculating the velocities of the markers
dim = size(pred);
n = 1;
for i = 1:dim(3)
    for j = 1:dim(1)-1
        dist(j,i) = sqrt(((pred(j+1,1,i)-pred(j,1,i))^2)+((pred(j+1,2,i)-...
            pred(j,2,i))^2)+((pred(j+1,3,i)-pred(j,3,i))^2));
    end
end

% Calculating the distance markers (segment lengths)
% mark1 = [1, 1, 3, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22];
% mark2 = [2, 2, 4, 4, 4, 5, 6, 7, 10, 11, 12, 11, 14, 15, 16, 15, 18, 19, 18, 21, 22, 21];
% dim_dist = size(mark1);
% for h = 1:dim_dist(2)
%     for v = 1:dim(1)
%         distance(v,h) = sqrt(((pred(v,1,mark1(h))-pred(v,1,mark2(h)))^2)+((pred(v,2,mark1(h))-...
%             pred(v,2,mark2(h)))^2)+((pred(v,3,mark1(h))-pred(v,3,mark2(h)))^2));
%     end
%     avg_thresh(h) = mean(distance(:,h));
% end


% Running a median filter over the velocities to broaden the spikes to try
% and remove larger chunks of bad frames

dist1 = smoothdata(dist,'sgolay',76);
% dist2 = smoothdata(distance,'gaussian',53);

% Thresholding the velocities and recording the frame number and body part
% that is above threshold
% threshold = [20.9, 20.9, 35.1, 35.1, 33.3, 31.5, 34.3, 43.7, 5.7, 12.7, 13.5, 13.5, ...
%    5.8, 11.8, 12.7, 12.7, 11.7, 20.3, 20.3, 12, 20.5, 20.5];
for m = 1:dim(3)
    for k = 1:dim(1)-1
        if dist1(k,m) > 1.5 % && dist2(k,m) > threshold(m)
            index(n,1) = k;
            index(n,2) = m;
            n = n + 1;
        end
    end
end


% Normalizing the p-max values of the 3D predictions in case you want to
% use them
dim_p = size(p_max);
for p = 1:dim_p(2)
    for s = 1:dim_p(1)
        new_pmax(s,p) = 1/(1+exp(-p_max(s,p)));
    end
end


% Saving the indexes of the bad frames to be used to change the scores of
% the bad frames to 0
% save('score_index.mat','index');

%% Determining the best window size for filtering

% Calculating velocities of markers
dim = size(pred);
for i = 1:dim(3)
    for j = 1:dim(1)-1
        dist(j,i) = sqrt(((pred(j+1,1,i)-pred(j,1,i))^2)+((pred(j+1,2,i)-...
            pred(j,2,i))^2)+((pred(j+1,3,i)-pred(j,3,i))^2));
    end
end

% Calculating distances between markers
% mark1 = [1, 1, 3, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22];
% mark2 = [2, 2, 4, 4, 4, 5, 6, 7, 10, 11, 12, 11, 14, 15, 16, 15, 18, 19, 18, 21, 22, 21];
% dim_dist = size(mark1);
% for h = 1:dim_dist(2)
%     for v = 1:dim(1)-1
%         distance(v,h) = sqrt(((pred(v,1,mark1(h))-pred(v,1,mark2(h)))^2)+((pred(v,2,mark1(h))-...
%             pred(v,2,mark2(h)))^2)+((pred(v,3,mark1(h))-pred(v,3,mark2(h)))^2));
%     end
%     avg_thresh(h) = mean(distance(:,h));
% end



% Arrays for bad frames, bad markers (indexed based on bad frames), and different
% window sizes for the median filter
bad_frames = [347:359,416:439,375:385]; %186:208, 224, 226:238, 247, 253:272, 273:285, 290, 340:345];
bad_mark = [repmat(9,1,37), repmat(13,1,11)]; %repmat(9,1,78)];
window = 1:200;
threshold1 = 0.5:0.1:2.5;
% threshold = [20.9, 20.9, 35.1, 35.1, 33.3, 31.5, 34.3, 43.7, 5.7, 12.7, 13.5, 13.5, ...
%    5.8, 11.8, 12.7, 12.7, 11.7, 20.3, 20.3, 12, 20.5, 20.5];


% Looping through different window sizes to determine the best window size
% for bad frame removal
dim1 = size(window);
dim2 = size(threshold1);
fprintf("Window\t\tBad\t\t\tGood\t\tThreshold\n");
for c = 1:dim2(2)
    for b = 1:dim1(2)
        med = smoothdata(dist,'sgolay',window(b));
        % med1 = smoothdata(distance,'gaussian',window(b));
        n = 1;
        ind = [];
        for m = 1:dim(3)
            for k = 1:dim(1)-1 
                if med(k,m) > threshold1(c) %&& med1(k,m) > threshold(m)
                    ind(n,1) = k;
                    ind(n,2) = m;
                    n = n + 1;
                end
            end
        end
        [bad, good] = Accuracy(dim(1),dim(3),ind,bad_frames,bad_mark);
        tab(b,1) = window(b);
        tab(b,2) = bad;
        tab(b,3) = good;
    end
    % Finding the best window size with the highest removal accuracy of bad
    % frames
    max_acc = max(tab(:,2));
    for a = 1:size(tab)
        if tab(a,2) == max_acc
            max_ind = tab(a,1);
            good_acc = tab(a,3);
        end
    end
    % Printing out the best window size and its corresponding accuracies
    fprintf("%2.0f\t\t\t%2.2f%%\t\t%2.2f%%\t\t\t%1.1f\n",max_ind,max_acc,good_acc,threshold1(c))
end



% Function used for calculating the accuracy of the thresholding in terms
% of bad frames removed and good frames kept in
function [acc_bad, acc_good] = Accuracy(tot_frame, tot_marker, index, bad_frames, bad_mark)

% Calculating the accuracy of bad frames being removed through thresholding
n = 0;
dim = size(index);
dim1 = size(bad_frames);
for i = 1:dim1(2)
    for j = 1:dim(1)
        if bad_frames(i) == index(j,1) && bad_mark(i) == index(j,2)
            n = n + 1;
        else
            n = n;
        end
    end
end
acc_bad = (n/dim1(2))*100;

% Calculating the accuracy of good frames not being removed through
% thresholding
tot_data = tot_frame*tot_marker;
tot_good = tot_data-dim1(2);
bad_index = dim(1)-n;
acc_good = ((tot_good-bad_index)/tot_good)*100;

end