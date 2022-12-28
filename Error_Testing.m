%% Calculating Errors and PMax Values
clear;clc;

% Add the path for the parent folder that contains two folders for Ground
% truth labels and Prediction labels
addpath(genpath('C:\Users\12053\Documents\Dunn_Research\Error_Testing'))

% Loading in file names for Ground Truth and Prediction Labels

% Add the path for the sub folder that contains the Ground Truth Labels (.mat files)
myGroundFolder = 'C:\Users\12053\Documents\Dunn_Research\Error_Testing\Ground_Truth_Labels';
filePatternGround = fullfile(myGroundFolder, '*.mat');
theGroundFiles = dir(filePatternGround);

% Add the path for the sub folder that contains the Prediction Labels (.mat files) w/ COM already added
myPredictionFolder = 'C:\Users\12053\Documents\Dunn_Research\Error_Testing\Prediction_Labels';
filePatternPred = fullfile(myPredictionFolder,'*.mat');
thePredictionFiles = dir(filePatternPred);

% Creating empty cell arrays for errors and pmax values
Errors = cell(length(theGroundFiles),1);
PMax = cell(length(theGroundFiles),1);

% Runs through each pair of .mat files, calculates the errors between the
% ground truth and prediction markers, and pulls all the necessary pmax
% values and runs them through a sigmoid function
% All the errors are output to the variable "Errors"
% All the pmax values are output to the variable "PMax"
for i = 1:length(theGroundFiles)
    GroundT = load(theGroundFiles(i,1).name);
    Prediction = load(thePredictionFiles(i,1).name);
    frame_ind = GroundT.labelData{1,1}.data_sampleID;
    error = [];
    Pred_data1 = [];
    pmax = [];
    for j = 1:length(frame_ind)
        GT_data = FormatRowData(GroundT.labelData{1,1}.data_3d(j,:));
        Pred_data = FormatPredData(Prediction.right_pred(frame_ind(j),:,:));
        pmax(j,1:22) = SigmoidFunc(Prediction.p_max(frame_ind(j),:));
        
        dim_data = size(GT_data);
        for k = 1:dim_data(1)
            error(j,k) = norm(GT_data(k,:)-Pred_data(k,:));
        end
    end
    Frame_ind{i,1} = frame_ind';
    Errors{i} = error;
    PMax{i} = pmax;

end

% Removing both tail markers from Errors and PMax cell arrays
dim_errors = size(Errors);
for h = 1:dim_errors(1)
    Errors{h}(:,7:8) = [];
    PMax{h}(:,7:8) = [];
end

%% Averaging Errors based on a threshold
threshold = [0.1:0.01:0.8];
dim = size(PMax);

% Runs through all the elements of the PMax cell array (which is each .mat file)
% and calculates the average of the errors that correspond to pmax values
% that are greater than the given threshold

for m = 1:length(threshold)
    tempErrors = {Errors};
    tempPMax = {PMax};
    for n = 1:dim(1)
        idx = tempPMax{1,1}{n} < threshold(m);
        tempErrors{1,1}{n}(idx) = [];
        tempErrors{1,1}{n}(isnan(tempErrors{1,1}{n})) = [];
        pred_avg(n) = mean(tempErrors{1,1}{n}, 'all');
    end
    AVG(m) = mean(pred_avg);
end

% Plots average error per pmax threshold
figure(1)
plot(threshold,AVG)
xlabel('p-max threshold')
ylabel('AVG Error (mm)')
title('Average Error per Threshold')

%% Average Precision to Determine Best Pmax Threshold
clc;

% Thresholds
error_threshold = 10; %mm
pmax_threshold = 0.1:0.001:0.8;

% Initializing matrices
good = [];
bad = [];

% Determining matrix sizes for iterations
dim = size(Errors);
dim_pmax_threshold = size(pmax_threshold);

% Used for calculating the percentages of good and bad frames kept and
% removed based on different threshold values for error and pmax
for d = 1:dim_pmax_threshold(2)     % Looping through pmax thresholds
    good_frames = 0;
    bad_frames = 0;
    good_frames_removed = 0;
    bad_frames_removed = 0;
    for a = 1:dim(1)                % Looping through cell arrays
        dim_internal = size(Errors{a,1});
        for b = 1:dim_internal(1)   % Looping through rows of each matrix
            for c = 1:dim_internal(2)  % Looping through columns of each matrix
                if Errors{a,1}(b,c) <= error_threshold
                    good_frames = good_frames + 1;
                    if PMax{a,1}(b,c) < pmax_threshold(d)
                        good_frames_removed = good_frames_removed + 1;
                    end
                elseif Errors{a,1}(b,c) > error_threshold
                    bad_frames = bad_frames + 1;
                    if PMax{a,1}(b,c) < pmax_threshold(d)
                        bad_frames_removed = bad_frames_removed + 1;
                    end
                else
                    continue;
                end
            end
        end
    end
    % These values can be plotted to visualize the affect of each threshold
    percent_good(d) = (good_frames/(good_frames + bad_frames))*100;
    percent_bad(d) = (bad_frames/(good_frames + bad_frames))*100;
    percent_good_removed(d) = (good_frames_removed/good_frames)*100;
    percent_good_kept(d) = ((good_frames-good_frames_removed)/good_frames)*100;
    percent_bad_removed(d) = (bad_frames_removed/bad_frames)*100;
    percent_bad_kept(d) = ((bad_frames-bad_frames_removed)/bad_frames)*100;
    % good(d,1:2) = [percent_good_kept, percent_bad_removed];
    % bad(d,1:2) = [percent_good_removed, percent_bad_kept];
end

%% Imputation of New Coordinates Based on Thresholding
clc;

dim = size(Errors);

error_threshold = 5;
pmax_threshold = [0.01:0.01:0.8];

good_frames = 0;
bad_frames = 0;
good_frames_removed = 0;
bad_frames_removed = 0;

dim_pmax = size(pmax_threshold);

for p = 1:dim_pmax(2)
    for a = 1:dim(1)                % Looping through cell arrays
        dim_internal = size(Errors{a,1});
        count = 1;
        index = [];
        for b = 1:dim_internal(1)   % Looping through rows of each matrix
            for c = 1:dim_internal(2)  % Looping through columns of each matrix
                if Errors{a,1}(b,c) <= error_threshold
                    good_frames = good_frames + 1;
                    if PMax{a,1}(b,c) < pmax_threshold(p)
                        good_frames_removed = good_frames_removed + 1;
                        % Had to incorporate this step becuase I removed
                        % markers 7 and 8 which are the tail markers
                        if c < 7
                            index(count, 1:2) = [b, c];
                        else
                            index(count, 1:2) = [b, c+2];
                        end
                        count = count + 1;
                    end
                elseif Errors{a,1}(b,c) > error_threshold
                    bad_frames = bad_frames + 1;
                    if PMax{a,1}(b,c) < pmax_threshold(p)
                        bad_frames_removed = bad_frames_removed + 1;
                        % Had to incorporate this step becuase I removed
                        % markers 7 and 8 which are the tail markers
                        if c < 7
                            index(count, 1:2) = [b, c];
                        else
                            index(count, 1:2) = [b, c+2];
                        end
                        count = count + 1;
                    end
                else
                    continue;
                end
            end
        end
        Index{a,1} = index;
    end
    
    % Removing and Imputing New Marker Positions Based on Index
    
    dim = size(Index);
    
    % Pulling all the indices for the specified video
    for i = 1:dim(1) % Loop 18 times, 1 for each video
        dim_internal = size(Index{i,1});
        pred_file = load(thePredictionFiles(i,1).name);
        ground_file = load(theGroundFiles(i,1).name);
        temp_right_pred = pred_file.right_pred;
        for j = 1:dim_internal(1) % Loop through the index matrix for each video
            bad_coord_frame = Frame_ind{i,1}(Index{i,1}(j,1));
            bad_coord_marker = Index{i,1}(j,2);
            temp_right_pred(bad_coord_frame,:,bad_coord_marker) = nan;
        end
        % This line is where the imputation occurs, can use different
        % imputation methods for different results
        fixed_right_pred = fillmissing(temp_right_pred, 'linear', 1);
        new_error = [];
        for k = 1:length(Frame_ind{i,1})
            GroundT_data = FormatRowData(ground_file.labelData{1,1}.data_3d(k,:));
            Prediction_data = FormatPredData(fixed_right_pred(Frame_ind{i,1}(k,1),:,:));
            
            dim_gtdata = size(GroundT_data);
            for m = 1:dim_gtdata(1)
                new_error(k,m) = norm(GroundT_data(m,:)-Prediction_data(m,:));
            end
        end
        New_Errors{i,1} = new_error;
    end
    
    % Removing both tail markers from Errors and PMax cell arrays
    dim_new_errors = size(New_Errors);
    for h = 1:dim_new_errors(1)
        New_Errors{h}(:,7:8) = [];
    end
end

% Comparing old errors to new errors
% for n = 1:dim_new_errors(1)
%     Compare_Errors{n} = Errors{n}-New_Errors{n};
% end

% Comparing Errors
% for i = 1:length(Compare_Errors)
%     s = sign(Compare_Errors{i});
%     better(i) = sum(s(:) == 1);
%     worse(i) = sum(s(:) == -1);
% end
% total_better = sum(better);
% total_worse = sum(worse);
% total_unchanged = (bad_frames_removed + good_frames_removed) - (total_better + total_worse);
% total_better
% total_worse
% total_unchanged

%% Histograms (not necessary to run)
% Just a visualization section I used to mess around with and view the data
% This section can be deleted if you want to visualize the data in some
% other way
figure(1)
histogram(Errors{7})
hold on
histogram(New_Errors{7})
legend("Old Errors", "New Errors")
xlabel("Errors (mm)")
ylabel("Count")
title("Histogram of Errors for Imputation")
avg_old_error = mean(mean(Errors{7}, 'omitnan'))
avg_new_error = mean(mean(New_Errors{7}, 'omitnan'))
% n = 1;
% for i = 1:size(Errors)
%     dim = size(Errors{i});
%     for j = 1:dim(1)
%         E(1,n:n+19) = Errors{i}(j,:);
%         n = n + 20;
%     end
% end
% figure(1)
% avg_error = mean(E, 'omitnan')
% histogram(E)
% hold on
% xline(avg_error, 'LineWidth', 1.5)
% 
% n = 1;
% for i = 1:size(New_Errors)
%     dim = size(New_Errors{i});
%     for j = 1:dim(1)
%         New_E(1,n:n+19) = New_Errors{i}(j,:);
%         n = n + 20;
%     end
% end
% figure(2)
% new_avg_error = mean(New_E, 'omitnan')
% histogram(New_E)
% hold on
% xline(new_avg_error, 'LineWidth', 1.5)

%% Plotting (not necessary to use this section)
% This section was used for plotting purposes only to better visualize the
% results of the calculations from above
% I'm going to leave all of them just in case they might be useful to see.
% If you want to use this section, make sure to run the calculation section
% above that corresponds to the variables you want to plot
% Feel free to get rid of this section if you would rather plot within the
% sections above

plot(pmax_threshold, new_avg)
xlabel("P-Max Threshold")
ylabel("Error (mm)")
title("Error for Imputing New Marker Coordinates (PChip)")
% figure(1)
% plot(pmax_threshold, percent_good_kept)
% hold on
% plot(pmax_threshold, percent_bad_removed)
% xlabel('PMax Threshold')
% ylabel('Percent (%)')
% legend('% Good Kept', '% Bad Removed')
% title('Accuracy of Thresholding')



% Printing percentages to the screen
% fprintf("Accuracy of Error Thresholding:\n")
% fprintf("Percent Good Frames: %3.1f %%\n", percent_good)
% fprintf("Percent Bad Frames: %3.1f %%\n", percent_bad)
% fprintf("\n")
% fprintf("Accuracy of PMax Thresholding in terms of Error Thresholding:\n")
% fprintf("Percent Good Frames Kept: %3.1f %%\n", percent_good_kept)
% fprintf("Percent Bad Frames Removed: %3.1f %%\n", percent_bad_removed)
% fprintf("\n")
% fprintf("Inaccuracy of PMax Thresholding in terms of Error Thresholding:\n")
% fprintf("Percent Good Frames Removed: %3.1f %%\n", percent_good_removed)
% fprintf("Percent Bad Frames Kept: %3.1f %%\n", percent_bad_kept)

% Displaying percentage calculations in bar graph form
% figure(1)
% bar1 = bar(pmax_threshold, good);
% set(bar1, {'DisplayName'}, {'% Good Kept', '% Bad Removed'}')
% title('Accuracy of Pmax Thresholding')
% xlabel('Pmax Threshold')
% ylabel('Percentage (%)')
% legend()
% 
% figure(2)
% bar2 = bar(pmax_threshold, bad);
% set(bar2, {'DisplayName'}, {'% Good Removed', '% Bad Kept'}')
% title('Inaccuracy of Pmax Thresholding')
% xlabel('Pmax Threshold')
% ylabel('Percentage (%)')
% legend()
% 
% figure(3)
% x = categorical({'% Good Frames', '% Bad Frames'});
% bar3 = bar(x,[percent_good, percent_bad]);
% title('Error Thresholding at 10 mm')
% ylabel('Percentage (%)')
% ylim([0,100])

%% Functions
% These are mini function I created for formatting purposes when doing
% calculation above
% Functions for formatting ground truth and prediction labels
function [row_data] = FormatRowData(data)
    n = 1;
    row_data = zeros([22,3]);
    for i = 1:22
        row_data(i,1:3) = data(1,n:n+2);
        n = n + 3;
    end
end

function [pred_data] = FormatPredData(input_data)
    for i = 1:22
        pred_data(i,1:3) = input_data(1,1:3,i);
    end
end

% Sigmoid function used for adjusting pmax within a 0 to 1 range
function [new_pmax] = SigmoidFunc(old_pmax)
    for i = 1:length(old_pmax)
        new_pmax(1,i) = 1/(1+exp(-old_pmax(i)));
    end
end



