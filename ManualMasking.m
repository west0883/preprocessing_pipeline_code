% ManualMasking.m
% Sarah West
% 8/23/21

% Is a function that lets you draw masks over mice brains manually. Is
% called by manual_masking_loop.m 

% Inputs:
% existing_masks-- 
% image_to_mask-- 

% Outputs: 
% masks-- a 

function[masks, indices_of_mask]=ManualMasking(image_to_mask, existing_masks)
       
    % Apply any existing masks to image_to_mask
    indices_of_mask=[];
    
    if isempty(existing_masks)
       % If no previous masks, don't need to add anything to image_to_mask 
    else
        % If there are pre-existing masks, apply them to
        % image_to_mask
        for i=1:size(existing_masks,3)
            mask_flat=existing_masks(:,:,i);
            indices_of_mask=[indices_of_mask; find(mask_flat)]; 
        end
        image_to_mask(indices_of_mask)=NaN;
    end 

    % Display image_to_mask. Displays masks as black
    mymap=[0 0 0; parula(512)];
    figure; imagesc(image_to_mask); colormap(mymap);

    % Ask user if they want to add a mask
    user_answer1= inputdlg('Do you want to draw additional masks? 1=Y, 0=N'); 

    %Convert the user's answer into a value
    answer1=str2num(user_answer1{1});

    % Include existing_masks in the list of masks you're making 
    masks=existing_masks; 

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
        indices_new=find(mask1);

        % Set the new mask to NaN for display
        image_to_mask(indices_new)=NaN; 
        
        % Add these new indices to the list of mask indices
        indices_of_mask=[indices_of_mask; indices_new];
        
        % Draw the representative image with the new masks on it
        figure; imagesc(image_to_mask); colormap(mymap); 

        % Repeat
        user_answer1= inputdlg('Do you want to draw additional masks on this mouse? 1=Y, 0=N'); 
        answer1=str2num(user_answer1{1});
    end

    % leaves while loop if user answers anything other than "1"

end