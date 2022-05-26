% RegisterStack_WithPreviousDFTShifts.m
% Sarah West
% 8/26/21

% Takes the frame-by-frame transforms previously calculated by a
% dftregistration and applies it to a stack. (dftregistration will give
% this to you as Greg variable as you're calculating transforms, but this
% code allows you to apply the transforms to a new stack. This is really
% only important when you're aligning violet channel images based on the
% transforms calculated on the blue images--> for accurate hemodynamics
% correction.) The calculations were copied from dftregistration. 

% Inputs:
% tforms -- Is an output from RegisterStackWithDFT. Is a 2D matrix, with
    % (first dim) diffphase,row_shift,col_shift for each frame (2nd dim).
% stack_to_register -- a (violet channel) stack matrix to register. 3D
    % matrix (pixels, pixels,frames)
% usfac -- "upsampling factor"; Determines the sub-pixel resolution of the registration; 

% Outputs:
% registered_stack -- the registered stack. 3D matrix (pixels, pixels,
    % frames)   
    
function [registered_stack] =RegisterStack_WithPreviousDFTShifts(tforms, stack_to_register, usfac) 
    
    % Initialize output registered stack
    registered_stack=NaN(size(stack_to_register)); 
    
    % Find number of frames of stack
    frames=size(stack_to_register,3); 
    
    % For each frame 
    parfor t=1:frames
       % Grab variables from tforms for this frame.
       diffphase=tforms(1,t);
       row_shift=tforms(2,t); 
       col_shift=tforms(3,t);
    
       % Grab the image you want to work with 
       im=stack_to_register(:,:,t); 
       
       % Create a Fourier-transformed version of the image you want to
       % register, keeping with the name of the variable used in the
       % dftregistration code to try to keep comparisons simple
       buf2ft=fft2(im);  

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
        %registered images.
        registered_im = abs(ifft2(vGreg));
        
        % Put registered image into variable holding registered stack.
        registered_stack(:,:,t)=registered_im;
    end
end 