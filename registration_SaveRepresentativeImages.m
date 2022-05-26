% registration_SaveRepresentaiveImages.m
% Sarah West
% 8/25/21

% Loads individual images for differentiating between ligh channels, then
% saves a representaive image for the day. 

function []=registration_SaveRepresentativeImages(dir_dataset, dir_exper, days_all, skip, pixel_rows, pixel_cols, rep_stacki, rep_framei)

    dir_out_base=[dir_exper 'representative images\'];
    disp(['Data saved in ' dir_out_base]); 
    
    dbase_str='stacks\' ; %name the optical data subfolder and call it dbase_str
    %usually this is called stacks but other people might call it something
    %else. It's where the tiff files are stored and must be entered manually
    
    % for each mouse
    for mousei=1:size(days_all,2)
        % Get the mouse name
        mouse=days_all(mousei).mouse;
        
        % Get the mouse's dataset days
        days_list=days_all(mousei).days; 
        
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
            dir_in=[dir_dataset day '\' day 'm' mouse '\' dbase_str]; 
            
            % get the day name
            day=days_list(dayi,:); 
            
            % make the output directory by day
            dir_out=[dir_out_base '\' mouse '\' day '\']; 
            mkdir(dir_out);
            
            % find the list of stacks in that day (so you can find the
            % first one)
            list=dir([dir_in '0*.tif']);
            
            % Find the stack to use for the representative image.
            stack_number=list(rep_stacki).name(2:3);   
            
            % Assign the input file name 
            input_fileName=[dir_in list(rep_stacki).name]; 
            
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
                im_list=tiffreadAltered_SCA(input_fileName, image_indices, 'ReadUnknownTags',1);
                
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
