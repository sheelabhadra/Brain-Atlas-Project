function point = get_rand_point(params)
    n = params.n; % number of points that you want
    center = params.center; % center coordinates of the circle [x0,y0] 
    radius = params.radius; % radius of the circle
    angle = 2*pi*rand(n,1);
    r = radius*sqrt(rand(n,1));
    X = double(r.*cos(angle)+ center(1));
    Y = double(r.*sin(angle)+ center(2));
    point = [X Y];
end