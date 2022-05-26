% registration_across_days.m
% Sarah West
% 8/23/21
% Modified from SCA_manual_masking.m, just the registration across days
% parts

function []=registration_across_days(days_all, transformation, configuration)

    % find parameters for the registration you want to do
    [optimizer, metric] = imregconfig(configuration);

    load([data_dir,day_in,'Back.mat']); %load the background file          
    trans_ix==1 % this loop performs between stacks registration
                    %if the trans_ix (tranform) variable is 1

    %figure out the transform to align the current
    %background image with the reference background and
    %hold it in variable tform
    tform = imregtform(bback, Reference_bback, transformation, optimizer, metric);

    back=imwarp(bback,tform,'OutputView',imref2d(size(Rback)));
    %use imwarp to tranform the current background to align
    %with the reference background using the tranform
    %stored in the tform variable

end