% manual_masking_loop.m
% Sarah West
% 8/23/21
% Modified from SCA_manual_masking.m, just the manual masking parts. Will
% also put in code from create_bloodvessel_masks_withbackgroundmasks.m . 
% Let's you keep adding masks until you say you're done. You can return to
% it. 

function []=manual_masking_loop(parameters)
    
    % Assign parameters their original names
    dir_exper = parameters.dir_exper; 
    mice_all = parameters.mice_all; 
    
    % Establish input and output folders 
    dir_in_base = [dir_exper 'representative images\'];
    dir_out = [dir_exper 'masks\']; 
    mkdir(dir_out); 

    % Display where data is being saved for user
    disp(['data saved in ' dir_out]); 
    
    % Load reference days
    load([dir_in_base '\reference_days.mat']); 
        
    % Cycle through mice based on the willingness of the user
    mousei = 1; 
    while mousei <= size(mice_all,2) 
        
        % Find the mouse name
        mouse = mice_all(mousei).name;
        
        % Display which mouse you're working on
        disp(['working on mouse ' mouse]); 
        
        % Find the day you're supposed to register to with this mouse 
        ind = NaN(1,size(reference_days.mouse,1)); 
        for i = 1:size(reference_days.mouse,1)
           ind(i) = strcmp(mouse, reference_days.mouse{i}); 
        end
        refdayi = find(ind); 
        reference_day = reference_days.day{refdayi};
        
        % Define input folder based on reference day
        dir_in = [dir_in_base mouse '\' reference_day '\'];
        
        % Load that mouse's Reference bRep
        load([dir_in '\bRep.mat']);
        
        % Check the size of the bRep, cut to size if needed. 
        bRep = FixImageSize(bRep, parameters.pixels); 

        yDim = parameters.pixels(1);
        xDim = parameters.pixels(2);
        
        % Determine if a mask file for this mouse already exists.
        existing_mask_flag = isfile([dir_out 'masks_m' mouse '.mat']); 
        
        % If it does exist already, load the mask file
        if existing_mask_flag == 1 
           load([dir_out 'masks_m' mouse '.mat']); 
            
        % If it doesn't exist, 
        elseif existing_mask_flag == 0 
            % Make a starting masks variable that's empty
            masks=[];
        end 
        
        % Rename existing masks so they're not confused with the new ones
        % that will be drawn.
        existing_masks=masks;
        
        % ***Run the function that runs the masking itself***
        [masks, indices_of_mask] = ManualMasking(bRep, existing_masks);     
        
        % Make a version of "masks" that puts all the masks on the same
        % plane.
        
        
        % Save whatever additions you've made to the mask file 
        save([dir_out 'masks_m' mouse '.mat'], 'masks', 'indices_of_mask');
       
        % clear things for next mouse 
        close all; 
        
        % Ask if the user wants to keep working
        user_answer1 = inputdlg('Do you want to work on the next mouse? 1=Y, 0=N'); 
        answer1 = str2num(user_answer1{1});
        
        % If the user says yes,
        if answer1 == 1 
            % Increase the valuse of mousei and continue 
            mousei = mousei+1; 
        else
            % If the user says anything else, break the while loop so
            % another mouse isn't started 
            break
        end
        
    end
end 