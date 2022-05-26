% DeleteMasks.m
% Sarah West
% 10/7/21

% Plots all the masks you drew with ManualMasking.m and lets you pick some
% for deletion.

function [remaining_masks] = DeleteMasks(masks, bRep)
% Inputs:
% masks -- a 3D matrix (pixels, pixels, mask #) of all the masks you drew.
% bRep -- a representative image (pixels, pixels) that you used to draw 

     % Get a colormap for qualitative data.
     mymap=[cbrewer('qual', 'Paired', size(masks,3)); jet(1000)];
     
     % Make a blank image for holding masks 
     %%%%%% *DOESN'T SHOW BLANK BACKGROUNDS RIGHT NOW*
     holder=zeros(size(masks,1), size(masks,2));
     
     
     % Add each mask in its own color to  holder. 
     for i=1:size(masks,3)
        holder(find(masks(:,:,i)))=i; 
     end

     % Plot the image with a colorbar. 
     figure; 
     
     % Plot bRep with its own color scheme
     ax1 = axes;
     imagesc(bRep); colormap(gray); 
     
     % Plot the mask overlays with their own colorscheme 
     ax2 = axes;
end