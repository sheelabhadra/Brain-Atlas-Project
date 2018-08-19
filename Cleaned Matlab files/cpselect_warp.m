function [Imregistered, tform] = cpselect_warp(image, skeleton, sktoimg, pl)
    % This function allows the manual selection of control points using the
    % cpselect tool and then applies the transfromation function on an 
    % image to warp it
    
    % INPUTS:
    % image: path to the base image
    % skeleton: path to the template or atlas
    % sktoimg: 1 - if fitting skeleton to the base image
    %          0 - if fitting base image to the skeleton
    % pl: 1 - plot registered image
    %     0 - do not plot registered image 

    % OUTPUTS:
    % Imregistered: the registered/warped skeleton
    % tform: the transformation function

    % Read the base image
    I = imread(image);
    I = rgb2gray(I);

    % Read the skeleton
    J = imread(skeleton);
    J = J(:,:,1:3);
    J = rgb2gray(J);
    J = bitcmp(J);
    J = im2bw(J, 0.05);
    J = im2double(J);

    %% Control point selection
    % Lets you select the Control Points on both the images
    [movingPoints, fixedPoints] = cpselect(J, I, 'Wait', true); % Uncomment to access the Control Point selection tool

    %% if fitting skeleton to image
    if sktoimg
        tform = fitgeotrans(movingPoints, fixedPoints, 'polynomial', 2);
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