% apply_registration_and_masks.m
% Sarah Wests
% 8/24/21
% Takes the pre-calculated tforms and masks and applies it to the
% hemocorrected data stacks at the same time, then saves. This is happening
% in the same code to reduce the amount of data being saved in intermediate
% processing steps.


% **Using tforms, transform the stacks.**
    
     for mousei=1:size(days_all,2)
        mouse=days_all(mousei).mouse;
        
        % get the list of days for that mouse
        days_list=days_all(mousei).days; 
        
        % for each day
          for dayi=1:size(days_list,1)
            day=days_list(dayi,:); 
         
            % Load that day's tform
            
            % if the tform's empty, then you don't need to register
          
            % Else, perform the registration/warp. Use imwarp to tranform
            % the current image to align with the reference image using the tranform
            % stored in the tform variable
             back=imwarp(bback,tform,'OutputView',imref2d(size(Rback)));
          end 
     end 
