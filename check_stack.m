% check_stack.m
% Sarah West
% 8/27/21
% Loads and reshapes a stack (based on "mask") so you can plot individual
% frames to check.

function [data_masked] = check_stack(dir_exper, stack_to_check, yDim, xDim) 

    mouse=stack_to_check{1};
    day=stack_to_check{2};
    stack_number=stack_to_check{3};
    
    % Load mask for this mouse 
    load([dir_exper 'masks\masks_m' mouse '.mat'], 'indices_of_mask');
    
    % Load the stack to check. 
    disp('Loading');
    load([dir_exper 'fully preprocessed stacks\' mouse '\' day '\data' stack_number '.mat']);
    
    % Initialize stack size
    frames=size(data,2); 
    data_masked=NaN(yDim*xDim, frames); 
    
    % Put in mask indicecs
    disp('Filling in mask and reshaping'); 
    data_masked(indices_of_mask,:)=data; 
   
    data_masked=reshape(data_masked, yDim, xDim, frames); 
    
end 