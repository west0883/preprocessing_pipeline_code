% RegisterStackWithDFT
% Sarah West
% 8/26/21

% Runs registration within stacks and across stacks within the same day to
% a representative image of that day. Uses dftregistration function. 

function [registered_stack, all_tforms]=RegisterStackWithDFT(reference_image, stack_to_register, usfac)

 % Inputs: 
 % reference_image -- the representative image (of that recording day) that
    % you're registering all frames of all stacks to. MUST BE BLUE CHANNEL
 % stack_to_register -- the data matrix of a stack to register. 3D (pixels,
    % pixels, frames). MUST BE
    % BLUE CHANNEL
 % usfac -- "upsampling factor" for dftregistration function (for within stack & 
    % day registration); determines the sub-pixel resolution of the registration; 
 
 % Outputs:
 % registered_stack -- the stack with each frame registered; 3D (pixels,
    % pixels, frames)
 % all_tforms -- all the shifts that were applied; 3D (rows shifted, cols 
    % shifted, frames)
 



end 