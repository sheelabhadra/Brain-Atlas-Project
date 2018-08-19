function [count, totalCount] = count_neurons(tform, skeleton, neuron_img, orig_coords, APnum)
    % This function counts the number of neurons marked in green in each 
    % region of the warped skeleton. The results are written to an excel
    % sheet.
    
    % INPUTS:
    % tform: transformation function for the warp
    % skeleton: path to the template or atlas
    % neuron_img: path to the image containing the activated neurons
    % orig_coords: .mat file containing info regarding the coordinates and 
    %              region IDs of the original skeleton
    % APnum: AP number
    
    % OUTPUTS:
    % count: a structure containing the count of neurons in each region
    % totalCount: the total number of neurons in all the regions
    
    % Read the neuron image
    neurons = imread(neuron_img);
    neurons = neurons(:,:,2);

    % Extract query points
    [row, col] = find(neurons);
    xq = col;
    yq = row;

    str = 'region';
    totalCount = 0;
    
    % This section plots the original coordinates on a blank figure.
    % The figure is then resized to the size of the given skeleton.
    % This is followed by applying the warp transformation on the resized
    % skeleton.
    for i=1:size(orig_coords.regions,2)
        varName = sprintf('%s_%d', str, i);
        coords = getfield(orig_coords, varName);
        xv = coords(:,2);
        yv = coords(:,1);
        tfRegion = zeros(800,1000,'uint8');
        for j=1:size(xv,1)
            tfRegion(yv(j),xv(j)) = uint8(255);
        end

        tfRegion = imresize(tfRegion, size(rgb2gray(imread(skeleton)))); % Resize the skeleton to given skeleton's size
        tfRegion = imwarp(tfRegion,tform,'OutputView',imref2d(size(neurons))); % Apply warping
        
        [newyv,newxv] = find(tfRegion > 150); % Find the coordinates of the polygon (region)
        [in,on] = inpolygon(xq, yq, newxv, newyv); % Calculate number of points (neurons) inside the polygon (region)
        count.(varName) = int32(numel(xq(in)));
        totalCount = totalCount + int32(numel(xq(in)));
    end

    % Export region-wise neuron count to an excel file
    T = struct2table(count);
    filename = sprintf('neuron_count_%d.xlsx', APnum);
    writetable(T,filename);
end
