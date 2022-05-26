% registration_pick_reference_day_permouse.m
% Sarah West
% 8/23/21

% Cyles through all the mice, calls pick_reference_day, saves the day the
% user picks for registration. Called by main pipeline code

function []=registration_pick_reference_day_permouse(days_all, dir_exper)
    
    % make the output directory
    dir_out=[dir_exper 'registered_across_days\']; 
    mkdir(dir_out); 
    disp(['data saved in ' dir_out]); 
    
    % See if the reference days have already been started and saved
    if exist([dir_out 'reference_days.mat'])
       
        % if it does, load it
        load([dir_out 'reference_days.mat']); 
        
        % if not, create a new variable for holding the reference days 
        reference_days.mouse=NaN(size(days_all,2),1);
        reference_days.dayname=NaN(size(days_all,2),6);
        
    end     
    % for each mouse 
    for mousei=1:size(days_all,2)
        mouse=days_all(1,mousei);
        
        % Use a flag for determining if the "pick_reference_day"
        % function should be run.
        pick_flag=0;         
 
        % see if it's been found before
        if isnan(reference_days.mouse(mousei,1))==0 % if it HAS been found before
            
            % ask user if they want to redo-it
            user_answer = inputdlg(['Would you like to re-find the reference day for mouse' mouse '? (y = yes, n = no)']);
            
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
        % find the directories and images for the pick_reference_day function
        
        
        % run the pick_reference_day function
        
        % hold onto the user output (of which day should be used as
        % reference)
       
        
    end 
    
    % save the user outputs/reference days as a variable

end 