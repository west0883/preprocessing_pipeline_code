% Registration_Manual_Redo.m
% Sarah West
% 8/24/21

% Takes the across-day registrations that weren't done very well by the automatic
% registration and let's you re-do them manually. Adapted from
% "lines_register_multiple_forbackwards.m"


function []=Registration_Manual_Redo(redo, dir_exper)

fig1=figure; imagesc(dat1); % plot each image
fig2=figure; imagesc(dat2)

[x1, y1]=getpts(fig1);% use the function "getpts" to slelect 3 or more points from the first image (I like to use blood vessel branch points), then the same 3 points 

[x2, y2]=getpts(fig2); 

tform = fitgeotrans([x2 y2], [x1 y1], 'affine'); % calculated the matrix that, when multiplied with the image you're registering, aligns it with the reference image
save([dir_out 'tform.mat'], 'tform'); 

% Perform a check and save it in the folder
% Apply the transform to the bback
result=imwarp(bback,tform,'OutputView',imref2d(size(Reference_bback))); 

% Plot both images together before and after registration 
figure; 
subplot(1,2,1); imshowpair(bback, Reference_bback); title('before')
subplot(1,2,2); imshowpair(result,Reference_bback); title('after')
suptitle([mouse ', ' day])
% Save the check figure 
savefig([dir_out 'before_and_after.fig']); 
end 