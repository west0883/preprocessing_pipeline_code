% registration_pick_reference_day_permouse.m
% Sarah West
% 8/23/21

% Cyles through all the mice, calls pick_reference_day, saves the day the
% user picks for registration. Called by main pipeline code

function []=registration_pick_reference_day_permouse(days_all, dir_exper, plot_sizes)
    
    % make the output directory
    dir_out=[dir_exper 'registered across days\']; 
    mkdir(dir_out); 
    disp(['data saved in ' dir_out]); 
    
    % See if the reference days have already been started and saved
    if exist([dir_out 'reference_days.mat'])
       
        % if it does, load it
        load([dir_out 'reference_days.mat']); 
    else  
        % if not, create a new variable for holding the reference days 
        reference_days.mouse=cell(size(days_all,2),1);
        reference_days.day=cell(size(days_all,2),1);
        
    end     
    % for each mouse 
    for mousei=1:size(days_all,2)
        mouse=days_all(mousei).mouse;
        
        % Use a flag for determining if the "pick_reference_day"
        % function should be run.
        pick_flag=0;         
 
        % see if it's been found before
        if isempty(reference_days.mouse{mousei})==0 % if it HAS been found before
            
            % ask user if they want to redo-it
            user_answer = inputdlg(['Would you like to re-find the reference day for mouse' mouse '? (y = yes, n = no)']);
            % get rid of cell formatting
            user_answer=user_answer{1};
            % if they don't want to,
            if user_answer=='n'
                pick_flag=0; % don't run functon
            % if they DO want to,     
            elseif user_answer=='y'
                pick_flag=1;  % run function          
            end
            
        % if it hasn't been found before    
        else
            pick_flag=1; % run function 
        end
        
        if pick_flag==1 
            % find the directories and images for the pick_reference_day function
            % holding variable for the images to show
            file_paths=cell(size(days_all(mousei).days,1),1); 

            % put the file paths of each background image into the list, to 
            for dayi=1:size(days_all(mousei).days,1)
                day=days_all(mousei).days(dayi,:);
                file_paths{dayi}=[dir_exper 'hemodynamics corrected/' mouse '/' day '/bback.mat'];

            end 
        
            % Run the pick_reference_day function
            [dayi_output]=pick_reference_day(mouse, file_paths, plot_sizes);

            % Convert the dayi user input to the day name and put in the
            % variable
            reference_days.mouse{mousei}=mouse; 
            reference_days.day{mousei}=days_all(mousei).days(dayi_output,:);
       
        end 
        
        % Save the user outputs/reference days as a variable. Save each
        % time you look at a mouse, because we don't want something to go
        % wrong in the middle and have to start over.
        save([dir_out 'reference_days.mat'], 'reference_days'); 

    end     
   
end 