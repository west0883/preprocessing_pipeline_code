% HemoCorrection.m
% Sarah West
% 8/26/21

% Corrects the hemodynamics of a stack. Requires input of two matrices--
% the blue and violet data from a single stack. 

% Inputs:
% bData -- the blue-channel only stack, in a 3D matrix (pixels, pixels,
    % frames)
% vData -- the violet-channel only stack, in a 3D matrix (pixels, pixels,
    % frames). Must be same size in all dimensions as the blue channel
    % matrix. 
    
% Outputs:
% hData -- The hemodynamic-corrected stack. 

function [hData]=HemoCorrection(bData, vData)
    

    if ndims(bData > 2)
        % Find blue matrix sizes
        yDim=size(bData,1);
        xDim=size(bData,2);
        frames=size(bData, 3); 
        
        % Reshape and flip the matrices so the "detrend" function below will work
        % properly. Needs to be 2D (frames, pixels*pixels). Overwrite variables
        % so you don't take up excess memory. 
        bData=[reshape(bData, yDim*xDim, frames)]'; 
        vData=[reshape(vData, yDim*xDim, frames)]'; 
    
    end 
    % Hemodynamic correction: 
    % For each channel, detrend each pixel along the time dimension and 
    % divide by that pixel's mean. Then subtract the violet data from the 
    % blue data. 
    hData=detrend(bData)./mean(bData)-detrend(vData)./mean(vData);
    
    % Flip and reshape hData back into original shape of bData. Overwrite 
    % variable so you don't take up excess memory. 
    hData=reshape(hData', yDim, xDim, frames); 
    
end 