% tform = fitgeotrans(templatePoints, new_pts, 'lwm', 20); % - Actual program

tform = fitgeotrans(movingPoints, fixedPoints, 'polynomial', 2);

Jregistered = imwarp(J,tform,'OutputView',imref2d(size(I)));

figure(1)
imshowpair(Jregistered,I)