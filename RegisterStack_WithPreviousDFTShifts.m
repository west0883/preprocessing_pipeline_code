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

function [registered_stack] =RegisterStack_WithPreviousDFTShifts() 

            
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
            vim = abs(ifft2(vGreg));
            
end 