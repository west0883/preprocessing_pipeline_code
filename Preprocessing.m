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
% 6. Applies the pre-caluclated mask per mouse.
% 7. Apples lowpass filtering. 

function []=preprocessing(days_all, dir_exper, dir_dataset, dataset_str, sampling_freq, fc, order, usfac, skip, pixel_rows, pixel_cols)
    
    % Establish base input directories
    dir_in_base_tforms=[dir_exper 'tforms across days\']; 
    dir_in_masks=[dir_exper 'masks\'];
    
    % Establish base output directory
    dir_out_base=[dir_exper 'fully preprocessed stacks/'];
    
    % Load reference days
    load([dir_in_base_tforms 'reference_days.mat']);
    
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
        load([dir_in masks 'mask_m' mouse '.mat'], 'indices_of_mask'); 
        
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
            
            % Load the reference image for that day
            
            
            % Load the across-day tform for that day. 
            load([dir_in_base_tforms mouse '\' day '\tform.mat']); 
            
            % List the stacks in this day
            list=dir([dir_in '0*.tif']); 
            
            % For each stack 
            for stacki=1:size(list,1)
                
                % Get the stack number for naming output files. 
                stack_number=list(stacki).name(2:3); 
                
                % Display what mouse, day, and stack you're on
                disp(['mouse ' mouse ', day ' day ', stack ' stack_number]);
                
                % *** 1. Read in tiffs.***
                disp('Reading tiffs'); 
                filename=[dir_in list(stacki).name];
                im_list=tiffreadAltered_SCA(filename,[], 'ReadUnknownTags',1);              
                
                % Find the sizes of the data
                xDim=size(im_list(1).data,1);
                yDim=size(im_list(1).data,2);
                %zDim=size(im_list,3);
                
                % ***2. Separate Channels***
                disp('Separating channels'); 
                
                % Pick 2 images after the skip to compare 
                im1=im_list(skip).data; 
                im2=im_list(skip+1).data;
                
                % Figure out which is what channel
                [first_image_channel] = determine_channel(im1, im2, pixel_rows, pixel_cols);
                
                % Make two lists of which images are what channel.
                if first_image_channel=='b'
                    % Then assign every other frame starting with "skip"
                    % to the blue list, the others to the violet list.
                    sel470=skip:2:nim;
                    sel405=skip+1:2:nim;
                elseif first_image_channel=='v' 
                    % Then assign every other frame starting with
                    % "skip"+1 to the blue list, the others to the violet list.
                    sel470=skip+1:2:nim; 
                    sel405=skip:2:nim;
                end
                
                % Find the minimum stack length of the two  channels 
                len=min(length(sel470),length(sel405));
                
                % Limit the frame indices for each color stack to the 
                % minimum number of indices (takes care of uneven image 
                % numbers by making them same length).
                sel470=sel470(1:len); 
                sel405=sel405(1:len);
                
                % Put respective channels into own data matrics
                bData=TiffreadStructureToMatrix(im_list, sel470);
                vData=TiffreadStructureToMatrix(im_list, sel405); 
               
                % ***3. Register within-stack/across stacks within a day.*** 
                disp('Registering within days'); 

                % Run the within-day registration function
                [registered_stack, all_tforms]=RegisterStackWithDFT(bRef, bData, usfac);

                 parfor t=1:len 
                     % make a function for this
                      % Perform fourier transform of the background/reference image 
                       fbback=fft2(bRef); 
                 end
                
                % *** 4. Correct hemodynamics. ***
                disp('Correcting hemodynamics');
                
                
                % *** 5. Apply registration across days ***
                disp('Applying registration across days'); 

                % If the tform's empty, then you don't need to register
                if isempty(tform)==1 
                    % Do nothing
                else
                    % Else (the tform isn't empty) perform the registration/warp. 
                    % Use imwarp to tranform the current image to align with the 
                    % reference image using the tranform stored in the tform variable. 
                    % Should be able to apply to all images in the 3rd dimension at the same time 
                     data=imwarp(hData,tform,'OutputView',imref2d(xDim, yDim));
                end
                
                % Reshape data into a 2D matrix (total pixels x frames) for
                % applying the mask and the lowpass filter. Don't rename
                % the variable, because that will take up extra
                % memory/time.
                data=reshape(data, xDim*yDim, zDim);
                
                % *** 6. Apply mask *** 
                % Keep only the indices that belong to the mask; Don't rename
                % the variable, because that will take up extra memory/time.
                disp('Applying mask')
                data=data(indices_of_mask,:); 
                
                % ** Lowpass filter** 
                disp('Lowpass filtering');
                
                % Find Niquist freq for filter; sampling divided by 2
                fn=sampling_freq/2; 
                
                % Find parameters of Butterworth filter. 
                [b,a]=butter(order,[fc/fn],'low');
                
                % Filter data.
                data=filtfilt(b,a, data); 
                
                % Save resulting stacks. 
                save([dir_out 'data' stack_number '.mat'], 'data');
            end
        end 
    end 
end
