% Script to perform manual control point selection and counting
%% Data
base = 'More samples/0.74/20171109_D2CreAi14_M671_G_RB_pDMS_S1P1_R3C1_001.tif';
skeleton = 'More samples/0.74/23_AP_0.74.tif';
APnum = 74;
neuron_img = 'More samples/0.74/20171109_D2CreAi14_M671_G_RB_pDMS_S1P1_R3C1_002.tif';
load('30_Counting Project/Data/Skeletons_mat/0.74-R.mat');
orig_coords = s;

%% Flags
sktoimg = 0;
pl = 0;
saved_cps = 1;

%% Control Point selection
% Warp a standard image to create the template
if saved_cps
    [Imregistered, tform] = warp_image(base, skeleton, movingPoints74_1, fixedPoints74_1, sktoimg, pl);
else
    [Imregistered, tform] = cpselect_warp(base, skeleton, sktoimg, pl);
end

% Base Image
I = imread(base);
I = rgb2gray(I);
I = imresize(I, 0.1, 'bicubic');
I = padarray(I,[50 50],0,'both');
BW = im2bw(I, 0.05);

se = strel('square', 3);
BW = imdilate(BW,se);

binaryImage = imfill(BW, 'holes');
% Find the contour with largest area
s = regionprops(binaryImage, 'Area', 'PixelList');
[~,ind] = max([s.Area]);
pix = sub2ind(size(binaryImage), s(ind).PixelList(:,2), s(ind).PixelList(:,1));
out = zeros(size(binaryImage));
out(pix) = binaryImage(pix);
boundaries = edge(out, 'Canny');
base = boundaries; % Extract outer edge of the base image

% Template Skeleton
J = imread(skeleton);
J = J(:,:,1:3);
J = rgb2gray(J);
J = imresize(J, 0.1, 'bicubic');
J = bitcmp(J);
J = padarray(J,[50 50],0,'both');

% Template Image
K = Imregistered;
K = imresize(K, 0.1, 'bicubic');
K = padarray(K,[50 50],0,'both');
BW = im2bw(K, 0.05);

se = strel('square', 3);
BW = imdilate(BW,se);

binaryImage = imfill(BW,'holes');
% Find the contour with largest area
s = regionprops(binaryImage, 'Area', 'PixelList');
[~,ind] = max([s.Area]);
pix = sub2ind(size(binaryImage), s(ind).PixelList(:,2), s(ind).PixelList(:,1));
out = zeros(size(binaryImage));
out(pix) = binaryImage(pix);
boundaries = edge(out, 'Canny');
template = boundaries; % Extract outer edge of the base image

% Plots helpful for debugging and finding good parameters for BW thresholding

% figure;
% imshow(template)
% title('Template')
% 
% figure;
% imshow(base)
% title('Base')
% 
% figure;
% imshow(J)
% title('skeleton')

% Select control points on the outer edge
templatePoints_outer = uniform_cp_select(template, 16);
basePoints_outer = uniform_cp_select(base, 16);

% Plots helpful for checking the placement of control points on the outer boundary

% figure;
% imshow(template)
% hold on
% scatter(templatePoints_outer(:,1), templatePoints_outer(:,2))
% hold off
% 
% figure;
% imshow(base)
% hold on
% scatter(basePoints_outer(:,1), basePoints_outer(:,2))
% hold off

% % % % % basePoints(2,2) = basePoints(2,2) - 5;
% % % % basePoints(3,2) = basePoints(3,2) - 5;
% % % % basePoints(4,1) = basePoints(4,1) + 5;
% % % % basePoints(5,1) = basePoints(5,1) + 5;
% % % % basePoints(6,1) = basePoints(6,1) + 5;
% % % % basePoints(7,2) = basePoints(7,2) + 10;
% % % % basePoints(8,2) = basePoints(8,2) + 10;
% % % % basePoints(10,2) = basePoints(10,2) + 10;
% % % % basePoints(11,2) = basePoints(11,2) + 10;
% % % % basePoints(12,1) = basePoints(12,1) - 5;
% % % % basePoints(13,1) = basePoints(13,1) - 5;
% % % % basePoints(14,1) = basePoints(14,1) - 5;
% % % % basePoints(15,2) = basePoints(15,2) - 5;
% % % % basePoints(16,2) = basePoints(16,2) - 5;

% Control Points obtained via. Feature matching
% Make sure to discard the points that are outside the outer edges
[templatePoints_inner, basePoints_inner] = detect_features(Imregistered, base, 100);

nPoints = 16 + size(basePoints_inner,1);

% Combine the outer and inner control points
templatePoints = vertcat(templatePoints_outer, templatePoints_inner);
basePoints = vertcat(basePoints_outer, basePoints_inner);

% Multiply the control points by the scale factor 1/0.1 = 10 to get the
% control points in the original base image and template
templatePoints = 10.*templatePoints;
basePoints = 10.*basePoints;

%% Registration
sktoimg = 1;
pl = 1;
[Imregistered, tform] = warp_image(base, skeleton, templatePoints, basePoints, sktoimg, pl);

%% Counting
% Count the number of neurons in each region
[count, totalCount] = count_neurons(tform, skeleton, neuron_img, orig_coords, APnum);
