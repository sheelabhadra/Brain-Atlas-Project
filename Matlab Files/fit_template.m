% Run this script after generating the Control Points
% i.e. First run control_point_selection.m to generate
% movingPoints and fixedPoints

base = imread('base_img_1.jpg');
template = imread('full_template.jpg');

% tform = fitgeotrans(templatePoints, new_pts, 'lwm', 20); % - Actual program

tform = fitgeotrans(movingPoints, fixedPoints, 'polynomial', 2);

Jregistered = imwarp(template,tform,'OutputView',imref2d(size(base)));

figure(1)
imshowpair(Jregistered,base)