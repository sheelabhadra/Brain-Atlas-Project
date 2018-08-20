function cps = uniform_cp_select(img, nPoints)
    % This function allows the automatic placement of control points on the
    % outer boundary of an image.
    
    % NOTE: Please ensure that the outer boundary has been well extracted 
    % from the image. The image should not be rotated i.e. the major axis 
    % of the image should be parallel to the horizontal axis (x-axis)
    
    % INPUTS:
    % img: the binary image containing the outer boundary
    % nPoints: number of control points - 8/16
    
    % OUTPUTS:
    % cps: control points on the outer boundary
    
    [row, col] = find(img);
    center = [int32(mean(row)) int32(mean(col))];

    cps = zeros([4 2]);
    MaxIt = log(nPoints)/log(2) - 2;
    
    c1 = 0;
    c2 = 0;
    north = 0;
    south = 0;

    for i=1:size(img,1)
        if img(i,center(2)) > 0
            if i < 200
                north = north + i;
                c1 = c1 + 1;
            end

            if i > 200
                south = south + i;
                c2 = c2 + 1;
            end  
        end
    end

    north = int32(north/c1);
    south = int32(south/c2);
    N = [north center(2)];
    S = [south center(2)];

    c1 = 0;
    c2 = 0;
    west = 0;
    east = 0;

    for i=1:size(img,2)
        if img(center(1),i) > 0
            if i < 200
                west = west + i;
                c1 = c1 + 1;
            end

            if i > 200
                east = east + i;
                c2 = c2 + 1;
            end  
        end
    end

    west = int32(west/c1);
    east = int32(east/c2);
    W = [center(1) west];
    E = [center(1) east];
    
    cps(1,:) = N;
    cps(2,:) = E;
    cps(3,:) = S;
    cps(4,:) = W;
    
    it = 1;
    while it <= MaxIt
        temp = zeros(size(cps));
        
        for pt=1:size(cps,1)-1
            mid_pt = [int32((cps(pt,1) + cps(pt+1,1))/2) int32((cps(pt,2) + cps(pt+1,2))/2)];
            temp(pt,:) = find_perpendicular_point(img, row, col, mid_pt, cps(pt,:), cps(pt+1,:));
        end
        
        mid_pt = [int32((cps(size(cps,1),1) + cps(1,1))/2) int32((cps(size(cps,1),2) + cps(1,2))/2)];
        temp(size(cps,1),:) = find_perpendicular_point(img, row, col, mid_pt, cps(size(cps,1),:), cps(1,:));
        
        new = zeros([2^(it+1),2]);
        
        % Add temp to the CPs in the correct order
        for i=1:2^(it+1)
            new(2*i-1,:) = cps(i,:);
            new(2*i,:) = temp(i,:);
        end
        
        it = it+1;
        
        cps = new;
    end
    
    % Convert [row, col] format to [X, Y] format
    for pt=1:size(cps,1)
        cps(pt,:) = fliplr(cps(pt,:));
    end

end


function coord = find_perpendicular_point(img, row, col, TARGET, pt1, pt2)
    % Helper function to find the point on a straight line closest to another point
    
    m1 = double(pt1(1) - pt2(1))/double(pt2(2) - pt1(2));
    for i=1:size(row,1)
        m2 = double(row(i) - TARGET(1))/double(TARGET(2) - col(i));
        if (m1*m2 < -0.9) && (m1*m2 > -1.1) && (double(row(i) - TARGET(1))^2 + double(col(i) - TARGET(2))^2)^0.5 < 70
            coord = [row(i), col(i)];
            break;
        end
        coord = find_nearest_edge(img, row, col, TARGET);
    end
    
end


function coord = find_nearest_edge(img, row, col, TARGET)
    % Helper function to find the point on the boundary closest to another point
    
    distances = 10000*ones([size(img,1), size(img,2)]);
    
    for i=1:size(row,1)
        distances(row(i),col(i)) = (double(row(i) - TARGET(1))^2 + double(col(i) - TARGET(2))^2)^0.5;
    end
    
    min_dist = min(distances(:));
    [near_row, near_col] = find(distances == min_dist);
    coord = [near_row, near_col];
end
