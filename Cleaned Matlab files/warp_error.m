% Calculates warp error between warped skeleton and any skeleton
I = imread('More samples/0.74/20171110_D2CreAi14_M558_G_RB_pDMS_S1P1_R3C2_001.tif');
I = rgb2gray(I);

J = imread('More samples/0.74/23_AP_0.74.tif');
J = J(:,:,1:3);
J = rgb2gray(J);
J = bitcmp(J);
J = im2bw(J, 0.05);
J = im2double(J);

pl = 0; % Plots all the figures

tform = fitgeotrans(movingPoints, fixedPoints, 'polynomial', 2);
Imgregistered = imwarp(J,tform,'OutputView',imref2d(size(I)));

if pl
    figure;
    imshow(I);
    hold on;
    for i=1:size(fixedPoints,1)
        plot(fixedPoints(i,1), fixedPoints(i,2), 'r*', 'LineWidth', 1);
        text(fixedPoints(i,1), fixedPoints(i,2), num2str(i),'Color','green','FontSize',14);
    end
    hold off;

    figure;
    imshow(J);
    hold on;
    for i=1:size(movingPoints,1)
        plot(movingPoints(i,1), movingPoints(i,2), 'r*', 'LineWidth', 1);
        text(movingPoints(i,1), movingPoints(i,2), num2str(i),'Color','green','FontSize',14);
    end
    hold off;
    
    figure;
    imshowpair(Imgregistered,I)
end

movingPointsEstimated = transformPointsInverse(tform,fixedPoints);

points_list = [points38, points50, points62, movingPoints, points86, points98, points110];
err_list = zeros(size(points_list,2)/2, 1);

for i=1:size(points_list,2)/2
    err_list(i) = find_error(movingPointsEstimated, points_list(:,2*i-1:2*i));
end

figure;
plot(err_list, '-o','MarkerIndices', 1:size(points_list,2)/2);
title('Error vs Atlas AP# for AP# 0.74');
xlabel('AP Number');
xticklabels({'0.38','0.50','0.62','0.74','0.86','0.98','1.10'});
ylabel('Error (SSD)');
grid on;

function err = find_error(tfSkele, origSkele)
    err = norm(tfSkele-origSkele);
end