EPF = 0.0;
   
   % Change this function you dimwit - make it dependent on the warped template !!
   % How could you even miss that at the first place ?!
   angle_EPF_template = find_angle_EPF(template);
   
   count = 0;
   for i=1:size(template,1)
       for j=1:size(template,2)
           if template(i,j) ~= 0
               % Bottleneck step - way too slow man!!
               nearest_coords = find_nearest_edge(base_edge, [i, j]);
               EPF = EPF + (1 + dist_EPF(i,j)*abs(cos(angle_EPF(i,j) - angle_EPF_template(nearest_coords(1),nearest_coords(2)))));
%                EPF = EPF + (1 + dist_EPF(i,j)*abs(cos(angle_EPF(i,j) - angle_EPF_template(i,j))));
               count = count + 1;
           end
       end
   end
%    z = EPF/(size(template, 1)*size(template, 2));
   z = EPF/count;
   
   % Alpha calculation
   k = 0.5;
   alpha = k/((size(dist_EPF,1))^2 + (size(dist_EPF,2))^2)^0.5;
   
   % Add the penalty term to z - Check Maggie's repo
   
   p = 0.0;
   for i=1:size(templatePoints,1)
       p = p + ((swarmPoints(1) - templatePoints(1))^2 + (swarmPoints(2) - templatePoints(2))^2)^0.5;
   end
   p = alpha*p;
   
   z = z + p;
end

function coord = find_nearest_edge(img, TARGET)
    [row, col] = find(img);
    distances = 1000*ones([size(img,1), size(img,2)]);
    
    for i=1:size(row,1)
        distances(row(i),col(i)) = ((row(i) - TARGET(1))^2 + (col(i) - TARGET(2))^2)^2;
    end
    
    min_dist = min(distances(:));
    [near_row, near_col] = find(distances == min_dist);
    coord = [near_row, near_col];
end