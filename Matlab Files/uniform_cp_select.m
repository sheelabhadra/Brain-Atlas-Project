% Pick 8 control points uniformly on the template and the base image
template = imread('outer_edge_template.jpg');
base = imread('base_outer_edge.jpg');

[i, j] = find(template > 100);
center = [int32(mean(i)) int32(mean(j))];

c1 = 0;
c2 = 0;
north = 0;
south = 0;

for i=1:size(template,1)
    
    if template(i,center(2)) > 100
        if i < 50
            north = north + i;
            c1 = c1 + 1;
        end
        
        if i > 150
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

for i=1:size(template,2)
    
    if template(center(1),i) > 100
        if i < 100
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

mid_NE = [int32((N(1) + E(1))/2) int32((N(2) + E(2))/2)];
mid_NW = [int32((N(1) + W(1))/2) int32((N(2) + W(2))/2)];
mid_SE = [int32((S(1) + E(1))/2) int32((S(2) + E(2))/2)];
mid_SW = [int32((S(1) + W(1))/2) int32((S(2) + W(2))/2)];

NE = find_nearest_edge(template, mid_NE);
NW = find_nearest_edge(template, mid_NW);
SE = find_nearest_edge(template, mid_SE);
SW = find_nearest_edge(template, mid_SW);

imshow(template);
hold on;

plot(N(2), N(1), 'c*', 'LineWidth', 1, 'MarkerSize', 10);
plot(S(2), S(1), 'c*', 'LineWidth', 1, 'MarkerSize', 10);
plot(E(2), E(1), 'c*', 'LineWidth', 1, 'MarkerSize', 10);
plot(W(2), W(1), 'c*', 'LineWidth', 1, 'MarkerSize', 10);
plot(NE(2), NE(1), 'c*', 'LineWidth', 1, 'MarkerSize', 10);
plot(NW(2), NW(1), 'c*', 'LineWidth', 1, 'MarkerSize', 10);
plot(SE(2), SE(1), 'c*', 'LineWidth', 1, 'MarkerSize', 10);
plot(SW(2), SW(1), 'c*', 'LineWidth', 1, 'MarkerSize', 10);


function coord = find_nearest_edge(img, TARGET)
    [row, col] = find(img > 100);
    distances = 10000.0*ones(size(img,1), size(img,2));
    
    for i=1:size(row,1)
        distances(row(i),col(i)) = (double((row(i) - TARGET(1))^2) + double((col(i) - TARGET(2))^2))^0.5;
    end
    
    min_dist = min(distances(:));
    
    [near_row, near_col] = find(distances == min_dist);
    coord = [near_row, near_col];
end
