function [std_points, base_points] = detect_features(standard_image, base_image, thres)
    % This function applies feature detection and matching between a standard image and a base image.
    % Harris corners and SURF are the 2 feature detectors used here.
    % The matched points are added to the list of control points for registration.
    
    % NOTE: Please ensure that the base image contains only the brain image
    % of interest. Remove all spurious images present around the brain image.
    % Some parameters in matchFeatures() might need manual tuning.
    
    % INPUTS:
    % standard_image: the standard image for the AP/ the warped representative base image
    % base_image: path to the baase image
    % thres: threshold distance for feature matching
    
    % OUTPUTS:
    % std_points: control points on the standard image
    % base_points: control points on the base image
    
    std = imresize(standard_image, 0.1, 'bicubic'); % Resize the standard image to remove details
    se = strel('disk', 2); % structuring element
    
    % Structuring elements - candidates
    % se = strel('line',5,10);
    % se = strel('disk',3);
    % se = strel('line',3,10);
    
    std_dilated = imdilate(std, se);
    std_dilated_edges = edge(std_dilated,'Canny');
    
    base = imread(base_image);
    base = rgb2gray(base);
    base = imresize(base, 0.1, 'bicubic');
    
    base_dilated = imdilate(base, se);
    base_dilated_edges = edge(base_dilated,'Canny');
    
    % Extract Harris corners on the standard image
    hcorners_std = detectHarrisFeatures(std_dilated_edges);
    [hfeatures_std,hvalid_points_std] = extractFeatures(std_dilated,hcorners_std);
    
    % Extract Harris corners on the base image
    hcorners_base = detectHarrisFeatures(base_dilated_edges);
    [hfeatures_base,hvalid_points_base] = extractFeatures(base_dilate,hcorners_base);
    
    % Harris feature matching
    hindexPairs = matchFeatures(hfeatures_std,hfeatures_base,'Method','SSD','Method','Exhaustive',...
        'MaxRatio',0.6,'Unique',true,'MatchThreshold',20);

    hmatchedPoints_std = hvalid_points_std(hindexPairs(:,1),:);
    hmatchedPoints_base = hvalid_points_base(hindexPairs(:,2),:);

    % Discard points that are far away
    th_dist = thres; % Set the threshold value for feature matching

    std_points = 0;
    base_points = 0;

    for i=1:size(hmatchedPoints_std.Location,1)
        if ((hmatchedPoints_std.Location(i,1) - hmatchedPoints_base.Location(i,1))^2 + ...
                (hmatchedPoints_std.Location(i,2) - hmatchedPoints_base.Location(i,2))^2)^0.5 < th_dist
            if std_points == 0
                std_points = hmatchedPoints_std.Location(i,:);
                base_points = hmatchedPoints_base.Location(i,:);
            else
                std_points = [std_points; hmatchedPoints_std.Location(i,:)];
                base_points = [base_points; hmatchedPoints_base.Location(i,:)];
            end
        end
    end

    % Extract SURF features on the standard image
    surf_points_std = detectSURFFeatures(std_dilated,'MetricThreshold',100,...
        'NumOctaves',4,'NumScaleLevels',6);
    [surffeatures_std,surfvalid_points_std] = extractFeatures(std_dilated,surf_points_std);
    
    % Extract SURF features on the base image
    surf_points_base = detectSURFFeatures(base_dilated,'MetricThreshold',100,...
        'NumOctaves',4,'NumScaleLevels',6);
    [surffeatures_base,surfvalid_points_base] = extractFeatures(base_dilated,surf_points_base);
    
    % SURF feature matching
    surfindexPairs = matchFeatures(surffeatures_std,surffeatures_base,'Method','SSD','Method','Exhaustive',...
        'MaxRatio',0.5,'Unique',true,'MatchThreshold',20);

    surfmatchedPoints_std = surfvalid_points_std(surfindexPairs(:,1),:);
    surfmatchedPoints_base = surfvalid_points_base(surfindexPairs(:,2),:);

    for i=1:size(surfmatchedPoints_std.Location,1)
        if ((surfmatchedPoints_std.Location(i,1) - surfmatchedPoints_base.Location(i,1))^2 + ...
                (surfmatchedPoints_std.Location(i,2) - surfmatchedPoints_base.Location(i,2))^2)^0.5 < th_dist
            if std_points == 0
                std_points = surfmatchedPoints_std.Location(i,:);
                base_points = surfmatchedPoints_base.Location(i,:);
            else
                std_points = [std_points; surfmatchedPoints_std.Location(i,:)];
                base_points = [base_points; surfmatchedPoints_base.Location(i,:)];
            end
        end
    end
    
    % Uncomment the lines below to visualize the points obtained after feature matching
%     figure;
%     showMatchedFeatures(std_dilated, base_dilated, std_points, base_points);
end