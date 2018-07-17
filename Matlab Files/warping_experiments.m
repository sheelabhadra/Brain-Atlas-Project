template = imread('outer_edge.jpg');
base = imread('base_outer_edge.jpg');

I = imread('base_img_1.jpg');
J = imread('full_template.jpg');
K = imread('template_gray.jpg');

nPoints = 25;

templatePoints = uniform_cp_select(template, nPoints);
basePoints = uniform_cp_select(base, nPoints);

% basePoints(2,2) = basePoints(2,2) - 5;
basePoints(3,2) = basePoints(3,2) - 5;
basePoints(4,1) = basePoints(4,1) + 5;
basePoints(5,1) = basePoints(5,1) + 5;
basePoints(6,1) = basePoints(6,1) + 5;
basePoints(7,2) = basePoints(7,2) + 5;
basePoints(8,2) = basePoints(8,2) + 5;
basePoints(10,2) = basePoints(10,2) + 5;
basePoints(11,2) = basePoints(11,2) + 5;
basePoints(12,1) = basePoints(12,1) - 5;
basePoints(13,1) = basePoints(13,1) - 5;
basePoints(14,1) = basePoints(14,1) - 5;
basePoints(15,2) = basePoints(15,2) - 5;
% basePoints(16,2) = basePoints(16,2) - 5;

% Add the points from feature matching
for i=1:9
    basePoints(nPoints-9+i,1) = int32(img2_points(i,1));
    basePoints(nPoints-9+i,2) = int32(img2_points(i,2));
    
    templatePoints(nPoints-9+i,1) = int32(img1_points(i,1));
    templatePoints(nPoints-9+i,2) = int32(img1_points(i,2));
end

figure;
imshow(J);
hold on;
for i=1:nPoints
    plot(templatePoints(i,1), templatePoints(i,2), 'c*', 'LineWidth', 2, 'MarkerSize', 30);
end
hold off;

figure;
imshow(K);
hold on;
for i=1:nPoints
    plot(templatePoints(i,1), templatePoints(i,2), 'c*', 'LineWidth', 2, 'MarkerSize', 30);
end
hold off;

figure;
imshow(I);
hold on;
for i=1:nPoints
    plot(basePoints(i,1), basePoints(i,2), 'r*', 'LineWidth', 2, 'MarkerSize', 30);
end
hold off;

% Gives the transform
tform = fitgeotrans(templatePoints, basePoints, 'polynomial', 2);

% Use the transform to warp the atlas
Tregistered = imwarp(J,tform,'OutputView',imref2d(size(I)));

figure;
imshowpair(Tregistered,I)