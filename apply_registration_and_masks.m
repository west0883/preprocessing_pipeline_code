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
    
    % Establish base input directories
    dir_in_base_data=[dir_exper 'hemodynamics corrected\']; 
    dir_in_base_tforms=[dir_exper 'tforms across days\']; 
    dir_in_masks=[dir_exper 'masks\'];
    
    % Establish base output directory
    dir_out_base=[dir_exper 'fully preprocessed stacks/'];
    
    % Load reference days
    load([dir_in_base_tforms 'reference_days.mat']);
    
    % For each mouse 
    for mousei=1:size(days_all,2)
        mouse=days_all(mousei).mouse;
        
        % Get the list of all days for that mouse
        days_list=days_all(mousei).days; 

        % For each day
        for dayi=1:size(days_list,1)
            day=days_list(dayi,:); 
            
            % Create cleaner data input and output directories; Is just a
            % preference, but might make it easier to edit directories
            % later if needed.
            dir_in=[dir_in_base_data mouse '\' day '\']; 
            dir_out=[dir_out_base mouse '\' day '\']; 
            
            % Load the tform for that day. 
            load([dir_in_base_tforms mouse '\' day '\tform.mat']); 
            
            % List the stacks in this day
            list=dir([dir_in 'hData*.mat']); 
            
            % For each stack 
            for stacki=1:size(list,1)
                
                % Get the stack number for naming output files. 
                stack_number=list(stacki).name(6:7); 
                
                % Load stack data. 
                load([dir_in list(stacki).name]); 

                % ** Apply registration**

                % If the tform's empty, then you don't need to register
                if isempty(tform)==1 
                    % Do  nothing
                else
                    % Else (the tform isn't empty) perform the registration/warp. 
                    % Use imwarp to tranform
                    % the current image to align with the reference image using the tranform
                    % stored in the tform variable. Should be able to apply to all
                    % images in the 3rd dimension at the same time 
                     data=imwarp(hData,tform,'OutputView',imref2d(size(hData,1), size(hData,2)));
                end
                % ** Apply mask** 

                % Save resulting stacks. 

            end
        end 
    end 
end
