% TiffreadStructureToMatrix.m
% Sarah West
% 8/26/21

% Takes the output structure from tiffread functions and turns the .data
% fields into one big matrix. 

function [data_matrix]=TiffreadStructureToMatrix(data_structure,frames_list)

% Inputs:
% data_structure -- a structure of images outputted by tiffread
% frames_list -- the indices/frames of the structure you want to include in the
    % data matrix. Is a vector. 
    
% Outputs:
% data_matrix -- a 3D matrix of an image stack (pixels, pixels, frames)

    % Use the first frame of the structure to determine image dimensions 
    [yDim, xDim]=size(data_structure(1).data); 
    
    % Use the size of the frames list to determine how many frames the data matrix will have
    frames=length(frames_list); 
    
    % Initialize size of data_matrix
    data_matrix=NaN(yDim, xDim, frames); 
    
    % For each frame, put it into the data_matrix at appropriate place, converting to double precision 
    parfor framei=1:frames
        
        % Make things a bit easier by defining your frame numbers. 
        frame_structure=frames_list(framei); 
      
        % Now, convert the frames to double precision (from uint16) and move them. 
        data_matrix(:,:,framei)=data_structure(frame_structure).data; 
    end 

end 