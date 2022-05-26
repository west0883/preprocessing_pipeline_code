% registration_across_days.m
% Sarah West
% 8/23/21
% Modified from SCA_manual_masking.m, just the registration across days
% parts

function []=registration_across_days(days_all, dir_exper, transformation, configuration)
    
    % establish input and output directories
    dir_in_base=[dir_exper 'hemodynamics corrected\'];
    dir_out_base=[dir_exper 'registered across days\'];
    
    disp(['data saved in ' dir_out_base]); 
    
    % Load the list of what days should be used to register everything else
    % to. 
    load([dir_out_base 'reference_days.mat']);
    
    % find parameters for the registration you want to do
    [optimizer, metric] = imregconfig(configuration);
    
    
    % **Compute t-forms** 
    % for each mouse 
    for mousei=1:size(days_all,2)
        mouse=days_all(mousei).mouse;
        
        % get the list of days for that mouse
        days_list=days_all(mousei).days; 
        
        % find the day you're supposed to register to with this mouse 
        reference_day=reference_days.day{mousei};
        
        % Load the reference bback image, rename it
        load([dir_in_base '\' mouse '\' reference_day '\bback.mat']);
        ref_bback=bback;
        
        % for each day
        for dayi=1:size(days_list,1)
            day=days_list(dayi,:); 
            
            % See if this day is the reference day
            if strcmp(day, reference_day)
                % If this is the reference day, tform is empty
                regis_flag=0; 
                tform=[];
                
            else
                % If this is NOT the reference day, perform the
                % registration
                
                % calculate the transform
                tform = imregtform(bback, Reference_bback, transformation, optimizer, metric);
                regis_flag=1; 
            end 
           
            
            % perform a check? 
            % save the tform for each day 
        end    
    end 
    
    % **Using tforms, transform the stacks.**
    
     for mousei=1:size(days_all,2)
        mouse=days_all(mousei).mouse;
        
        % get the list of days for that mouse
        days_list=days_all(mousei).days; 
        
        % for each day
          for dayi=1:size(days_list,1)
            day=days_list(dayi,:); 
         
            % Load that day's tform
            
            % if the tform's empty, then you don't need to register
          
            % Else, perform the registration/warp. Use imwarp to tranform
            % the current image to align with the reference image using the tranform
            % stored in the tform variable
             back=imwarp(bback,tform,'OutputView',imref2d(size(Rback)));
          end 
     end 

   

end