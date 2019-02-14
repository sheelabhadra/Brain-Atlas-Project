%% Matlab + Python code
% % base_full = imresize(rgb2gray(imread('full_color_base.jpg')),0.25);
% base_lines = imread('base_edge.jpg');
% % base_full = imread('full_template_simplified.jpg');
% 
% base_full = imread('template_gray.jpg');
% % base_full = rgb2gray(template);
% 
% % base_full = imread('base_img_1.jpg');
% % base_full = histeq(base_full);
% se = strel('disk',2);
% % se = strel('line',3,10);
% base_down = imdilate(base_full, se);
% % base_down = im2bw(base_down, 0.2);
% 
% base_down_edges = edge(base_down,'Canny');
% 
% % Dilation, Erosion, Preprocessing
% % se = strel('line',5,10);
% % se = strel('disk',3);
% 
% corners1 = detectHarrisFeatures(base_down_edges);
% % corners1 = detectBRISKFeatures(base_down);
% [features1,valid_points1] = extractFeatures(base_down,corners1);
% 
% % figure;
% % imshow(base_down); hold on;
% % plot(valid_points1)
% % % plot(corners.selectStrongest(200));
% % hold off;
% 
% % base_down = imerode(base_full, se);
% 
% % HOG Feature Detection
% % cellSize = 8;
% % hog_base = vl_hog(im2single(base_full), cellSize, 'verbose', 'numOrientations',3);
% % imhog_base = vl_hog('render',hog_base, 'verbose', 'numOrientations',3);
% % figure; hold on;
% % clf; imagesc(imhog_base); colormap gray;
% % hold off;
% 
% % MSER Feature Detection
% % full_trans = uint8(base_down);
% % [full_regions, frames] = vl_mser(full_trans,'MinDiversity',.2,...
% %                                     'MaxVariation',1, 'Delta', 7,'BrightOnDark',1,...
% %                                     'MinArea',3/300);
% % frames = vl_ertr(frames);
% % figure;  hold on; imshow(base_down); 
% % vl_plotframe(frames);
% % hold off;
% 
% % SIFT
% % [frames, descrs] = vl_sift(im2single(base_down), 'FirstOctave',4);
% % figure; hold on; imshow(base_down);
% % vl_plotframe(frames);
% % hold off;
% 
% base_full_2 = imread('base_img_2.jpg');
% base_down_2 = imdilate(base_full_2, se);
% % base_down_2 = imdilate(base_down_2, se);
% % base_down_2 = im2bw(base_down_2, 0.2);
% 
% % figure;
% % imshow(base_down)
% % 
% % figure;
% % imshow(base_down_2)
% 
% base_down_2_edges = edge(base_down_2,'Canny');
% 
% corners2 = detectHarrisFeatures(base_down_2_edges);
% % corners2 = detectBRISKFeatures(base_down_2);
% [features2,valid_points2] = extractFeatures(base_down_2,corners2);
% 
% % figure;
% % imshow(base_down_2); hold on;
% % plot(valid_points2)
% % hold off;
% 
% % base_full_2 = imread('edited_template.jpg');
% % base_down_2 = rgb2gray(base_full_2);
% % base_down_2 = imresize(base_down_2, [255 408]);
% % base_down_2 = imdilate(base_down_2, se);
% 
% indexPairs = matchFeatures(features1,features2,'Method','SSD','Method','Exhaustive',...
%     'MaxRatio',0.8,'Unique',true,'MatchThreshold',20);
% 
% matchedPoints1 = valid_points1(indexPairs(:,1),:);
% matchedPoints2 = valid_points2(indexPairs(:,2),:);
% 
% % Discard points that are far away
% % Remember that we only need the (X,Y) coordinates of the feature points
% 
% th_dist = 30;
% 
% img1_points = 0;
% img2_points = 0;
% 
% for i=1:size(matchedPoints1.Location,1)
%     if ((matchedPoints1.Location(i,1) - matchedPoints2.Location(i,1))^2 + ...
%             (matchedPoints1.Location(i,2) - matchedPoints2.Location(i,2))^2)^0.5 < th_dist
%         if img1_points == 0
%             img1_points = matchedPoints1.Location(i,:);
%             img2_points = matchedPoints2.Location(i,:);
%         else
%             img1_points = [img1_points; matchedPoints1.Location(i,:)];
%             img2_points = [img2_points; matchedPoints2.Location(i,:)];
%         end
%     end
% end
% 
% % SURF
% surf_points = detectSURFFeatures(base_down,'MetricThreshold',100,...
%     'NumOctaves',4,'NumScaleLevels',6);
% % figure; imshow(base_down); hold on;
% % plot(surf_points);
% 
% % SURF
% surf_points_2 = detectSURFFeatures(base_down_2,'MetricThreshold',100,...
%     'NumOctaves',4,'NumScaleLevels',6);
% % figure; imshow(base_down_2); hold on;
% % plot(surf_points_2);
% 
% [features1,valid_points1] = extractFeatures(base_down,surf_points);
% [features2,valid_points2] = extractFeatures(base_down_2,surf_points_2);
% 
% indexPairs = matchFeatures(features1,features2,'Method','SSD','Method','Exhaustive',...
%     'MaxRatio',0.5,'Unique',true,'MatchThreshold',30);
% 
% matchedPoints1 = valid_points1(indexPairs(:,1),:);
% matchedPoints2 = valid_points2(indexPairs(:,2),:);
% 
% for i=1:size(matchedPoints1.Location,1)
%     if ((matchedPoints1.Location(i,1) - matchedPoints2.Location(i,1))^2 + ...
%             (matchedPoints1.Location(i,2) - matchedPoints2.Location(i,2))^2)^0.5 < th_dist
%             img1_points = [img1_points; matchedPoints1.Location(i,:)];
%             img2_points = [img2_points; matchedPoints2.Location(i,:)];
%     end
% end
% 
% figure; 
% showMatchedFeatures(base_down,base_down_2,img1_points,img2_points);


%% Matlab standalone

% base_full = imread('template_gray.jpg');
% base_full = Iregistered;
% base_full = Iregistered1;
% base_full = rgb2gray(template);

reference_images = {'../Data/AP-image-data/train/-0.22/01.jpg';
    '../Data/AP-image-data/train/-0.46/01.jpg';
    '../Data/AP-image-data/train/-0.94/01.jpg';
    '../Data/AP-image-data/train/-1.06/01.jpg';
    '../Data/AP-image-data/train/-1.94/01.jpg';
    '../Data/AP-image-data/train/0.02/01.jpg';
    '../Data/AP-image-data/train/0.38/01.jpg';
    '../Data/AP-image-data/train/0.86/04.jpg';
    '../Data/AP-image-data/train/1.54/01.jpg';
    '../Data/AP-image-data/train/2.58/02.jpg'};

reference_images = string(reference_images);

query_image = '../Data/AP-image-data/train/-0.46/02.jpg';

candidates = {};
feature_match_points = [];
feature_match_points_size = [];

for ap=1:size(reference_images, 1)
    base_full = imread(reference_images(ap));
    base_full = base_full(:,:,1);
    base_full = imresize(base_full, 0.2, 'bicubic');

    % base_full = imread('base_img_1.jpg');
    % base_full = histeq(base_full);
    se = strel('disk', 2);
    % se = strel('line',3,10);
    base_down = imdilate(base_full, se);
    % base_down = im2bw(base_down, 0.2);

    base_down_edges = edge(base_down,'Canny');

    % Dilation, Erosion, Preprocessing
    % se = strel('line',5,10);
    % se = strel('disk',3);

    corners1 = detectHarrisFeatures(base_down_edges);
    % corners1 = detectBRISKFeatures(base_down);
    [features1,valid_points1] = extractFeatures(base_down,corners1);

    I = imread(query_image);
    % I = imread('5 images and skeleton/20180614_D1CreSnap25_M96_G_RB_pDMS_Part1_R3C2_001.tif');
    % I = rgb2gray(I);
    I = I(:,:,1);
    I = imresize(I, 0.2, 'bicubic');
    % I = padarray(I,[50 50],0,'both');

    % base_full_2 = imread('base_img_2.jpg');
    base_full_2 = I;
    base_down_2 = imdilate(base_full_2, se);
    % base_down_2 = imdilate(base_down_2, se);
    % base_down_2 = imdilate(base_down_2, se);
    % base_down_2 = im2bw(base_down_2, 0.2);

    base_down_2_edges = edge(base_down_2,'Canny');

    corners2 = detectHarrisFeatures(base_down_2_edges);
    % corners2 = detectBRISKFeatures(base_down_2);
    [features2,valid_points2] = extractFeatures(base_down_2,corners2);

    % figure;
    % imshow(base_down_2); hold on;
    % plot(valid_points2)
    % hold off;

    % base_full_2 = imread('edited_template.jpg');
    % base_down_2 = rgb2gray(base_full_2);
    % base_down_2 = imresize(base_down_2, [255 408]);
    % base_down_2 = imdilate(base_down_2, se);

    indexPairs = matchFeatures(features1,features2,'Method','SSD','Method','Exhaustive',...
        'MaxRatio',0.6,'Unique',true,'MatchThreshold',20);

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
            if img1_points == 0
                img1_points = matchedPoints1.Location(i,:);
                img2_points = matchedPoints2.Location(i,:);
            else
                img1_points = [img1_points; matchedPoints1.Location(i,:)];
                img2_points = [img2_points; matchedPoints2.Location(i,:)];
            end
        end
    end
    
    % Add the reference image to the list of candidates if
    % #feature matches > threshold
    if size(img1_points,1) >= 5
        disp(reference_images(ap))
        candidates{end+1} = reference_images(ap);
        feature_match_points = [feature_match_points; img2_points];
        feature_match_points = [feature_match_points; img1_points];
        feature_match_points_size(end+1) = size(img1_points, 1);
    end
    
%     if img1_points
%         figure;
%         showMatchedFeatures(base_down,base_down_2,img1_points,img2_points);
%     end
end

% Save the candidates and coordinates
candidates = cell2table(candidates');
writetable(candidates,'../Localization/feature-points/candidates.csv');
csvwrite('../Localization/feature-points/feature_match_points.csv', feature_match_points);
csvwrite('../Localization/feature-points/feature_match_points_size.csv', feature_match_points_size');

