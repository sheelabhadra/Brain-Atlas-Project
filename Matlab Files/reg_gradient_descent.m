% Convert templatePoints from float to int32
for i=1:size(templatePoints,1)
    templatePoints(i,1) = int32(templatePoints(i,1));
    templatePoints(i,2) = int32(templatePoints(i,2));
end

new_pts = zeros([20, 2]);

for pt=1:20
    temp = templatePoints(pt,1);
    new_pts(pt,1) = templatePoints(pt,2);
    new_pts(pt,2) = temp;
end

basePoints = templatePoints;
baseImage = imread('base_outer_edge.jpg');

alpha = 5*10^(-3);

% Gradient descent step
MaxIt = 20;

M = zeros([size(baseImage,1) size(baseImage,2), 3]);

for i=1:size(baseImage,1)
    for j=1:size(baseImage,2)
        nearest_coord = find_nearest_edge(baseImage, [i,j]);
        M(i,j,1) = (i - nearest_coord(1,1))^2;
        M(i,j,2) = (j - nearest_coord(1,2))^2;
        M(i,j,3) = M(i,j,1) + M(i,j,2); 
    end
end

disp("M completed")

figure(1);
hold on;

for it=1:MaxIt
    % Find the template after warping
    tform = fitgeotrans(basePoints,templatePoints,'lwm',size(basePoints,1));

    Wtemplate = imwarp(template,tform,'OutputView',imref2d(size(baseImage)));
    
    imshowpair(Wtemplate,baseImage)
    
    base_pts = zeros([20, 2]);

    for pt=1:20
        temp = basePoints(pt,1);
        base_pts(pt,1) = basePoints(pt,2);
        base_pts(pt,2) = temp;
    end
    
    for cp = 1:size(base_pts,1)
        [y, y1, y2] = Cost_Function(M, Wtemplate, new_pts(cp,:));
        base_pts(cp, 1) = int32(base_pts(cp, 1) - alpha*y*y1*10^(-11));
        base_pts(cp, 2) = int32(base_pts(cp, 2) - alpha*y*y2*10^(-11));
    end
    
    for pt=1:20
        temp = base_pts(pt,1);
        basePoints(pt,1) = base_pts(pt,2);
        basePoints(pt,2) = temp;
    end
    
    if rem(it, 5) == 0
        disp([it, y*10^(-11)])
    end
end

% tform = fitgeotrans(templatePoints, basePoints, 'lwm', 20);
% 
% Tregistered = imwarp(template,tform,'OutputView',imref2d(size(baseImage)));
% 
% 
% imshowpair(Tregistered,baseImage)

% Create a matrix to store the nearest distances to the baseImage edge from
% any pixel (warped template)

function coord = find_nearest_edge(img, TARGET)
    [row, col] = find(img);
    distances = 1000*ones([size(img,1), size(img,2)]);
    
    for i=1:size(row,1)
        distances(row(i),col(i)) = ((row(i) - TARGET(1))^2 + (col(i) - TARGET(2))^2)^2;
    end
    
    min_dist = min(distances(:));
    [near_row, near_col] = find(distances == min_dist);
    coord = [near_row, near_col];
end

% Find the L2 norm
function [C, C1, C2] = Cost_Function(M, warpedTemplate, templatePoints)
    ssd = 0;
    for i=1:size(warpedTemplate,1)
        for j=1:size(warpedTemplate,2)
            if warpedTemplate(i,j) > 0
                ssd = ssd + M(i,j,3);
            end
            
            if ismember(i, templatePoints(1)) && ismember(j, templatePoints(2))
                C1 = M(i,j,1);
                C2 = M(i,j,2);
            end
        end
    end
    
    C = ssd;
end
