function angle_epf = find_angle_EPF(img)
    [Gx, Gy] = imgradientxy(img);
    [Gmag, Gdir] = imgradient(Gx, Gy);
    angle_epf = Gdir;
end