% apply_registration_and_masks.m
% Sarah Wests
% 8/24/21
% Takes the pre-calculated tforms and masks and applies it to the
% hemocorrected data stacks at the same time, then saves. This is happening
% in the same code to reduce the amount of data being saved in intermediate
% processing steps.

% Each mouse has 1 masks, which was drawn on the reference bback image.
% Each day within a mouse has a tform that aligns all images to the same
% reference image. (All within-stack and within-day/across-stacks
% registration was already done in Preprocessing_Hemo.m)
 
function []=apply_registration_and_masks(days_all, dir_exper)
    
    % Establish base input and output directories
    dir_in_base_data=[dir_exper 'hemodynamics corrected\']; 
    dir_in_base_tforms=[dir_exper 'tforms across days\']; 
    dir_in_masks=[dir_exper 'masks\'];
    
    % load reference days 
    
    for mousei=1:size(days_all,2)
        mouse=days_all(mousei).mouse;

        % get the list of days for that mouse
        days_list=days_all(mousei).days; 

        % for each day
        for dayi=1:size(days_list,1)
            day=days_list(dayi,:); 
            
            for stacki=1:size(list,1)
                stack_number
            % for each stack 

            % ** Apply registration**

            % Load that day's tform

            % if the tform's empty, then you don't need to register

            % Else, perform the registration/warp. Use imwarp to tranform
            % the current image to align with the reference image using the tranform
            % stored in the tform variable. Should be able to apply to all
            % images in the 3rd dimension at the same time 
             data=imwarp(hData,tform,'OutputView',imref2d(size(Rback)));

            % ** Apply mask** 
            
            % Save resulting stacks. 
            
            end
        end 
    end 
end
