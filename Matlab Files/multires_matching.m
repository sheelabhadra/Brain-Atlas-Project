base_img = imread('base_img_2.jpg');
template = imread('outer_edge_template.jpg');

se = strel('square', 3);
base_img = imdilate(base_img,se);

% WTF!! Need to mess around with the values for different images
base_img = im2bw(base_img, 0.05); % Conversion to binary image

base_edges = edge(base_img, 'Canny', 0.1, 0.6);
BW = imdilate(base_edges,se);
binaryImage = imfill(BW, 'holes'); % Fill holes.
binaryImage = imerode(binaryImage,se);
boundaries = edge(binaryImage, 'Canny'); % Get list of (x,y) coordinates of outer perimeter

c = normxcorr2(template, boundaries);

figure(1)
imshow(c, [])
