% LoadStack_Hemo_Split.m
% Sarah West 
% 8/18/21
% Modified from SCA_LoadStack_Hemo_Split

function [hData,bData,bback] = LoadStack_Hemo_Split(fileName,skip, usfac, bback_flag, bback)
%%%%%%%%%%%%%%%%%
% HemoName - path and file name to save the hemo corrected data 
% fileName - the directory and name of the original input tiff file 
% skip_min - minimum number of frames to be skipped before illumination stabilization
% usfac - the upsampling factor for dftregistration (usually = 10, which
%         means accuracy down to 1/10 of a pixel).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load in imaging stack and separate channels into blue and violet data matrices
disp('Loading');
%Read .tif file into struct and print the fileName and path to the command
%line

 
    im_list=tiffreadAltered_SCA(fileName,[], 'ReadUnknownTags',1); %if the
    %file specified by HemoName doesn't exist use the function
    %tiffreadAltered_SCA to load the original tiff file into a structure
    %called im_list which loads each frame as a line within the structure
    

    [yDim, xDim]=size(im_list(1).data); %get the dimensions of the first 
    %image in im_list by looking in the data  field and hold them in xDim and
    %yDim variables (dimensions are in pixels)
    
    im_pixels=yDim*xDim; %multiply the dimensions of a single image to 
    %get the number of pixels in each image and hold the number in the
    %im_pixels variable

    nim=length(im_list); %see how many images are in the im_list variable 
    %(i.e. how many images are in the stack) and hold the number in
    %variable nim

    err=[]; %initialize the variable err as blank 
    %(this will tell us if there's an error later)

    if nim<6000 %if the number of images in the stack specified by 
        %variable nim is less than 6000

        bData=[]; %all variables are initializes as empty and the err
        vData=[]; %variable displays 'stack too short for further analysis
        err='Stack too short for further analysis'
    end

    if mod(skip,2)==0 %if the remainder of the length of the skip 
        %(specified as an input argument) after division by 2 is 0
        skip=skip-1; %subtract 1 from the skip value 
    end

    if isempty(err) %if the err variable is empty (i.e there is no error 
        %and the stack is longer than 6000 frames) 

        %Check intensity of images to detect which channel is blue vs. violet

        im1=im_list(skip).data; %get the first image at the end of the skip
        %and hold it in variable im1
        im2=im_list(skip+1).data; %get the second image after the skip
        %and hold it in im2
        lev1=mean2([im1(110:160,50:100) im1(110:160,150:200)]); 
        %get the mean gray level from a brain ROI in im1 and hold it in
        %variable lev1
        lev2=mean2([im2(110:160,50:100) im2(110:160,150:200)]); 
        %get the mean gray level from a brain ROI in im2 and hold it in
        %variable lev2

        if lev1~=lev2 % if lev1 doesn't equal lev2 (i.e. the mean gray levels
            %are not equal between im1 and im2

            if lev1>lev2 %if lev1 is greater than lev2

                sel470=skip:2:nim; %the frame indexes for the 470 images
                % held in sel470 start at the skip and are every other 
                %image until the end of the stack
                
                sel405=skip+1:2:nim; %the frame indexes for 405 images are 
                %held in sel405 and start at the image after the skip going
                %every other image until the end of the stack
            else
                sel470=skip+1:2:nim; %if lev2 is greater than lev1 then 
                %the indices for the 470 vs. 405 images are flipped
                sel405=skip:2:nim;
            end

            len=min(length(sel470),length(sel405)); %get the minimum stack
            %length of the 470 and 405 frame indexes
            sel470=sel470(1:len); %limit the frame indices for each color 
            %stack to the minimum number of indices (takes care of uneven
            %image numbers by making them even)
            sel405=sel405(1:len);

            stk_ref=round(len/2); %get the stack reference frame number 
            %stk_ref by rounding the stack length by 2 (used as background)

        else
            bData=[]; %if illumination between the two channels is not different
            vData=[]; %err variable is populated with 'Stack illuminate does
            err='Stack illumination does not differentiate hemo signal. No further anakysis'
        end
    end

    if isempty(err) %if the err variable is still empty
        disp('Registering');
        
        %initialize bData and vData as a matrix of zeros with size frame number and pixels
        bData = zeros(length(sel470),im_pixels); 
        vData = zeros(length(sel405),im_pixels);
        
        % select a "background" image (reference image); number defined by stk_ref; and convert to a
        % double
        if bback_flag==0 % don't need to make a new one
            % do nothing
        else 
            % make a new one 
            bback=double(im_list(sel470(stk_ref)).data);
        end
        %vback=double(im_list(sel405(stk_ref)).data);
        
        %convert 1D background images to 2D images
        bback=bback(1:yDim,1:xDim); 
        %vback=vback(1:yDim,1:xDim);
        
        %perform fourier transform of the background images 
        fbback=fft2(bback); 
        %fvback=fft2(vback); 
         
        %for each frame of the stack as indexed by variable t
        for t=1:len 
            %get the t-th image of each channel's stack and convert to a double 
            bim=double(im_list(sel470(t)).data);
            vim=double(im_list(sel405(t)).data);
            
            %convert 1D images to 2D images
            bim=bim(1:yDim,1:xDim); 
            vim=vim(1:yDim,1:xDim);
                   
            % Use dftregistration function to align the fourier transform of
            % the current BLUE image with the fourier transform of the
            % background/reference image of the reference BLUE image
            
            [output , bGreg] = dftregistration(fbback, fft2(bim),usfac);
            
            % Grab variables from "output" that you'll need to find the registered VIOLET image
            % From dftregistration code: output=[error,diffphase,row_shift,col_shift];
            diffphase=output(2);
            row_shift=output(3); 
            col_shift=output(4); 
            
            % Then, calculate the registered VIOLET image using the output
            % variables from the blue image registration; from
            % dftregistration code.
            
                % Create a Fourier-transformed version of the image you want to
                %register, keeping with the name of the variable used in the
                %dftregistration code to try to keep copying and pasting
                %simple.
                buf2ft=fft2(vim);  
                
                % find dimensions of images needed for the calulations
                % (from dftregistration.m)
                [nr,nc]=size(buf2ft);
                Nr = ifftshift(-fix(nr/2):ceil(nr/2)-1);
                Nc = ifftshift(-fix(nc/2):ceil(nc/2)-1);

                % calculate violet registered image
                if (usfac > 0)
                    [Nc,Nr] = meshgrid(Nc,Nr);
                    vGreg = buf2ft.*exp(1i*2*pi*(-row_shift*Nr/nr-col_shift*Nc/nc));
                    vGreg = vGreg*exp(1i*diffphase);
                elseif (usfac == 0)
                    vGreg = buf2ft*exp(1i*diffphase);
                end

            %Get the absolute value of the inverse fourier transform of the
            %registered images; overwrite old variables to reducce memory
            %needs
            bim = abs(ifft2(bGreg)); 
            vim = abs(ifft2(vGreg));
            
            % reshape the data because that's how the "detrend" function
            % wants it to look in the hemo correction step. Have to have all pixels in the 2nd
            % dimension. Overwrite old variables to reduce memory
            % needs
            bim=reshape(bim,[1 im_pixels]); 
            vim=reshape(vim,[1 im_pixels]);
            
            %put the new registered image into variable vData
            %at the correct frame number t. 
            bData(t,:) = bim;
            vData(t,:) = vim;
        end
       
        disp('Correcting Hemodynamics');
        
        
        % Hemo correct the data on a pixel-by-pixel basis. Convert to single precision. 
        hData=single(detrend(bData)./mean(bData)-detrend(vData)./mean(vData)) ;
        
        % convert hData into a 3D matrix, because that's how my brain works best 
        hData=reshape(hData', yDim, xDim, len);
        bData=reshape(bData', yDim, xDim, len);

    else
        hData=[]; %I think this means if no images are loaded leave hData
        bback=[]; %and bback blank variables
    end
end
    