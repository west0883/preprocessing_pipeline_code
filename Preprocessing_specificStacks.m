% Preprocessing_specificStacks.m
% Sarah Wests
% 9/15/21

% Runs Preprocessing code, but only on specific stacks. Meant for use after
% check_stacks.m 

% This is happening all in the same code to reduce the amount of data being 
% saved in intermediate processing steps. THIS CODE DOES:

% 1. Reads the data tiffs in as matrics.
% 2. Separates data into blue and violet channels. 
% 3. Registers within-stack/across stacks within a day. 
% 4. Applies the pre-calculated across-day tforms.
% 5. Applies the pre-calculated mask per mouse.
% 6. Corrects hemodynamics via the user's chosen method.
% 7. Applies any filtering. 
% 8. Saves preprocessed stacks. 

function []=Preprocessing_specificStacks(mouse, day, stack_number, dir_exper, dir_dataset_name, input_data_name, b, a, usfac, skip, pixel_rows, pixel_cols, frames_for_spotchecking, filter_flag, digitNumber, minimum_frames, correction_method, channelNumber)
    
    % Establish base input directories
    dir_in_base_tforms=[dir_exper 'tforms across days\']; 
    dir_in_masks=[dir_exper 'masks\'];
    dir_in_ref=[dir_exper 'representative images\']; 
    
    % Establish base output directory
    dir_out_base=[dir_exper 'fully preprocessed stacks\'];
    
    % Load reference days
    load([dir_in_ref 'reference_days.mat']);
    
    % Make skip always odd.
    if mod(skip,2)==0 
        %if the remainder of the length of the skip 
        %(specified as an input argument) after division by 2 is 0
        skip=skip-1; %subtract 1 from the skip value 
    end
    
    % Load the mask indices for this mouse
    load([dir_in_masks 'masks_m' mouse '.mat'], 'indices_of_mask'); 

    % Create data input directory and clean output directory. 
    dir_in=CreateFileStrings(dir_dataset_name, mouse, day, []);
    dir_out=[dir_out_base mouse '\' day '\']; 

    % Create data input name
    filename=CreateFileStrings([dir_dataset_name input_data_name], mouse, day, stack_number);

    % Load the reference image for this day
    load([dir_in_ref mouse '\' day '\bRep.mat']); 

    % Load the across-day tform for this day. 
    load([dir_in_base_tforms mouse '\' day '\tform.mat']); 
            
    % *** 1. Read in tiffs.***
    disp('Reading tiffs'); 
    im_list=tiffreadAltered_SCA(filename,[], 'ReadUnknownTags',1);              

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
        im1=im_list(skip).data; 
        im2=im_list(skip+1).data;

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
        if frames<minimum_frames
           warning('This stack is too short-- will not be processed.');

           return    
        end

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

    case 1 
       % If only one channel

       % Get list of frames after the skip
       frames_list=skip:nim; 

        % Figure out if this frames number is long enough for
        % further processing. If not, quit this stack. 
        if frames<minimum_frames
           warning('This stack is too short-- will not be processed.');

           % Go to next iteration of stacki for loop.
           return
        end
    end

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


    % Reshape data into a 2D matrix (total pixels x frames) for
    % applying the mask, regressions, and the lowpass filter. Overwrite the variable
    % so you don't take up excess memory. 
    bData=reshape(bData, yDim*xDim, frames);

    % If more than 1 channel, do for violet channel as well
    if channelNumber==2
        vData=reshape(vData, yDim*xDim, frames);
    end 


    % *** 5. Apply mask *** 
    % Keep only the indices that belong to the mask; Don't rename
    % the variable, because that will take up extra memory/time.
    disp('Applying mask')
    bData=bData(indices_of_mask,:);  

    % Set aside images for spotcheck 
    spotcheck_data.masked.blue=bData(:, frames_for_spotchecking);

    % If more than 1 channel, do for violet channel as well
    if channelNumber==2
        vData=vData(indices_of_mask,:);
        spotcheck_data.masked.violet=vData(:, frames_for_spotchecking);
    end 

    % *** 6. Correct hemodynamics. ***
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

            % Run regression against extractions from blood
            % vessel masks. 
            data=VesselRegression(bData, vessel_masks, yDim, xDim); 
    end
    % Set aside images for spotcheck 
    spotcheck_data.hemodynamicscorrected=data(:, frames_for_spotchecking);


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
