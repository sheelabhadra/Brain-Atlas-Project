function [Imgregistered,tform] = warp_image(image, skeleton, movingPoints, fixedPoints, sktoimg, pl)
    % This function calculates the transformation function from control
    % points saved beforehand and applies the transformation function to
    % an image to warp it
    
    % INPUTS:
    % image: path to the base image
    % skeleton: path to the template or atlas
    % movingPoints: control points on the atlas
    % fixedPoints: control points on the base image
    % sktoimg: 1 - if fitting skeleton to the base image
    %          0 - if fitting base image to the skeleton
    % pl: 1 - plot registered image
    %     0 - do not plot registered image 

    % OUTPUTS:
    % Imgregistered: the registered/warped skeleton
    % tform: the transformation function
    
    % Read the base image
    I = imread(image);
    I = rgb2gray(I);

    % Reads the skeleton and resizes it
    J = imread(skeleton);
    J = J(:,:,1:3);
    J = rgb2gray(J);
    J = bitcmp(J);
    J = im2bw(J, 0.05);
    J = im2double(J);

    %% Registration
    %% if fitting skeleton to image
    if sktoimg
        tform = fitgeotrans(movingPoints, fixedPoints, 'polynomial', 2);
%         tform = fitgeotrans(movingPoints, fixedPoints, 'lwm', size(fixedPoints,1));
        Imgregistered = imwarp(J,tform,'OutputView',imref2d(size(I)));
        
        if pl
            figure;
            imshowpair(Imgregistered,I)
        end

    %% if fitting image to skeleton
    else
        tform = fitgeotrans(fixedPoints, movingPoints, 'polynomial', 2);
        Imgregistered = imwarp(I,tform,'OutputView',imref2d(size(J)));
        
        if pl
            figure;
            imshowpair(Imgregistered,J)
        end
    end
end