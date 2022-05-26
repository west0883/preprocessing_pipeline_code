% registration_SaveRepresentaiveImages.m
% Sarah West
% 8/25/21

% Loads individual images for differentiating between light channels, then
% saves a representaive image for the day. 
           
function []=registration_SaveRepresentativeImages(parameters)
     
    % Assign parameters their original names
    dir_dataset_name = parameters.dir_dataset_name; 
    input_data_name = parameters.input_data_name;
    dir_exper = parameters.dir_exper; 
    mice_all = parameters.mice_all; 
    skip = parameters.skip;
    pixel_rows = parameters.pixel_rows;
    pixel_cols = parameters.pixel_cols; 
    rep_stacki = parameters.rep_stacki; 
    rep_framei = parameters.rep_framei; 
    digitNumber = parameters.digitNumber; 
    
    dir_out_base=[dir_exper 'representative images\'];
    disp(['Data saved in ' dir_out_base]); 
    
    % for each mouse
    for mousei=1:size(mice_all,2)
        % Get the mouse name
        mouse=mice_all(mousei).mouse;
        
        % Get the mouse's dataset days
        days_list=vertcat(mice_all(mousei).days(:).name); 
        
        % Make skip always odd.
        if mod(skip,2)==0 
            %if the remainder of the length of the skip 
            %(specified as an input argument) after division by 2 is 0
            skip=skip-1; %subtract 1 from the skip value 
        end
        
        % For each day of the mouse 
        for dayi=1:size(days_list,1)
            day=days_list(dayi,:);
            
            %create the input directory by day
            dir_in=CreateFileStrings(dir_dataset_name, mouse, day, []);
            
            % get the day name
            day=days_list(dayi,:); 
            
            % make the output directory by day
            dir_out=[dir_out_base '\' mouse '\' day '\']; 
            mkdir(dir_out);
            
            % find the list of stacks in that day (so you can find the
            % first one)
            % Find the correct stack list entry of mice_all. 
            stackList=mice_all(mousei).days(dayi).stacks; 
            
            % If stackList is a character string (to see if 'all')
            if ischar(stackList)
        
               % If it is a character string, check to see if it's the string
               % 'all'. 
               if strcmp(stackList, 'all')
                   
                    % If it is the character string 'all', list stacks from
                    % the day directory. 
                    list=dir([dir_in '0*.tif']);

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
                    stack_number=list(rep_stacki).name(length_pre+1:length_pre+digitNumber); 
                          
               end
               
               % If stackList is not a character string, assume it's a
               % vector of integer stacknumbers.  
            else
                list=ListStacks(stackList, digitNumber); 
                
                % Use this list to get the stack number
                stack_number=list(rep_stacki,:); 
                
            end 
            
            % Use the stacknumber to make an input filename
            stackname=CreateFileStrings(input_data_name, [], [], stack_number); 
            input_filename=[dir_in stackname];
            
            % find if there is a selected reference image for this day
            if isfile([dir_out '\bRep.mat'])==1 
                % If it exists, do nothing; don't need to create a new
                % one
            else 
                % If it doesn't exist, then need to create a new one
                  
                
                % Select 2 sequential images to read; Determined by the 
                % skip and the ref_framei given by the user. Need 2 to 
                % confirm which channel is which.
                image_indices=[skip + rep_framei, skip + rep_framei + 1]; 
                
                % Read those two images
                im_list=tiffreadAltered_SCA(input_filename, image_indices, 'ReadUnknownTags',1);
                
                im1=im_list(1).data;
                im2=im_list(2).data; 
                
                % Compare the brightness of the two images; 
                first_image_channel = DetermineChannel(im1, im2, pixel_rows, pixel_cols);
                
                if first_image_channel=='b'
                   bRep=im1; 
                elseif first_image_channel=='v'
                   bRep=im2;
                end
                
                % Convert bRep to single precision.
                bRep=single(bRep);
                
                % Save the representative image
                save([dir_out 'bRep.mat'], 'bRep');
            end 
        end 
    end
end 
