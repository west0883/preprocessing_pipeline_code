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
     mymap=[1 1 1 ; cbrewer('qual', 'Paired', size(masks,3))];

     % Make blank images for holding masks 
     holder=zeros(size(masks,1), size(masks,2));
     all_masks=zeros(size(masks,1), size(masks,2));
     
     % Add each mask in its own color to  holder, and also put all masks into single image.
     for i=1:size(masks,3)
        holder(find(masks(:,:,i)))=i; 
        all_masks(find(masks(:,:,i)))=1;
     end
     
     % Put all masks onto bRep
     bRep(find(all_masks))=NaN; 
     
     % Create figure.
     figure; 
     
     % Plot bRep in first subplot
     subplot(1,2,1); imagesc(bRep); colormap(gca,[0 0 0; parula(1000)]); 
     title('brain with masks');
     
     % Plot the mask overlays with their own colorscheme in second subplot.
     subplot(1,2,2); imagesc(holder); colormap(gca, mymap); colorbar; 
     title('mask numbers for removal');
end