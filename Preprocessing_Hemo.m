% Preprocessing_Hemo.m
% Sarah West
% 8/18/21
% Edited from SCA_Preprocessing_Hemo.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Register within stacks & across stacks within days, correct hemodynamics, 
% apply tforms for across-day transformations, apply drawn masks, lowpass filter 
% and save data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function []=Preprocessing_Hemo(dir_dataset, dir_exper, days_all, skip, usfac)
    % dir_dataset - where your input/raw data is saved
    % dir_exper -
    dir_out_base=[dir_exper 'hemodynamics corrected\'];
    disp(['data saved in ' dir_out_base]); 
    
    dbase_str='stacks\' ; %name the optical data subfolder and call it dbase_str
    %usually this is called stacks but other people might call it something
    %else. It's where the tiff files are stored and must be entered manually
    
    % for each mouse
    for mousei=1:size(days_all,2)
        % get the mouse name
        mouse=days_all(mousei).mouse;
        
        % get the mouse's dataset days
        days_list=days_all(mousei).days; 
        
        % for each day of the mouse 
        for dayi=1:size(days_list,1)
            
            % get the day name
            day=days_list(dayi,:); 
            
            % make the output directory by day
            dir_out=[dir_out_base '\' mouse '\' day '\']; 
            mkdir(dir_out);
            
            %create the dir_day (input directory by day)
            dir_day=[dir_dataset day '\' day 'm' mouse '\' dbase_str]; 
                                                    
            % find the list of stacks in that day
            list=dir([dir_day '00*.tif']);
            
            % for each stack
            for stacki=1:size(list,1)
                
               % get the stack number (for making output names and disp progress)
                stack_number=list(stacki).name(2:3);   
                
               % find if there is a selected reference image for this day
               % (dftregistration does well with horizontal shifts across stacks within a day, but it doesn't 
               % rescalethe image, making it a poor choice for across-day
               % differences--which might have different zoom levels)
           
                  if isfile([dir_out '\bback.mat'])==1 % If it exists,
                    % then enter bback_flag as 0; don't need to create a new
                    % one
                    bback_flag=0; 
                    load([dir_out 'bback.mat']);
                   else 
                    % then enter bback_flag as 1; need to create a new one
                    bback_flag=1;
                    bback=[];
                  end 
                
                disp(['mouse ' mouse ', day ' day ', stack ' stack_number]);
                % assign the input file name 
                input_fileName=[dir_day list(stacki).name]; 
                
                
                
                % Hemocorrected data output name
                output_fileName=[dir_out 'hData' stack_number '.mat'];
                 
                % run funtion that carries out the
                % preprocessing and saves the results (LoadStack_Hemo_Split); 
                [hData, bData, bback]=LoadStack_Hemo_Split(input_fileName,skip, usfac, bback_flag, bback);
                
                disp('Saving');
                
                % Save example blue images to spot-check how well the
                % registration went.
                try
                    % Select some arbitrary frames (I used only up to frame 
                    % 3000 because the function below only outputs if available 
                    %stack is at least 3000 frames long). If it throws an error, just make it empty.
                    example_registered_images=bData(:,:,[1 1000 1500 3000]);
                catch
                    % If it throws and error, just make it empty
                    example_registered_images=[];    
                end
                % Save the hemo corrected data, make it v7.3 compatible
                save(output_fileName, 'hData','example_registered_images', '-v7.3'); 
                
                % If you had to create a reference image (bback) for this
                % day, save it now. 
                if bback_flag==1
                    save([dir_out 'bback.mat'], 'bback');
                end
            end 
            
            
        end 
    end
end 

