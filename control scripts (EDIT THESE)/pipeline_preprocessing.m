% pipeline_preprocessing_MotorizedTreadmill.m
% Sarah West
% 8/17/21

% This script allows you to run all steps of the preprocessing pipeline via 
% the "Run Section" feature of the Matlab Editor. Each step of the preprocessing 
% is called as a function. 

% Use "create_mice_all.m" before using this.

% ** should add a spatial filtering step; probably an averaging**
%
%% Initial Setup  
% Put all needed paramters in a structure called "parameters", which you
% can then easily feed into your functions. 
clear all; 

% Output Directories

% Create the experiment name. This is used to name the output folder. 
parameters.experiment_name='Motorized Treadmill';

% Output directory name bases
parameters.dir_base='Y:\Sarah\Analysis\Experiments\';
parameters.dir_exper=[parameters.dir_base parameters.experiment_name '\']; 

% *********************************************************
% Data to preprocess

% (DON'T EDIT). Load the "mice_all" variable you've created with "create_mice_all.m"
load([parameters.dir_exper 'mice_all.mat']);

% Add mice_all to parameters structure.
parameters.mice_all = mice_all; 

% ****Change here if there are specific mice, days, and/or stacks you want to work with**** 
% If you want to change the list of stacks, use ListStacks function.
% Ex: numberVector=2:12; digitNumber=2;
% Ex cont: stackList=ListStacks(numberVector,digitNumber); 
% Ex cont: mice_all(1).stacks(1)=stackList;

 parameters.mice_all=parameters.mice_all(2);
 parameters.mice_all(1).days=parameters.mice_all(1).days(3);
 % parameters.mice_all(1).days(1).stacks = 12;

% **********************************************************************8
% Input Directories

% Establish the format of the daily/per mouse directory and file names of 
% the collected data. Will be assembled with CreateFileStrings.m Each piece 
% needs to be a separate entry in a cell 
% array. Put the string 'mouse', 'day', or 'stack number' where the mouse, 
% day, or stack number will be. If you concatenated this as a sigle string,
% it should create a file name, with the correct mouse/day/stack name 
% inserted accordingly. 


parameters.dir_dataset_name={'Y:\Sarah\Data\' parameters.experiment_name, '\', 'day', '\', 'm', 'mouse number', '\stacks\'};
parameters.input_data_name={'0', 'stack number', '.tif' }; 

% Give the number of digits that should be included in each stack number.
parameters.digitNumber=2; 

% *************************************************************************
% Parameters

% Sampling frequency of collected data (per channel), in Hz or frames per
% second.
parameters.sampling_freq=20; 

% Number of channels data was collected with. (2=had a blue and violet
% channel, 1= had only blue and need to find blood vessel masks for
% hemodynamic correction. 
parameters.channelNumber=2;

% Method of hemodynamics correction.
% Options:
% 'regression' -- Runs regression of blue pixels against corresponding
% violet pixels
% 'scaling' -- Has the same ultimate output as 'regression', but also
% calculates everything as DF/F.
% 'vessel regression'-- regresses (blue) pixels against masks drawn from
% blood vessels in the same (blue) channel. 
parameters.correction_method='regression';

% Number of initial frames to skip, allows for brightness/image
% stabilization of camera
parameters.skip=1200; 

% Pixel ranges for checking brightness to determine which channel is which.
% Is a portion of the brain. 
parameters.pixel_rows=110:160;
parameters.pixel_cols=[50:100 150:200]; 

% Representative images parameters.

    % The nth stack in the collected data that you want to use for the
    % representative image
    parameters.rep_stacki=1; 

    % The nth frame in the chosen stack that you want to use for the
    % representative image (after the skipped frames). 
    parameters.rep_framei=1;

% Across-day registration parameters

    % Set up transformation type (rigid, similar, or affine)
    parameters.transformation='affine';

    % Determine configuration for intensity-based image registration using
    % imregconfig...(keep monomodal because images are similar intensity/contrast)
    parameters.configuration='monomodal';

    % Set optimizer maximum step-length and iterations for performing registration
    parameters.max_step_length=3e-3;
    parameters.max_iterations=500;
    

% Do you want to mask your data? Yes--> mask_flag=true, No-->
% mask_flag=false.
parameters.mask_flag=true; 

% Do you want to spatially filter your data? Yes--> filter_flag=true, No-->
% filter_flag=false.
parameters.filter_flag=false; 

% Spatial filtering parameters. (These aren't used if filter_flag=false,
% because no filtering is performed.) 
    % Order of Butterworth filter you want to use.
    parameters.order=5; 

    % Low cut off frequency
    %fc1=0.01; 
    
    % High cutoff frequency
    parameters.fc2=7; 

    % Find Niquist freq for filter; sampling divided by 2
    parameters.fn=parameters.sampling_freq/2; 

    % Find parameters of Butterworth filter. 
    [parameters.b, parameters.a]=butter(parameters.order, parameters.fc2/parameters.fn,'low');

% Set a minimum number of frames each channel of the stack needs to have to
% consider it a valid stack for full processing. (If less than this, code 
% will assume something very bad happened and won't continue processing the
% stack, will jump to the next stack.) 
parameters.minimum_frames=5999; 

% Give list of individual frames to save from intermediate steps of
% preprocessing from each stack to use for spot checking.
parameters.frames_for_spotchecking=[1 500 1200 2400 3000]; 

% Set "upsampling factor" for dftregistration function (for within stack & 
% within day registration); determines the sub-pixel resolution of the registration; 
parameters.usfac=10;   

%% Find representative images from each day. (Automatic).
% Saves a representative blue-channel image from each day of recording.
% You'll use this to align data within days, and later you'll pick one of
% these per mouse as the image to use to draw the mask and align data
% across imaging days. 

% (DON'T EDIT). Run code.
registration_SaveRepresentativeImages(parameters); 

%% Pick across-day reference (Has interactive steps)
% Choose which day to use as the reference day to align all days to in each
% mouse. (Pick the one that's the most centered, straight, nice-looking).

% Determine how many subplots you want for displaying your potential
% reference images at once. If you have lots of images, you'll want more
% subplots. If you have only a few, you want only a few subplots so each
% image is plotted as large as possible. 
parameters.plot_sizes=[2,2]; 

%(DON'T EDIT). Run code.
registration_pick_reference_day_permouse(parameters);

%% Registration across days. (Automatic)
% Calculates the transformation ("tform") that will be applied to images.
% Also saves the before-and-after registration images overlaid together
% (from imshowpair) so you can inspect how well the registration went.

% (DON'T EDIT). Run code.
registration_across_days(parameters);

%% Redo registration manually of any days that did badly above. (Has interactive steps). 

% List of days to redo. Format: cell array, first column mouse, second
% column day. Each row is the mouse and day of a day that should be redone.
% Eg redo={mouse, day}--> redo={'1088', '070921'}; 
redo={'1088','093021'}; 

% The function will plot both the reference image and the current image.
% Select 3+ points on the first image, hit "enter", then select the same 3+
% points on the second image & hit enter. (I like to use blood vessel
% branch points).

% (DON'T EDIT). Run code.
registration_Manual_Redo(redo, parameters);

%% Draw masks (Has interactive steps)
% Only need to do once per mouse. 
% [Add instructions here.]

% (DON'T EDIT). Run code.
manual_masking_loop(parameters);

%% Draw blood vessel masks (Has interactive steps) 
% If you only have one channel, draw blood vessel and background masks for
% hemodynamic regression correction. 
% Only need to do once per mouse. 

manual_bloodvesselmasking_loop(parameters);

%% Apply Preprocessing (Automatic,takes 5+ minutes per stack).
% Applies all the steps of preprocessing. Doing this all in one step so 
% intermediate steps of preprocessing aren't saved, which takes up a lot of storage space. 

% This code: 
% 1. Reads the recorded data tiffs in as matrics.
% 2. Separates data into blue and violet channels. 
% 3. Registers within-stack/across stacks within a day. 
% 4. Applies the pre-calculated across-day tforms.
% 5. Applies the pre-calculated mask per mouse.
% 6. Corrects hemodynamics. 
% 7. Applies any filtering. 
% 8. Saves preprocessed stacks. 

%(DON'T EDIT). Run code.
Preprocessing(parameters);

%% Check if any of the files are corrupt. 
% Determines if a stack is corrupt and re-preprocesses it if so.

%(DON'T EDIT). Run code.
check_stacks(parameters); 

