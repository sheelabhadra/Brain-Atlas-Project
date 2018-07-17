% base_full = imresize(rgb2gray(imread('full_color_base.jpg')),0.25);
base_lines = imread('base_edge.jpg');
% base_full = imread('full_template_simplified.jpg');

base_full = imread('template_gray.jpg');
% base_full = rgb2gray(template);

% base_full = imread('base_img_1.jpg');

% Dilation, Erosion, Preprocessing
se = strel('line',5,10);

base_down = imdilate(base_full, se);

% base_down = imerode(base_full, se);

% HOG Feature Detection
% cellSize = 8;
% hog_base = vl_hog(im2single(base_full), cellSize, 'verbose', 'numOrientations',3);
% imhog_base = vl_hog('render',hog_base, 'verbose', 'numOrientations',3);
% figure; hold on;
% clf; imagesc(imhog_base); colormap gray;
% hold off;

% MSER Feature Detection
% full_trans = uint8(base_down);
% [full_regions, frames] = vl_mser(full_trans,'MinDiversity',.2,...
%                                     'MaxVariation',1, 'Delta', 7,'BrightOnDark',1,...
%                                     'MinArea',3/300);
% frames = vl_ertr(frames);
% figure;  hold on; imshow(base_down); 
% vl_plotframe(frames);
% hold off;

% SIFT
% [frames, descrs] = vl_sift(im2single(base_down), 'FirstOctave',4);
% figure; hold on; imshow(base_down);
% vl_plotframe(frames);
% hold off;

% SURF
surf_points = detectSURFFeatures(base_down,'MetricThreshold',200,...
    'NumOctaves',4,'NumScaleLevels',6);
figure; imshow(base_down); hold on;
plot(surf_points);

base_full_2 = imread('base_img_1.jpg');
base_down_2 = imdilate(base_full_2, se);

% base_full_2 = imread('edited_template.jpg');
% base_down_2 = rgb2gray(base_full_2);
% base_down_2 = imresize(base_down_2, [255 408]);
% base_down_2 = imdilate(base_down_2, se);

% SURF
surf_points_2 = detectSURFFeatures(base_down_2,'MetricThreshold',200,...
    'NumOctaves',4,'NumScaleLevels',6);
figure; imshow(base_down_2); hold on;
plot(surf_points_2);

[features1,valid_points1] = extractFeatures(base_down,surf_points);
[features2,valid_points2] = extractFeatures(base_down_2,surf_points_2);

indexPairs = matchFeatures(features1,features2,'Method','SSD','Method','Exhaustive',...
    'MaxRatio',0.5,'Unique',true,'MatchThreshold',10);

matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);

% Discard points that are far away
% Remember that we only need the (X,Y) coordinates of the feature points

th_dist = 30;

img1_points = 0;
img2_points = 0;

for i=1:size(matchedPoints1.Location,1)
    if ((matchedPoints1.Location(i,1) - matchedPoints2.Location(i,1))^2 + ...
            (matchedPoints1.Location(i,1) - matchedPoints2.Location(i,1))^2)^0.5 < th_dist
        if img1_points == 0
            img1_points = matchedPoints1.Location(i,:);
            img2_points = matchedPoints2.Location(i,:);
        else
            img1_points = [img1_points; matchedPoints1.Location(i,:)];
            img2_points = [img2_points; matchedPoints2.Location(i,:)];
        end
    end
end

figure; 
showMatchedFeatures(base_down,base_down_2,img1_points,img2_points);
