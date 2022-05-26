% preprocessing.m
% Sarah Wests
% 8/24/21

% This is happening all in the same code to reduce the amount of data being 
% saved in intermediate processing steps. THIS CODE DOES:

% 1. Reads the data tiffs in as matrics.
% 2. Separates data into blue and violet channels. 
% 3. Registers within-stack/across stacks within a day. 
% 4. Corrects hemodynamics. 
% 5. Applies the pre-calculated across-day tforms.
% 6. Applies the pre-calculated mask per mouse.
% 7. Apples filtering. 
% 8. Saves preprocessed stacks. 

function []=preprocessing(days_all, dir_exper, dir_dataset, dataset_str, b, a, usfac, skip, pixel_rows, pixel_cols, frames_for_spotchecking, filter_flag)
    
    % Establish base input directories
    dir_in_base_tforms=[dir_exper 'tforms across days\']; 
    dir_in_masks=[dir_exper 'masks\'];
    dir_in_ref=[dir_exper 'representative images\']; 
    
    % Establish base output directory
    dir_out_base=[dir_exper 'fully preprocessed stacks/'];
    
    % Load reference days
    load([dir_in_ref 'reference_days.mat']);
    
    % Make skip always odd.
    if mod(skip,2)==0 
        %if the remainder of the length of the skip 
        %(specified as an input argument) after division by 2 is 0
        skip=skip-1; %subtract 1 from the skip value 
    end
    
    % For each mouse 
    for mousei=1:size(days_all,2)
        mouse=days_all(mousei).mouse;
        
        % Load the mask indices for that mouse
        load([dir_in_masks 'masks_m' mouse '.mat'], 'indices_of_mask'); 
        
        % Get the list of all days for that mouse
        days_list=days_all(mousei).days; 

        % For each day
        for dayi=1:size(days_list,1)
            day=days_list(dayi,:); 
            
            % Create cleaner data input and output directories; Is just a
            % preference, but might make it easier to edit directories
            % later if needed.
            dir_in=[dir_dataset day '\' day 'm' mouse '\' dataset_str]; 
            dir_out=[dir_out_base mouse '\' day '\']; 
            mkdir(dir_out); 
            
            % Load the reference image for that day
            load([dir_in_ref mouse '\' day '\bRep.mat']); 
            
            % Load the across-day tform for that day. 
            load([dir_in_base_tforms mouse '\' day '\tform.mat']); 
            
            % Find the correct stack list entry of days_all. 
            stackList=days_all(mousei).stacks{dayi}; 
            
            % If stackList is a character string (to see if 'all')
            if ischar(numberVector)
        
               % If it is a character string, check to see if it's the string
               % 'all'. 
               if strcmp(numberVector, 'all')
                   
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
                    
                    % If the user said use 'all' stacks.
                    case 1
                        
                      % Get the stack number for naming output files. 
                      stack_number=list(stacki).name(2:3); 
                      
                      % Get the filename of the stack. 
                      filename=[dir_in list(stacki).name];
                    
                    % If the user said use a specifc list of stacks. 
                    case 0
                        
                end 
                
                
               
                
                % Display what mouse, day, and stack you're on
                disp(['mouse ' mouse ', day ' day ', stack ' stack_number]);
                
                % *** 1. Read in tiffs.***
                disp('Reading tiffs'); 
                im_list=tiffreadAltered_SCA(filename,[], 'ReadUnknownTags',1);              
                
                % Find the sizes of the data
                yDim=size(im_list(1).data,1);
                xDim=size(im_list(1).data,2);
                
                % ***2. Separate Channels***
                disp('Separating channels'); 
                
                % Pick 2 images after the skip to compare 
                im1=im_list(skip).data; 
                im2=im_list(skip+1).data;
                
                % Get total number of images
                nim=size(im_list,2); 
                
                % Figure out which is what channel
                [first_image_channel] = DetermineChannel(im1, im2, pixel_rows, pixel_cols);
                
                % Make two lists of which images are what channel.
                switch first_image_channel
                    
                    % If the first image is blue
                    case 'b'
                        % Then assign every other frame starting with "skip"
                        % to the blue list, the others to the violet list.
                        sel470=skip:2:nim;
                        sel405=skip+1:2:nim;
                    
                    % If the first image is violet. 
                    case'v' 
                        % Then assign every other frame starting with
                        % "skip"+1 to the blue list, the others to the violet list.
                        sel470=skip+1:2:nim; 
                        sel405=skip:2:nim;
                end
                
                % Find the minimum stack length of the two channels; make this the "frames" number 
                frames=min(length(sel470),length(sel405));
                
                % Figure out if this frames number is long enough for
                % further processing. If not, quit this stack. 
                
                % Limit the frame indices for each color stack to the 
                % minimum number of indices (takes care of uneven image 
                % numbers by making them same length).
                sel470=sel470(1:frames); 
                sel405=sel405(1:frames);
                
                % Put respective channels into own data matrics
                bData=TiffreadStructureToMatrix(im_list, sel470);
                vData=TiffreadStructureToMatrix(im_list, sel405); 
               
                % Set aside images for spotcheck 
                spotcheck_data.initial.blue=bData(:,:, frames_for_spotchecking);
                spotcheck_data.initial.violet=vData(:,:, frames_for_spotchecking);
                
                % ***3. Register within-stack/across stacks within a day.*** 
                disp('Registering within days'); 

                % Run the within-day registration function; overwrite bData
                % so you don't take up as much memory. 
                [bData, tforms_forviolet]=RegisterStackWithDFT(bRep, bData, usfac);

                % Apply the calculated tforms to the violet stack. Overwrite vData
                % so you don't take up as much memory.  
                [vData]=RegisterStack_WithPreviousDFTShifts(tforms_forviolet, vData, usfac); 
                 
                % Set aside images for spotcheck 
                spotcheck_data.withindayregistered.blue=bData(:,:, frames_for_spotchecking);
                spotcheck_data.withindayregistered.violet=vData(:,:, frames_for_spotchecking);
                
                % *** 4. Correct hemodynamics. ***
                % Run HemoCorrection function; 
                disp('Correcting hemodynamics');
                [data]=HemoCorrection(bData, vData);
                
                % Set aside images for spotcheck 
                spotcheck_data.hemodynamicscorrected=data(:,:, frames_for_spotchecking);
                
                % *** 5. Apply registration across days ***

                % If the tform's empty, then you don't need to register
                if isempty(tform)==1 
                    % Do nothing
                else
                    % Else (the tform isn't empty) perform the registration/warp. 
                    % Use imwarp to tranform the current image to align with the 
                    % reference image using the tranform stored in the tform variable. 
                    % Should be able to apply to all images in the 3rd dimension at the same time 
                    disp('Applying registration across days');  
                    data=imwarp(data,tform,'OutputView',imref2d([yDim xDim]));
                end
                
                % Set aside images for spotcheck 
                spotcheck_data.registrationacrossdays=data(:,:, frames_for_spotchecking);
                
                % Reshape data into a 2D matrix (total pixels x frames) for
                % applying the mask and the lowpass filter. Overwrite the variable
                % so you don't take up excess memory. 
                data=reshape(data, yDim*xDim, frames);
                 
                
                % *** 6. Apply mask *** 
                % Keep only the indices that belong to the mask; Don't rename
                % the variable, because that will take up extra memory/time.
                disp('Applying mask')
                data=data(indices_of_mask,:); 
                
                % Set aside images for spotcheck 
                spotcheck_data.masked=data(:, frames_for_spotchecking);
                
                
                % ** *7. Filter***
                % Filter data.
                
                % Only if the user said they wanted to.
                if filter_flag==1
                    disp('Filtering');

                    % flip data as you put it into the filter so it's filtered
                    % in the right dimension. 
                    data=filtfilt(b,a, data'); 

                    data=data'; 
                    % Set aside images for spotcheck 
                    spotcheck_data.filtered=data(:, frames_for_spotchecking);
                end 
                
                % *** 8. Save preprocessed stacks***
                disp('Saving');
                
                % Convert data to single precision to take up less space
                data=single(data); 
                
                % Save resulting stacks. 
                save([dir_out 'data' stack_number '.mat'], 'data', '-v7.3');
                
                % Save spotchecking data
                save([dir_out 'spotcheck_data' stack_number '.mat'], 'spotcheck_data', '-v7.3');  
            end
        end 
    end 
end
