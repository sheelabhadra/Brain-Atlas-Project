%% Image-Template pairs
% R3C3 - 31
% R3C4 - 33
% R3C2 - 27


%% Code
% template = imread('outer_edge.jpg');
% template = imread('template_gray_outer_edge.jpg');

% Template Gray
I = imread('20170913_D2CreAi14_M529_G_RB_pDMS_S1P2_R1C4_001.tif');
% I = imread('5 images and skeleton/20180614_D1CreSnap25_M96_G_RB_pDMS_Part1_R3C2_001.tif');
I = rgb2gray(I);
I = imresize(I, 0.1, 'bicubic');
I = padarray(I,[50 50],0,'both');

% Template Skeleton
J = imread('28_AP_0.14.tif');
% J = imread('5 images and skeleton/27_AP_0.14.tif');
J = J(:,:,1:3);
J = rgb2gray(J);
% J = imread('actual_template.jpg');
J = imresize(J, 0.1, 'bicubic');
J = bitcmp(J);
J = padarray(J,[50 50],0,'both');

% Base Image
K = Iregistered;
% K = Iregistered1;
% K = rgb2gray(K);
% K = imresize(K, 0.1);

% I = imread('base_img_2.jpg');
% J = imread('full_template.jpg');
% K = imread('template_gray.jpg');
BW = im2bw(I, 0.05);

se = strel('square', 3);
BW = imdilate(BW,se);

binaryImage = imfill(BW, 'holes');
binaryImage = imerode(binaryImage,se);
boundaries = edge(binaryImage, 'Canny');
base = boundaries; % Extract outer edge of the template

BW = im2bw(K, 0.07);
se = strel('square', 3);
BW = imdilate(BW,se);

binaryImage = imfill(BW, 'holes');
binaryImage = imerode(binaryImage,se);
boundaries = edge(binaryImage, 'Canny');
template = boundaries; % Extract outer edge of the template

% figure;
% imshow(template)
% 
% figure;
% imshow(base)

nPoints = 16 + size(img1_points,1);

templatePoints = uniform_cp_select(template, 16);
basePoints = uniform_cp_select(base, 16);

% basePoints(2,2) = basePoints(2,2) - 5;
basePoints(3,2) = basePoints(3,2) - 5;
basePoints(4,1) = basePoints(4,1) + 5;
basePoints(5,1) = basePoints(5,1) + 5;
basePoints(6,1) = basePoints(6,1) + 5;
basePoints(7,2) = basePoints(7,2) + 10;
basePoints(8,2) = basePoints(8,2) + 10;
basePoints(10,2) = basePoints(10,2) + 10;
basePoints(11,2) = basePoints(11,2) + 10;
basePoints(12,1) = basePoints(12,1) - 5;
basePoints(13,1) = basePoints(13,1) - 5;
basePoints(14,1) = basePoints(14,1) - 5;
basePoints(15,2) = basePoints(15,2) - 5;
basePoints(16,2) = basePoints(16,2) - 5;

% Add the points from feature matching
for i=1:size(img1_points,1)
    basePoints(nPoints-size(img1_points,1)+i,1) = int32(img2_points(i,1));
    basePoints(nPoints-size(img1_points,1)+i,2) = int32(img2_points(i,2));
    
    templatePoints(nPoints-size(img1_points,1)+i,1) = int32(img1_points(i,1));
    templatePoints(nPoints-size(img1_points,1)+i,2) = int32(img1_points(i,2));
end

% figure;
% imshow(J);
% hold on;
% for i=1:nPoints
%     plot(templatePoints(i,1), templatePoints(i,2), 'c*', 'LineWidth', 2, 'MarkerSize', 20);
% end
% hold off;

figure;
imshow(K);
hold on;
for i=1:nPoints
    plot(templatePoints(i,1), templatePoints(i,2), 'c*', 'LineWidth', 2, 'MarkerSize', 20);
end
hold off;

figure;
imshow(I);
hold on;
for i=1:nPoints
    plot(basePoints(i,1), basePoints(i,2), 'r*', 'LineWidth', 2, 'MarkerSize', 20);
end
hold off;

% Gives the transform
tform = fitgeotrans(templatePoints, basePoints, 'polynomial', 2);
% tform = fitgeotrans(templatePoints, basePoints, 'lwm', nPoints);
% tform = fitgeotrans(templatePoints, basePoints, 'pwl');

% Use the transform to warp the atlas
Tregistered = imwarp(J,tform,'OutputView',imref2d(size(I)));

figure;
imshowpair(Tregistered,I)