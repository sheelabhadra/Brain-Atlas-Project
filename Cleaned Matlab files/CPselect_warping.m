% template = imread('outer_edge.jpg');
% base = imread('base_outer_edge.jpg');
% % load('CP.mat');
% % I = imread('base_img_1.jpg');
% % J = imread('full_template.jpg');

I = imread('5 images and skeleton/20180614_D1CreSnap25_M96_G_RB_pDMS_Part1_R3C2_001.tif');
% I = imread('20170914_D2CreAi14_M527_G_RB_pDMS_S1P2_R1C3_001.tif');
I = rgb2gray(I);
I = imresize(I, 0.1, 'bicubic');
I = padarray(I,[50 50],0,'both');

% J = imread('actual_template.jpg');
% J = imread('28_AP_0.14.tif');
J = imread('5 images and skeleton/27_AP_0.14.tif');
J = J(:,:,1:3);
J = rgb2gray(J);
J = imresize(J, 0.1, 'bicubic');
J = bitcmp(J);
J = im2bw(J, 0.05);
J = padarray(J,[50 50],0,'both');

% Lets you select the Control Points on both the images
% Save the Control Points in the work-space
% cpselect(J, I)

% Gives the transform
% tform = fitgeotrans(movingPoints, fixedPoints, 'polynomial', 2);
tform = fitgeotrans(fixedPoints1, movingPoints1, 'lwm', size(fixedPoints1,1));

% Use the transform to warp the atlas
% Jregistered = imwarp(J,tform,'OutputView',imref2d(size(I)));
Iregistered1 = imwarp(I,tform,'OutputView',imref2d(size(J)));

% figure;
% imshow(Jregistered)
% imwrite(Jregistered,'template_gray.jpg');

% figure;
% imshowpair(Jregistered,I)
figure;
imshowpair(Iregistered1,J)