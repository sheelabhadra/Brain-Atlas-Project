% im2bw threshold values
% R3C2 - 0.02
% R3C3 - 0.03
% R3C4 - 0.03
% R3C5 - 0.03
% R4C1 - 0.02
% R4C2 - 0.03

%% Actual Base image registration
img = '20170914_D2CreAi14_M527_G_RB_pDMS_S1P2_R1C3_001.tif';
skele = '28_AP_0.14.tif';

sktoimg = 0; % False
plot = 0; % False
Iregistered1 = warp_image(img, skele, movingPoints, fixedPoints, sktoimg, plot);

%% Feature detection and matching
% Iregistered1 = histeq(Iregistered1);
base_full = Iregistered1;
se = strel('disk', 2);
% se = strel('line',3,10);
base_down = imdilate(base_full, se);

base_down_edges = edge(base_down,'Canny');

% Dilation, Erosion, Preprocessing
% se = strel('line',5,10);
% se = strel('disk',3);

corners1 = detectHarrisFeatures(base_down_edges);
[features1,valid_points1] = extractFeatures(base_down,corners1);

I = imread('5 images and skeleton/20180614_D1CreSnap25_M96_G_RB_pDMS_Part1_R3C2_001.tif');
I = rgb2gray(I);
I = imresize(I, 0.2, 'bicubic');
I = padarray(I,[50 50],0,'both');
% I = histeq(I);

% base_full_2 = imread('base_img_2.jpg');
base_full_2 = I;
base_down_2 = imdilate(base_full_2, se);

base_down_2_edges = edge(base_down_2,'Canny');

corners2 = detectHarrisFeatures(base_down_2_edges);
[features2,valid_points2] = extractFeatures(base_down_2,corners2);

% figure;
% imshow(base_down); hold on;
% plot(valid_points1)
% hold off;
% 
% figure;
% imshow(base_down_2); hold on;
% plot(valid_points2)
% hold off;

indexPairs = matchFeatures(features1,features2,'Method','SSD','Method','Exhaustive',...
    'MaxRatio',0.8,'Unique',true,'MatchThreshold',20);

matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);

% Discard points that are far away
% Remember that we only need the (X,Y) coordinates of the feature points
th_dist = 100;

img1_points = 0;
img2_points = 0;

for i=1:size(matchedPoints1.Location,1)
    if ((matchedPoints1.Location(i,1) - matchedPoints2.Location(i,1))^2 + ...
            (matchedPoints1.Location(i,2) - matchedPoints2.Location(i,2))^2)^0.5 < th_dist
        if img1_points == 0
            img1_points = matchedPoints1.Location(i,:);
            img2_points = matchedPoints2.Location(i,:);
        else
            img1_points = [img1_points; matchedPoints1.Location(i,:)];
            img2_points = [img2_points; matchedPoints2.Location(i,:)];
        end
    end
end

% SURF
surf_points = detectSURFFeatures(base_down,'MetricThreshold',100,...
    'NumOctaves',4,'NumScaleLevels',6);
% figure; imshow(base_down); hold on;
% plot(surf_points);

% SURF
surf_points_2 = detectSURFFeatures(base_down_2,'MetricThreshold',100,...
    'NumOctaves',4,'NumScaleLevels',6);
% figure; imshow(base_down_2); hold on;
% plot(surf_points_2);

[features1,valid_points1] = extractFeatures(base_down,surf_points);
[features2,valid_points2] = extractFeatures(base_down_2,surf_points_2);

indexPairs = matchFeatures(features1,features2,'Method','SSD','Method','Exhaustive',...
    'MaxRatio',0.5,'Unique',true,'MatchThreshold',20);

matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);

for i=1:size(matchedPoints1.Location,1)
    if ((matchedPoints1.Location(i,1) - matchedPoints2.Location(i,1))^2 + ...
            (matchedPoints1.Location(i,2) - matchedPoints2.Location(i,2))^2)^0.5 < th_dist
            img1_points = [img1_points; matchedPoints1.Location(i,:)];
            img2_points = [img2_points; matchedPoints2.Location(i,:)];
    end
end

figure; 
showMatchedFeatures(base_down,base_down_2,img1_points,img2_points);

% %% Outer boundary extraction
% img = imread('5 images and skeleton/20180614_D1CreSnap25_M96_G_RB_pDMS_Part1_R3C2_001.tif');
% img = rgb2gray(img);
% BW = im2bw(img, 0.03);
% % BW = imbinarize(img);
% 
% se = strel('square', 3);
% BW = imdilate(BW,se);
% 
% % figure;
% % imshow(BW)
% 
% binaryImage = imfill(BW, 'holes');
% binaryImage = imerode(binaryImage,se);
% 
% % Find the contour with largest area
% s = regionprops(binaryImage, 'Area', 'PixelList');
% [~,ind] = max([s.Area]);
% pix = sub2ind(size(binaryImage), s(ind).PixelList(:,2), s(ind).PixelList(:,1));
% out = zeros(size(binaryImage));
% out(pix) = binaryImage(pix);
% 
% % figure;
% % imshow(out)
% 
% out = imresize(out, 0.1, 'bicubic');
% out = padarray(out,[50 50],0,'both');
% 
% % figure;
% % imshow(binaryImage)
%  
% boundaries = edge(out, 'Canny');
% base = boundaries;
% % figure;
% % imshowpair(boundaries, out)
% 
% % Template Skeleton
% % J = imread('28_AP_0.14.tif');
% J = imread('5 images and skeleton/27_AP_0.14.tif');
% J = J(:,:,1:3);
% J = rgb2gray(J);
% % J = imread('actual_template.jpg');
% J = imresize(J, 0.1, 'bicubic');
% J = bitcmp(J);
% J = padarray(J,[50 50],0,'both');
% 
% % Base Image
% K = Iregistered1;
% BW = im2bw(K, 0.02);
% se = strel('square', 3);
% BW = imdilate(BW,se);
% 
% binaryImage = imfill(BW, 'holes');
% binaryImage = imerode(binaryImage,se);
% boundaries = edge(binaryImage, 'Canny');
% template = boundaries; % Extract outer edge of the template
% 
% % figure;
% % imshow(template)
% 
% % figure;
% % imshow(base)
% 
% nPoints = 16 + size(img1_points,1);
% 
% templatePoints = uniform_cp_select(template, 16);
% basePoints = uniform_cp_select(base, 16);
% 
% % basePoints(2,2) = basePoints(2,2) - 5;
% basePoints(3,2) = basePoints(3,2) - 5;
% basePoints(4,1) = basePoints(4,1) + 5;
% basePoints(5,1) = basePoints(5,1) + 5;
% basePoints(6,1) = basePoints(6,1) + 5;
% basePoints(7,2) = basePoints(7,2) + 10;
% basePoints(8,2) = basePoints(8,2) + 10;
% basePoints(10,2) = basePoints(10,2) + 10;
% basePoints(11,2) = basePoints(11,2) + 10;
% basePoints(12,1) = basePoints(12,1) - 5;
% basePoints(13,1) = basePoints(13,1) - 5;
% basePoints(14,1) = basePoints(14,1) - 5;
% basePoints(15,2) = basePoints(15,2) - 5;
% basePoints(16,2) = basePoints(16,2) - 5;
% 
% % Add the points from feature matching
% for i=1:size(img1_points,1)
%     basePoints(nPoints-size(img1_points,1)+i,1) = int32(img2_points(i,1));
%     basePoints(nPoints-size(img1_points,1)+i,2) = int32(img2_points(i,2));
%     
%     templatePoints(nPoints-size(img1_points,1)+i,1) = int32(img1_points(i,1));
%     templatePoints(nPoints-size(img1_points,1)+i,2) = int32(img1_points(i,2));
% end
% 
% % figure;
% % imshow(J);
% % hold on;
% % for i=1:nPoints
% %     plot(templatePoints(i,1), templatePoints(i,2), 'c*', 'LineWidth', 2, 'MarkerSize', 20);
% % end
% % hold off;
% 
% figure;
% imshow(K);
% hold on;
% for i=1:nPoints
%     plot(templatePoints(i,1), templatePoints(i,2), 'c*', 'LineWidth', 2, 'MarkerSize', 20);
% end
% hold off;
% 
% figure;
% imshow(I);
% hold on;
% for i=1:nPoints
%     plot(basePoints(i,1), basePoints(i,2), 'r*', 'LineWidth', 2, 'MarkerSize', 20);
% end
% hold off;
% 
% % Gives the transform
% tform = fitgeotrans(templatePoints, basePoints, 'polynomial', 2);
% % tform = fitgeotrans(templatePoints, basePoints, 'lwm', nPoints);
% % tform = fitgeotrans(templatePoints, basePoints, 'pwl');
% 
% % Use the transform to warp the atlas
% Tregistered = imwarp(J,tform,'OutputView',imref2d(size(I)));
% 
% figure;
% imshowpair(Tregistered,I)