% check_stack.m
% Sarah West
% 8/27/21
% Checks if a preprocessed stack is corrupt

function [] = check_stacks(days_all, dir_exper, dir_dataset_name, input_data_name, b, a, usfac, skip, pixel_rows, pixel_cols, frames_for_spotchecking, filter_flag, digitNumber, minimum_frames, correction_method, channelNumber) 

    % Set input (and re-preprocessing output) directory base.
    dir_preprocessed_base=[dir_exper 'fully preprocessed stacks\']; 
    
    % Create output file name
    output_filename='corrupt_stacks.mat';

    % Tell user what you're doing.
    disp(['Finding corrupt stacks. Saving data in ' dir_preprocessed_base]);
    
    % Initiate an empty cell array
    corrupt_files={};
    
    % Cycle through mice. 
    for mousei=1:size(days_all,1)
        
        % Get the mouse name.
        mouse=days_all(mousei).mouse; 

        % Cycle through days.
        for dayi=1:size(days_all(mousei).days, 2)
            
            % Get the day name.
            day=days_all(mousei).days(dayi).name; 
            
            % Tell user where the code is.
            disp(['mouse ' mouse ', ' day ]); 
            
            % Establish input directory. 
            dir_preprocessed=[dir_preprocessed_base '\' mouse '\' day '\'];
            
            % Find the correct stack list entry of days_all. 
            stackList=days_all(mousei).days(dayi).stacks; 
            
            % If stackList is a character string (to see if 'all')
            if ischar(stackList)
        
               % If it is a character string, check to see if it's the string
               % 'all'. 
               if strcmp(stackList, 'all')
                   
                   % If it is the character string 'all', list stacks from
                   % the day directory. 
                   list=dir([dir_preprocessed 'data*.mat']);
                   
                   % Assign a flag for marking if this happened. 
                   all_flag=1; 
               end
               
               % If stackList is not a character string, assume it's a
               % vector of integer stacknumbers.  
            else
                list=ListStacks(stackList, digitNumber); 
                
                % Assign a flag for marking if the list was already made
                all_flag=0;
            end 
            
            % For each stack 
            for stacki=1:size(list,1)
                
                % Depending on the value of the all_flag (the format of the
                % stack list), figure out the name of the stacks
                switch all_flag
                    
                    % If the user said use 'all' stacks,
                    case 1
                        
                        % Get the stack number assuming the filename is
                        % 'data' [stack_number] '.mat'.
                        stack_number=list(stacki).name(5:5+digitNumber-1); 
                          
                        % Get the filename of the stack. 
                        filename=[dir_preprocessed list(stacki).name];
                    
                    % If the user said use a specifc list of stacks, use
                    % the list generated from the ListStacks function. 
                    case 0
                        % Get the stack number.
                        stack_number=list(stacki, :); 
                        
                        % Get the filename.
                        stackname=CreateFileStrings(input_data_name, [], [], stack_number); 
                        filename=[dir_preprocessed stackname];
                end 
                
               % Run filename in CheckIfCorruptFast 
               [isCorrupt]=CheckIfCorruptFast(filename);
              
               % If the file was corrupt, 
               if isCorrupt==true
                   % Add to list of corrupt stacks.
                   corrupt_files=[corrupt_files; {mouse} {day} {stack_number}]; 

                   % Tell user there was a corrupt stack. 
                   disp('Found a corrupt stack.');
                   disp(['Preprocesing ' mouse ', ' day ' stack' stack_number ]); 
               
                   % Run the re-do preprocessing here (I don't feel like writing
                   % out the logic of stack names again.) 
                   Preprocessing_specificStacks(mouse, day, stack_number, dir_exper, dir_dataset_name, input_data_name, b, a, usfac, skip, pixel_rows, pixel_cols, frames_for_spotchecking, filter_flag, digitNumber, minimum_frames, correction_method, channelNumber);
               end
            end
        end 
    end 

% Save list of corrupt stacks, just in case.  
save([dir_preprocessed_base output_filename], 'corrupt_files');

end 