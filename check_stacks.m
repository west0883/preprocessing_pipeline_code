% check_stack.m
% Sarah West
% 8/27/21
% Checks if a preprocessed stack is corrupt

function [] = check_stacks(days_all, dir_exper, stack_to_check, yDim, xDim) 

    % Set input (and re-preprocessing output) directory base.

    dir_in_base=[dir_exper 'fully preprocessed stacks\']; 

    % Tell user what you're doing.
    disp(['Finding corrupt stacks. Saving data in ' dir_in_base]);
    
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
            dir_in=[dir_in_base '\' mouse '\' day '\'];
            
            % Find the correct stack list entry of days_all. 
            stackList=days_all(mousei).days(dayi).stacks; 
            
            % If stackList is a character string (to see if 'all')
            if ischar(stackList)
        
               % If it is a character string, check to see if it's the string
               % 'all'. 
               if strcmp(stackList, 'all')
                   
                   % If it is the character string 'all', list stacks from
                   % the day directory. 
                   list=dir([dir_in '0*.tif']);
                   
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
                        
                        % Get the stack number for naming output files
                        % using the input_data_name (allows for flexible
                        % outside-package file names). 
                        
                        % Find the index of the stack number within the input data name.  
                        stackindex=find(contains(input_data_name,'stack number'));
                        
                        % Find the letters in the filename before the stack
                        % number. 
                        pre_stackindex=horzcat(input_data_name{1:(stackindex-1)}); 
                        
                        % Find the number of letters in the filename before
                        % the stack number. 
                        length_pre=length(pre_stackindex); 
                        
                        % Now take range of the file list that corresponds
                        % to the stack number, according to number of
                        % letters that came before the stack number and the
                        % number of digits assigned to the stack number. 
                        stack_number=list(stacki).name(length_pre+1:length_pre+digitNumber); 
                          
                        % Get the filename of the stack. 
                        filename=[dir_in list(stacki).name];
                    
                    % If the user said use a specifc list of stacks, use
                    % the list generated from the ListStacks function. 
                    case 0
                        % Get the stack number.
                        stack_number=list(stacki, :); 
                        
                        % Get the filename.
                        stackname=CreateFileStrings(input_data_name, [], [], stack_number); 
                        filename=[dir_in stackname];
                end 
                
               % Run filename in CheckIfCorruptFast 
               [isCorrupt]=CheckIfCorruptFast(filename);
               
               % If the file was corrupt, 
               if isCorrupt==1
                   % Add to list of corrupt stacks.
                   corrupt_files=[corrupt_files; {day list(stacki).name}]; 

                   % Tell user there was a corrupt stack. 
                   disp('Found a corrupt stack.');
               
                   % Run the re-do preprocessing here (I don't feel like writing
                   % out the logic of stack names again.) 
                   
               
               
               
               
               
               
               
               
               end
               
               

            end
        end 
    end 

% Save list of corrupt stacks, just in case.  
save([dir_in_base output_filename], 'corrupt_files');

end 