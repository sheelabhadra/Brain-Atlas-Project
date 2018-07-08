% Using CP-Select

J = imread('outer_edge.jpg');
I = imread('base_outer_edge.jpg');

% Lets you select the Control Points on both the images
% Save the Control Points in the work-space
cpselect(J, I)