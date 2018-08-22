% Script to perform manual control point selection and counting
%% Data
base = 'More samples/0.74/20171109_D2CreAi14_M671_G_RB_pDMS_S1P1_R3C1_001.tif';
skeleton = 'More samples/0.74/23_AP_0.74.tif';
APnum = 74;
neuron_img = 'More samples/0.74/20171109_D2CreAi14_M671_G_RB_pDMS_S1P1_R3C1_002.tif';
load('30_Counting Project/Data/Skeletons_mat/0.74-R.mat');
orig_coords = s;

%% Flags
sktoimg = 1;
pl = 0;
saved_cps = 1;

%% Registration
% Manually select control points on the base image and the skeleton
% To select new control points use cpselect_warp()
% If the control points have been saved beforehand, use warp_image()

if saved_cps
    [Imregistered, tform] = warp_image(base, skeleton, movingPoints74_1, fixedPoints74_1, sktoimg, pl);
else
    [Imregistered, tform] = cpselect_warp(base, skeleton, sktoimg, pl);
end

%% Counting
% Count the number of neurons in each region
[count, totalCount] = count_neurons(tform, skeleton, neuron_img, orig_coords, APnum);
