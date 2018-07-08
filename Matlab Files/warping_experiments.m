% ### Playground for uniform CP selection ### %

template = imread('outer_edge.jpg');
base = imread('base_outer_edge.jpg');

I = imread('base_img_1.jpg');
J = imread('full_template.jpg');

templatePoints = uniform_cp_select(template, 8);
basePoints = uniform_cp_select(base, 8);

% Plot the CPs on the template
figure;
imshow(J);
hold on;
for i=1:8
    plot(templatePoints(i,1), templatePoints(i,2), 'c*', 'LineWidth', 1, 'MarkerSize', 10);
end
hold off;

% Plot the CPs on the base image
figure;
imshow(I);
hold on;
for i=1:8
    plot(basePoints(i,1), basePoints(i,2), 'r*', 'LineWidth', 1, 'MarkerSize', 10);
end
hold off;

% Gives the transform
tform = fitgeotrans(templatePoints, basePoints, 'polynomial', 2);

% Use the transform to warp the atlas
Tregistered = imwarp(J,tform,'OutputView',imref2d(size(I)));

% Plot the registered figures
figure;
imshowpair(Tregistered,I)