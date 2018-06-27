function z = mod_EPF(template, dist_EPF, angle_EPF, angle_EPF_template, templatePoints, swarmPoints)
   EPF = 0.0;
   % Check for efficient Matrix multiplication
   for i=1:size(dist_EPF,1)
       for j=1:size(dist_EPF,2)
           EPF = EPF + (1 + dist_EPF(i,j)*abs(cos(angle_EPF(i,j) - angle_EPF_template(i,j))));
       end
   end
   z = EPF/(size(template, 1)*size(template, 2));
   
   % Alpha calculation
   k = 0.5;
   alpha = k/(size(dist_EPF,1)^2 + size(dist_EPF,2)^2)^0.5;
   
   % Add the penalty term to z - Check Maggie's repo
   p = 0.0;
   for i=1:size(templatePoints,1)
       p = p + ((swarmPoints(1) - templatePoints(1))^2 + (swarmPoints(2) - templatePoints(2))^2)^0.5;
   end
   p = alpha*p;
   
   z = z + p;
end