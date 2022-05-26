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
 
% Should also apply lowpass filtering here? 

function []=apply_registration_and_masks(days_all, dir_exper, sampling_freq, fc, order)
    
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
        
        % Load the mask indices for that mouse
        load([dir_in masks 'mask_m' mouse '.mat'], 'indices_of_mask'); 
        
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
                
                % Load stack data. Ask only for hData so you don't also get
                % the example registered images.
                load([dir_in list(stacki).name], 'hData'); 
                
                % Find the sizes of the data
                xDim=size(hData,1);
                yDim=size(hData,2);
                zDim=size(hData,3);
                
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
                     data=imwarp(hData,tform,'OutputView',imref2d(xDim, yDim));
                end
                
                % Reshape data into a 2D matrix (total pixels x frames) for
                % applying the mask and the lowpass filter. Don't rename
                % the variable, because that will take up extra
                % memory/time.
                data=reshape(data, xDim*yDim, zDim);
                
                % ** Apply mask** 
                % Keep only the indices that belong to the mask; Don't rename
                % the variable, because that will take up extra memory/time.
                data=data(indices_of_mask,:); 
                
                % ** Lowpass filter** 
                disp('Filtering');
                
                % Find Niquist freq for filter; sampling divided by 2
                fn=sampling_freq/2; 
                
                % Find parameters of Butterworth filter. 
                [b,a]=butter(order,[fc/fn],'low');
                
                % Filter data.
                data=filtfilt(b,a, data); 
                
                % Save resulting stacks. 
                save([dir_out 'data' stack_number '.mat'], 'data');
            end
        end 
    end 
end
