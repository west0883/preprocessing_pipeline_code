% manual_masking_loop.m
% Sarah West
% 8/23/21
% Modified from SCA_manual_masking.m, just the manual masking parts. Will
% also put in code from create_bloodvessel_masks_withbackgroundmasks.m . 
% Let's you keep adding masks until you say you're done. You can return to
% it. 

function []=manual_masking_loop(days_all, dir_exper)
    
    % Establish input and output folders 
    dir_in_base=[dir_exper 'hemodynamics corrected\'];
    dir_out=[dir_exper 'masks\']; 
    mkdir(dir_out); 

    % Display where data is being saved for user
    disp(['data saved in ' dir_out]); 
    
    % Cycle through mice based on the willingness of the user
    mousei=1; 
    while mousei <= size(days_all,2) 
        
        % Find the mouse name
        mouse=days_all(mousei).mouse;
        
        % Display which mouse you're working on
        disp(['working on mouse ' mouse]); 
        
        % Find the reference day
        reference_day=reference_days.day{mousei};
        
        % Define input folder based on reference day
        dir_in=[dir_in_base mouse '\' reference_day '\'];
        
        % Load that mouse's Reference bback
        load([day_in '\bback.mat']);
        
        % Determine if a mask file for this mouse already exists.
        existing_mask_flag=isfile([dir_out 'masks_m' mouse '.mat']); 
        
        % If it does exist already, load the mask file
        if existing_mask_flag==1 
           load([dir_out 'masks_m' mouse '.mat']); 
            
        % If it doesn't exist, 
        elseif existing_mask_flag==0 
            % Make a starting masks variable that's empty
            masks=[];
        end 
        
        % Rename existing masks so they're not confused with the new ones
        % that will be drawn.
        existing_masks=masks;
        
        % ***Run the function that runs the masking itself***
        masks=ManualMasking(bback, existing_masks);     
        
        % Save whatever additions you've made to the mask file 
        save([dir_out 'mask_m' mouse '.mat'], 'masks');
       
        % clear things for next mouse 
        close all; 
        
        % Ask if the user wants to keep working
        user_answer1= inputdlg('Do you want to work on the next mouse? 1=Y, 0=N'); 
        answer1=str2num(user_answer1{1});
        
        % If the user says yes,
        if answer1==1
            % Increase the valuse of mousei and continue 
            mousei=mousei+1; 
        else
            % If the user says anything else, break the while loop so
            % another mouse isn't started 
            break
        end
        
    end
end 