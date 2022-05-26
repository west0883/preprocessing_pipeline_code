% manual_masking_loop.m
% Sarah West
% 8/23/21
% Modified from SCA_manual_masking.m, just the manual masking parts. Will
% also put in code from create_bloodvessel_masks_withbackgroundmasks.m . 

function []=manual_masking_loop(days_all, dir_exper, MaskComponent)
    
    % Establish input and output folders 
    dir_in_base=[dir_exper 'hemodynamics corrected\'];
    dir_out=[dir_exper 'masks\']; 
    mkdir(dir_out); 

    % Display where data is being saved for user
    disp(['data saved in ' dir_out]); 
    
    % For each mouse
    for mousei=1:size(days_all,2) 
        mouse=days_all(mousei).mouse;
        
        % Find the reference day
        reference_day=reference_days.day{mousei};
        
        % Define input folder based on reference day
        dir_in=[dir_in_base mouse '\' reference_day '\'];
        
        % Load that mouse's Reference bback
        load([day_in '\bback.mat']);
        
        % Determine if a mask file for this mouse already exists.
        existing_mask_flag=isfile([dir_out 'masks_m' mouse '.mat']); 
%         rep_image_drawn=bback; 
        
        % If it does exist already, load the mask file
        if existing_mask_flag==1 
           load([dir_out 'masks_m' mouse '.mat']); 
            
        % If it doesn't exist, 
        elseif existing_mask_flag==0 
            % Make a starting masks variable that's empty
            masks=[];
        end 
        
         %% Could make this section below into a function
           % if a function, just have to pass in bback and previously
           % existing masks
        
        rep_image_drawn=bback;
        
        % Apply any existing masks to rep_image_drawn
        if isempty(masks)
           % If no previous masks, don't need to add anything to rep_image_drawn 
        else
            % If there are pre-existing masks, apply them to
            % rep_image_drawn
            for i=1:size(masks,3)
                mask_flat=masks(:,:,i);
                indices=[indices; find(mask_flat)]; 
            end
            rep_image_drawn(indices)=NaN;
        end 
        
        % Display rep_image_drawn. Displays masks as black
        figure; imagesc(rep_image_drawn); colormap(mymap);
        
        % Ask user if they want to add a mask
        user_answer1= inputdlg('Do you want to draw additional masks? 1=Y, 0=N'); 
        
        %Convert the user's answer into a value
        answer1=str2num(user_answer1{1});

        % If the user said yes,
        while answer1==1      
            
            % Run function "PolyDraw" on the image with previous masks; will 
            % output the coordinates of the ROI drawn
            ROI1=PolyDraw; 
            mask1=flipud(poly2mask(ROI1(1,:),ROI1(2,:),256, 256)); % make a mask of the ROI drawn 
            
            % Close the figure that was being drawn on
            close all;   
            
            % Add the new mask to the matrix of masks that have been drawn so far
            masks=cat(3, masks, mask1); 
            
            % Find the indices of the new mask
            indices=find(mask1);
            
            % Set the new mask to NaN for display
            rep_image_drawn(indices)=NaN; 
            
            % Draw the representative image with the new masks on it
            figure; imagesc(rep_image_drawn); colormap(mymap); 
            
            % Repeat
            user_answer1= inputdlg('Do you want to draw additional masks? 1=Y, 0=N'); 
            answer1=str2num(user_answer1{1});
        end
        
        % leaves while loop if user answers anything other than "1"
        
        
        % Save whatever additions you've made to the mask file 
        save([dir_out 'mask_m' mouse '.mat'], 'masks');
            
    end
end 