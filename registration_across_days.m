% registration_across_days.m
% Sarah West
% 8/23/21
% Modified from SCA_manual_masking.m, just the registration across days
% parts

function []=registration_across_days(days_all, dir_exper, transformation, configuration, max_step_length, max_iterations)
    
    % Establish input and output directories
    dir_in_base=[dir_exper 'hemodynamics corrected\'];
    dir_out_base=[dir_exper 'tforms across days\'];
    
    % Display to user where everything is saved.
    disp(['data saved in ' dir_out_base]); 
    
    % Load the list of what days should be used to register everything else
    % to. 
    load([dir_out_base 'reference_days.mat']);
    
    % Find parameters for the registration you want to do
    [optimizer, metric] = imregconfig(configuration);
    
    % Change the default max step length and max iterations. 
    optimizer.MaximumStepLength=max_step_length;
    optimizer.MaximumIterations=max_iterations;
  
    
    % **Compute t-forms** 
    % For each mouse 
    for mousei=1:size(days_all,2)
        mouse=days_all(mousei).mouse;
        
        % Get the list of days for that mouse
        days_list=days_all(mousei).days; 
        
        % Find the day you're supposed to register to with this mouse 
        reference_day=reference_days.day{mousei};
        
        % Load the reference bback image, rename it
        load([dir_in_base '\' mouse '\' reference_day '\bback.mat']);
        Reference_bback=bback;
        
        % for each day
        for dayi=1:size(days_list,1)
            day=days_list(dayi,:); 
            
            % make a dir_in and dir_out folder name for each day
            dir_in = [dir_in_base mouse '\' day '\']; 
            dir_out= [dir_out_base mouse '\' day '\']; 
            
            % See if a tform file already exists; skip if so 
%             registration_flag=isfile([dir_out 'tform.mat']);
%             if registration_flag==1
%                 % If the tform has already been calculated for this day,
%                 % skip it.
%             elseif registration_flag==0
                % If it doesn't exist yet, continue. 
                
                % Create the output folder 
                mkdir(dir_out); 
                
                % See if this day is the reference day
                if strcmp(day, reference_day)
                    
                    % If this is the reference day, make tform empty
                    tform=[];

                else
                    % If this is NOT the reference day, perform the
                    % registration
                    
                    % Load day's bback
                    load([dir_in 'bback.mat']);
                    
                    % Perform registration.                 
                     tform = imregtform(bback, Reference_bback, transformation, optimizer, metric);
                    
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
                % Save the tform for each day (including empy tform variables, 
                % which makes the logic easier in later steps) 
                save([dir_out 'tform.mat'], 'tform');         
            %end           
        end 
    end
end