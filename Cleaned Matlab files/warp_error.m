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

[Y, X] = size(I);

points_list = [points14, points26, points38, points50, points62, points74, points86, points98, points110, points118, points134];
scaleFactor = [1/3118, 1/2242; 1/3060, 1/2044; 1/3081, 1/2064; 1/2965, 1/1999; 1/2874 1/2022; 1/2838 1/2023; 1/2751 1/1956; 1/2690, 1/1976; 1/2606, 1/1920; 1/2619, 1/1911; 1/2495, 1/1888].*[X, Y];
err_list = zeros(size(points_list,2)/2, 1);

% figure;
% imshow(I);
% hold on;
% for i=1:size(points74,1)
%     plot(points134(i,1), points134(i,2), 'r*', 'LineWidth', 1);
%     text(points134(i,1), points134(i,2), num2str(i),'Color','green','FontSize',14);
% end
% for i=1:size(base74,1)
%     plot(base74(i,1), base74(i,2), 'r*', 'LineWidth', 1);
%     text(base74(i,1), base74(i,2), num2str(i),'Color','yellow','FontSize',14);
% end
% hold off;

for i=1:size(points_list,2)/2
%     err_list(i) = find_error(movingPointsEstimated, points_list(:,2*i-1:2*i));
    new_points_list = points_list(:,2*i-1:2*i).*[scaleFactor(i,1), scaleFactor(i,2)];
    err_list(i) = find_error(base74, new_points_list);
end

figure;
plot(err_list, '-o','MarkerIndices', 1:size(points_list,2)/2);
title('Error vs Atlas AP# for AP# 0.74');
xlabel('AP Number');
xticklabels({'0.14', '0.26','0.38','0.50','0.62','0.74','0.86','0.98','1.10', '1.18', '1.34'});
ylabel('Error (SSD)');
grid on;

function err = find_error(tfSkele, origSkele)
    err = norm(tfSkele-origSkele);
end