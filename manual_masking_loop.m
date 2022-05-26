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
    
        % Determine if a mask file for this mouse already exists; 
        masking_flag=isfile([dir_out 'mask_m' mouse '.mat']); 
        
        % If it does exist already, load the mask file
        if masking_flag==1 
           load([dir_out 'mask_m' mouse '.mat']);
       
        % If it doesn't exist, will go through the masking loop
        elseif masking_flag==0 

            % Load that mouse's Reference bback
            load([day_in mouse '\' day '\bback.mat']);
            
            % Get the average fluorescence value of the background image and
            % hold the value in back0.
            back0=(bback-min(min(bback)))/(max(max(bback))-min(min(bback)));
           
            MRMask=[]; %initalize MRMask as a blank variable (for manual 
            %reference mask)

    %%%%%%%%%%%%%%%%%% Manual Masking Loop%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for k=1:MaskComponent %for each mask component which we'll 
                    %index with variable k

                    f=figure;hold on %create a figure called f and turn hold on
                    %to keep everything in view
                    title(sprintf('Masking Mouse %d MaskComponent %d of %d',mouse,k,MaskComponent))
                    %put title on figure with the mouseID number and which
                    %component you're drawing (i.e 1 of 2 or 2 of 2)
                    f.WindowState='maximized'; %set figure window to maximized
                    cMask=roipoly(back0); %draw an ROI for one side of the mask on the 
                    %background image and store the boundary coordinates in variable cMask
                    delete(f) %when done delete the figure

                    if isempty(MRMask) %if variable MRMask is empty
                        MRMask=cMask; %make MRMask equal the cMask variable
                        %so now MRMask holds the boundaries of one side of the mask
                    else
                        if ~isempty(cMask) %if variable cMask is not empty
                            MRMask=MRMask+cMask; %add new cMask (other half of 
                            %brain mask to the one already drawn; this if for
                            %when the second image comes up and the loop has
                            %repeated)
                        end
                    end
                end

    %%%%%%%%%%%%%%%%%%%%%%%%% saves the mask and the background %%%%%%%%%%%%%%%%%%%%          
                if ~isempty(MRMask) %if MRMask is not empty

                    MRMask(MRMask>0)=1; %set all areas of the mask in MRMask
                    %that are greater than 0 equal to 1 (i.e. areas covering
                    %the brain)
                    RMask=MRMask; %set variable RMask equal to MRMask so that
                  
                end
                
                
  
        
        end
        % Save whatever additions you've made to the mask file 
        save([dir_out 'mask_m' mouse '.mat'], 'mask');
    end
end 