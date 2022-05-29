% preprocessing.m
% Sarah Wests
% 8/24/21

% This is happening all in the same code to reduce the amount of data being 
% saved in intermediate processing steps. THIS CODE DOES:

% 1. Reads the data tiffs in as matrics.
% 2. Separates data into blue and violet channels. 
% 3. Registers within-stack/across stacks within a day. 
% 4. Applies the pre-calculated across-day tforms.
% 5. Applies the pre-calculated mask per mouse.
% 6. Corrects hemodynamics via the user's chosen method.
% 7. Apples filtering. 
% 8. Saves preprocessed stacks. 

function []=Preprocessing(parameters)
    
    % Assign parameters their original names
    dir_dataset_name = parameters.dir_dataset_name; 
    input_data_name = parameters.input_data_name;
    dir_exper = parameters.dir_exper; 
    digitNumber = parameters.digitNumber; 
    channelNumber = parameters.channelNumber;
    skip = parameters.skip;
    pixel_rows = parameters.pixel_rows;
    pixel_cols = parameters.pixel_cols; 
    filter_flag = parameters.filter_flag;
    b = parameters.b;
    a = parameters.a;
    usfac = parameters.usfac; 
    frames_for_spotchecking = parameters.frames_for_spotchecking;
    minimum_frames = parameters.minimum_frames;
    mask_flag = parameters.mask_flag;
    correction_method = parameters.correction_method;
    
    % Establish base input directories
    dir_in_base_tforms=[dir_exper 'tforms across days\']; 
    dir_in_masks=[dir_exper 'masks\'];
    dir_in_ref=[dir_exper 'representative images\']; 
    
    % Establish base output directory
    dir_out_base= parameters.dir_out_base;
    
    % Tell user where data is being saved
    disp(['Data saved in ' dir_out_base]); 
    
    % Load reference days
    load([dir_in_ref 'reference_days.mat']);

    % Establish a holding cell array to keep track of what days need to be
    % checked on.
    bad_trials = {};
    
    % For each mouse 
    for mousei=1:size(parameters.mice_all,2)
        mouse=parameters.mice_all(mousei).name;
        
        % Load the mask indices for that mouse
        try 
        load([dir_in_masks 'masks_m' mouse '.mat'], 'indices_of_mask'); 
        catch 
            disp('Could not load mouse mask.');
            bad_trials = [bad_trials; {[dir_in filename], 'couldn''t load mouse mask'}];
            continue
        end

        % For each day
        for dayi=1:size(parameters.mice_all(mousei).days, 2)
            
            % Get the day name.
            day=parameters.mice_all(mousei).days(dayi).name; 
            
            % Create cleaner output directory. 
            dir_out=[dir_out_base mouse '\' day '\']; 
            mkdir(dir_out); 
            
            % Load the reference image for that day
            try 
                load([dir_in_ref mouse '\' day '\bRep.mat']); 
            catch 
                disp('Could not load representative image.');
                bad_trials = [bad_trials; {[dir_in filename], 'couldn''t load representative image'}];
                continue
            end

            % Load the across-day tform for that day. 
            try
                load([dir_in_base_tforms mouse '\' day '\tform.mat']); 
            catch 
                disp('Could not load registration tform.');
                bad_trials = [bad_trials; {[dir_in filename], 'couldn''t load registration tform'}];
                continue
            end
            
            parameters.dir_in = dir_dataset_name;
            
            % Get the stack list
            [stackList]=GetStackList(mousei, dayi, parameters);
            
            for stacki=1:size(stackList.filenames,1)
                
                % Get the stack number and filename for the stack.
                stack_number = stackList.numberList(stacki, :);
                filename = stackList.filenames(stacki, :);
                
                % Get a cleaner data input directory.
                dir_in=CreateFileStrings(dir_dataset_name, mouse, day, stack_number, [], false);
                
                % Display what mouse, day, and stack you're on
                disp(['mouse ' mouse ', day ' day ', stack ' stack_number]);
                
                % *** 1. Read in tiffs.***
                disp('Reading tiffs'); 

                % Check if file exists. If it doesn't, report and keep track. 
                if ~isfile([dir_in filename])
                    disp('File does not exist.');
                    bad_trials = [bad_trials; {[dir_in filename], 'couldn"t find'}];
                    continue 
                end   
                
                % Attempt to load
                try
                    im_list=tiffreadAltered_SCA([dir_in filename],[], 'ReadUnknownTags',1);       
                catch 
                    disp('Could not load file.');
                    bad_trials = [bad_trials; {[dir_in filename], 'couldn"t load'}];
                    continue 
                end
                
                % Find the sizes of the data
                yDim=size(im_list(1).data,1);
                xDim=size(im_list(1).data,2);
                
                % Get total number of images
                nim=size(im_list,2); 
                
                % ***2. Separate Channels***
                
                % Only if number of channels is 2. 
                switch channelNumber
                    case 2
                    disp('Separating channels'); 

                    % Pick 2 images after the skip to compare 
                    im1=im_list(skip+1).data; 
                    im2=im_list(skip+2).data;

                    % Figure out which is what channel
                    [first_image_channel] = DetermineChannel(parameters.blue_brighter, im1, im2, pixel_rows, pixel_cols);

                    % Make two lists of which images are what channel.
                    switch first_image_channel

                        % If the first image is blue
                        case 'b'
                            % Then assign every other frame starting with "skip"
                            % to the blue list, the others to the violet list.
                            sel470=skip+1:2:nim;
                            sel405=skip+2:2:nim;

                        % If the first image is violet. 
                        case'v' 
                            % Then assign every other frame starting with
                            % "skip"+1 to the blue list, the others to the violet list.
                            sel470=skip+2:2:nim; 
                            sel405=skip+1:2:nim;
                    end

                    % Find the minimum stack length of the two channels; make this the "frames" number 
                    frames=min(length(sel470),length(sel405));

                    % Limit the frame indices for each color stack to the 
                    % minimum number of indices (takes care of uneven image 
                    % numbers by making them same length).
                    sel470=sel470(1:frames); 
                    sel405=sel405(1:frames);
                    
                    % Figure out if this frames number is long enough for
                    % further processing. If not, quit this stack. 
                    if frames<minimum_frames
                       warning('This stack is too short-- will not be processed.');

                       % Go to next iteration of stacki for loop.
                       continue 
                    end

                    % Put respective channels into own data matrics
                    bData=TiffreadStructureToMatrix(im_list, sel470);
                    vData=TiffreadStructureToMatrix(im_list, sel405); 

                    % Set aside images for spotcheck 
                    spotcheck_data.initial.blue=bData(:,:, frames_for_spotchecking);
                    spotcheck_data.initial.violet=vData(:,:, frames_for_spotchecking);
                    
                case 1 
                   % If only one channel
                   
                   % Get list of frames after the skip
                   frames_list=skip+1:nim; 
                   
                   % Get the number of frames after the skip
                   frames=length(frames_list); 
                   
                    % Figure out if this frames number is long enough for
                    % further processing. If not, quit this stack. 
                    if frames<minimum_frames
                       warning('This stack is too short-- will not be processed.');

                       % Go to next iteration of stacki for loop.
                       continue 
                    end
                    
                    % Put data into data matrix
                    bData=TiffreadStructureToMatrix(im_list, frames_list);
                    
                    % Set aside images for spotcheck 
                    spotcheck_data.initial.blue=bData(:,:, frames_for_spotchecking);
                end

                clear im_list;
                
                % ***3. Register within-stack/across stacks within a day.***
                disp('Registering within days'); 

                % Run the within-day registration function; overwrite bData
                % so you don't take up as much memory. 
                [bData, tforms_forviolet]=RegisterStackWithDFT(bRep, bData, usfac);

                % Set aside images for spotcheck 
                spotcheck_data.withindayregistered.blue=bData(:,:, frames_for_spotchecking);

                % If more than one channel
                if channelNumber==2
                    % Apply the calculated tforms to the violet stack. Overwrite vData
                    % so you don't take up as much memory.  
                    [vData]=RegisterStack_WithPreviousDFTShifts(tforms_forviolet, vData, usfac); 

                    % Also set aside image for spotcheck
                    spotcheck_data.withindayregistered.violet=vData(:,:, frames_for_spotchecking);
                end 
              

                % *** 4. Apply registration across days ***
                
                % If the tform's empty, then you don't need to register
                if isempty(tform)==1 
                    % Do nothing
                else
                    % Else (the tform isn't empty) perform the registration/warp. 
                    % Use imwarp to tranform the current image to align with the 
                    % reference image using the tranform stored in the tform variable. 
                    % Should be able to apply to all images in the 3rd dimension at the same time 
                    disp('Applying registration across days');  
                    bData=imwarp(bData,tform,'nearest', 'OutputView',imref2d([yDim xDim]));
                    
                    % Set aside images for spotcheck 
                    spotcheck_data.registrationacrossdays.blue=bData(:,:, frames_for_spotchecking);
                    
                    % If more than 1 channel, do for violet channel as well
                    if channelNumber==2
                        vData=imwarp(vData,tform,'nearest', 'OutputView',imref2d([yDim xDim]));
                        spotcheck_data.registrationacrossdays.violet=vData(:,:, frames_for_spotchecking);
                    end 
                end
                
                % ***Check if image of stack are the right size. Use just
                % the first frame. ***
                bData = FixImageSize(bData, parameters.pixels); 

                % If two channels, repeat with violetdata
                if parameters.channelNumber ==2
                   vData = FixImageSize(vData, parameters.pixels); 
                end 
                
                % Make sure dimensions are updated to desired dimensions.
                yDim = parameters.pixels(1);
                xDim = parameters.pixels(2);
                
                % *** Reshape data into a 2D matrix (total pixels x frames) for
                % applying the mask, regressions, and the lowpass filter. Overwrite the variable
                % so you don't take up excess memory. ***
                bData=reshape(bData, yDim*xDim, frames);
                
                % If more than 1 channel, do for violet channel as well
                if channelNumber==2
                    vData=reshape(vData, yDim*xDim, frames);
                end 
                 
                % *** 5. Apply mask *** 
                % Keep only the indices that belong to the mask; Don't rename
                % the variable, because that will take up extra memory/time.
                
                % Only if user said to use mask (if mask_flag= true)
                if mask_flag
                    
                    % Tell user what's happening.
                    disp('Applying mask')
                    
                    % Apply mask (keep only pixels included in the mask).
                    bData=bData(indices_of_mask,:);  

                    % Set aside images for spotcheck 
                    spotcheck_data.masked.blue=bData(:, frames_for_spotchecking);

                    % If more than 1 channel, do for violet channel as well
                    if channelNumber==2
                        vData=vData(indices_of_mask,:);
                        spotcheck_data.masked.violet=vData(:, frames_for_spotchecking);
                    end 
                end
                
                 % ** *6. Filter***
                % Filter data.
                
                % Only if the user said they wanted to (if
                % filter_flag=true).
                if filter_flag
                    disp('Filtering');

                    % filtfilt treats each column as its own channel. Flip 
                    % data as you put it into the filter so it's filtered
                    % in temporal dimension. (frames x pixesl). 
                    bData=filtfilt(b,a, bData'); 

                    bData=bData'; 
                    
                    % Set aside images for spotcheck 
                    spotcheck_data.filtered.blue=bData(:, frames_for_spotchecking);
                    
                    % If 2 channels, repeat for violet channel.
                    if parameters.channelNumber == 2
                        
                        vData=filtfilt(b,a, vData'); 

                        vData=vData'; 
                    
                        % Set aside images for spotcheck 
                        spotcheck_data.filtered.violet=vData(:, frames_for_spotchecking);
                        
                    end 
                end 
                
                
                % *** 7. Correct hemodynamics. ***
                % Run HemoRegression function; 
                disp('Correcting hemodynamics');
                
                % Depending on the method desired by user
                switch correction_method
                
                    case 'regression' 
                        % Run regressions. 
                        data=HemoRegression(bData, vData);
                        
                    case 'scaling'
                        % Run detrend-rescale version of hemo correction
                        % (Laurentiu's version)
                        data=HemoCorrection(bData, vData);
                        
                    case 'vessel regression'
                        % Establish filename of blood vessel mask.
                        filename_vessel_mask=[dir_exper 'blood vessel masks\bloodvessel_masks_m' mouse '.mat']; 
                    
                        % Load blood vessel masks. 
                        load(filename_vessel_mask, 'vessel_masks'); 
                        
                        % Convert vessel masks into 2D matrix
                        vessel_masks =reshape(vessel_masks, yDim*xDim, size(vessel_masks, 3));
                        
                        % If user said to use a brain mask,
                        if mask_flag
                            % Mask each blood vessel mask with the brain mask.
                            vessel_masks=vessel_masks(indices_of_mask, :);
                        end 
                        
                        % Run regression against extractions from blood
                        % vessel masks. 
                        data=VesselRegression(bData, vessel_masks); 
                end
                % Set aside images for spotcheck 
                spotcheck_data.hemodynamicscorrected=data(:, frames_for_spotchecking);
                
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

    % Save the bad trial data. Give the file a name with the date & time so
    % you can always find the list again.
    date_string = strrep(datestr(datetime),':','');
    save([parameters.dir_exper 'bad_trials_' date_string '.mat'], 'bad_trials');
end
