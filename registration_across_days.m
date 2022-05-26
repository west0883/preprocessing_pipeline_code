% registration_across_days.m
% Sarah West
% 8/23/21
% Modified from SCA_manual_masking.m, just the registration across days
% parts


% Run this scrip twice:
% First time with with Preffered_mask_list empty to inspect background
% images for all days. Use figures to select prefered background for each mouse
% Populate the Preffered_mask_list with the selection (mouseID then day index; 
%ex:. [1 6] means mouseID 1 and day 6 
%This time you will be asked to manually draw the brain mask for each mouse once using the
% selected background


data_dir='X:\Angie_new\SCA1_Hemo_Data_041421\'; %data_dir is a variable
%that holds the path to where the hemo data is stored

SCA_day_list %runs a code called SCA_day_list.m and loads the day_list
%this will also need to be manually changed for each database

re_mask=1; %set it to 1 if want to redraw masks (it's a true/false statement)
%where 0 is false and it won't perform and 1 is true
MaskComponent=2; % how many disjunct brain domains are in the field of view
%usually this is two but for the cerebellum it'll be 1

trans_ix=1; %set to 1 to check the between stacks registration
%another true/false statement


Preffered_mask_list=[1 6]; % populate in pairs [mouse day]
%Preffered_mask_list=[53 31;54 62;56 45; 57 64;59 71;60 54;79 143;80 171;81 193;82 187;83 154;84 99;85 86];

[optimizer, metric] = imregconfig('monomodal');
%set the configurations for intensity-based image registration using
%imregconfig...(keep monomodal because images are similar
%intensity/contrast). Outputs are optimizer and metric

metric=registration.metric.MeanSquares; %set metric variable to meansquares
%method of registration
optimizer.MaximumStepLength=3e-3; %set optimizer maximum step-length and 
%iterations for performing registration
optimizer.MaximumIterations=200;

d_list=[]; %initailize recording days per mouse as a blank variable and 
%call it d_list
for d=1:length(day_list) %for each recording day (we'll iterate through
    %days with variable d)
    day_in=day_list{d}; %make day_in variable the path to the day you're on
    m=str2num(day_in(end-3:end-1)); %get mouseID for each day 
    %(this should be the last 3 characters of day_in and should only be numbers)
    
    d_list(d,:)=[d m]; %populate d_list variable with the day index 
    %(from the day_list) and mouseID for each day
end

m_id=unique(d_list(:,2)); %find unique mouseIDs in d_list and call it m_list 
%(this should give you all of the mouseIDs in your database in one
%variable)

fi=501; %set variable fi (figure number) to 501;
pos=0;

for mouse=1%m_id' %%pick a mouseID you want to analyze and call it mouse
    %otherwise use m_id' to cycle through all mice
    
    fname=sprintf('Reg_Ref_M%03d.mat',mouse); %print the file name for the
    %mask for the mouse you're looking for M%03d puts the mouseID from mouse
    %as a 3-digit number after M and store it in fname
    
    ref_name=[data_dir,fname]; %combine the data_dir and fname to create
    %the path and file name for where the mask will be stored and keep it
    %in variable ref_name
    s_list=d_list(d_list(:,2)==mouse,1); %index into the d_list and find
    %day where your mouse was recorded and store the day index in s_list

    RMask=[]; %initialize variable RMask as a blank matrix (this will hold
    %the reference day's mask)
    Rback=[]; %initalize variable Rback as blank matrix (this will hold the
    %reference background
    
    if isempty(Preffered_mask_list) %if the preferred_mask_list variable is empty
        fmsk=[]; %then variable fmsk is a blank variable
    else
        fmsk=find(Preffered_mask_list(:,1)==mouse); %if preferred_mask_list
        %is populated, then find the index in the preferred_mask_list that
        %contains the preferred mask for the mouse you're on
    end
    
    if exist(ref_name,'file')==0 || re_mask==1 %if mask file doesn't exist
        %or if the re_mask is required it will go through the masking loop
    
        
        
        if ~isempty(fmsk) %if the variable fmsk is not empty
            rday=Preffered_mask_list(fmsk,2); %get the day index for the 
            %preferred mask and call it rday
            rday_in=day_list{rday}; %get the path for the day containing 
            %the preferred mask and background and hold it in variable
            %rday_in

            load([data_dir,rday_in,'Back.mat']); %load the background image
            %for the preferred mask day and mouse by combining the
            %data_dir, and rday_in paths with the background file name
            %'Back.mat'; this loads the bback from the Back.mat file

            Rback=bback; %make Rback equal the bback variable you just 
            %loaded (i.e. the 2D background blue image)

            back0=(bback-min(min(bback)))/(max(max(bback))-min(min(bback)));
            %get the average fluorescence value of the background image and
            %hold the value in back0
            MRMask=[]; %initalize MRMask as a blank variable (for manual 
            %reference mask)

%%%%%%%%%%%%%%%%%% Manual Masking Loop%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for k=1:MaskComponent %for each mask component which we'll 
                %index with variable k

                f=figure;hold on %create a figure called f and turn hold on
                %to keep everything in view
                title(sprintf('Masking Mouse %d MaskComponent %d of %d',mouse,k,MaskComponent))
                %put title on figure with the mouseID number and which
                %component you're drawing (i.e 1 of 2 or 2 of 2)
                f.WindowState='maximized'; %set figure window to maximized
                cMask=roipoly(back0); %draw an ROI for one side of the mask on the 
                %background image and store the boundary coordinates in variable cMask
                delete(f) %when done delete the figure

                if isempty(MRMask) %if variable MRMask is empty
                    MRMask=cMask; %make MRMask equal the cMask variable
                    %so now MRMask holds the boundaries of one side of the mask
                else
                    if ~isempty(cMask) %if variable cMask is not empty
                        MRMask=MRMask+cMask; %add new cMask (other half of 
                        %brain mask to the one already drawn; this if for
                        %when the second image comes up and the loop has
                        %repeated)
                    end
                end
            end
            
%%%%%%%%%%%%%%%%%%%%%%%%% saves the mask and the background %%%%%%%%%%%%%%%%%%%%          
            if ~isempty(MRMask) %if MRMask is not empty

                MRMask(MRMask>0)=1; %set all areas of the mask in MRMask
                %that are greater than 0 equal to 1 (i.e. areas covering
                %the brain)
                RMask=MRMask; %set variable RMask equal to MRMask so that
                %manual mask is now contained in RMask
                %RMSize=sum(sum(1-RMask))/im_pixels; %not needed
                ref_name=[data_dir,fname]; %create the file path and
                %file name by combining the data_dir and fname variables as
                %defined earlier and call it ref_name
                save(ref_name,'RMask','Rback') %save RMask and Rback to 
                %in the path and file ref_name (file is created in the main
                %directory called Reg_Ref_M(3-digit mouseID).mat and stores
                %the mask and reference background that everything gets
                %aligned to later
            end
        end
    else
        load(ref_name); %if file ref_name exists load it
    end

%%% goes through all days grouped by mouse and plots the background and the mask if exists
    
    
    for dix=s_list' %for each day in the s_list for a mouse (defined at line 68)
        
        pos=pos+1; %iterate the pos variable by 1 (starts at 0)
        if pos>16 %if pos is greater than 16
            pos=1; %set pos back to 1
            fi=fi+1; %and iterate the figure number held in fi by 1
        end

        day_in=day_list{dix}; %get the path to the day you're on and hold
        %it in the day_in variable
        
        if isfile([data_dir,day_in,'Back.mat']) %If the background imag
            %for the current day is a file called Back.mat
            
            load([data_dir,day_in,'Back.mat']); %load the background file
            
            if ~isempty(Rback) %if Rback (reference background) is not empty
                
                FMask=RMask; %set FMask equal to RMask (reference mask)
            
                if trans_ix==1 % this loop performs between stacks registration
                    %if the trans_ix (tranform) variable is 1

                    tform = imregtform(bback, Rback, 'rigid', optimizer, metric);
                    %figure out the transform to align the current
                    %background image with the reference background and
                    %hold it in variable tform
                    back=imwarp(bback,tform,'OutputView',imref2d(size(Rback)));
                    %use imwarp to tranform the current background to align
                    %with the reference background using the tranform
                    %stored in the tform variable
                    
                    %MSize=RMSize; %not needed          
                    
                    [Reg,FinSize,DomId] = ClustReg(1-FMask,100);
                    %Checks that the registration transform does not
                    %fragments the mask into small pieces; LSP
                    Reg(Reg>0)=1;
                    BW=Reg*0.1;
                    % BW is the variable that shows the mask superimposed
                    % on the brain LSP
                else
                    BW=(1-FMask)*0.1;
                end
            else
                BW=zeros(size(bback));
            end

            figure(fi);subplot(4,4,pos);axis square %create a figure with 
            %specified by fi and plot 16 backgrounds/masks in a subplot
            back=bback; %set back equal to bback (current day's background)
            superimpose_GCAMP_singlemap; %run code superimpose_GCAMP_singlemap.m
            %plots each background in grayscale with the mask overlaid in
            %blue
            title(sprintf('M%d D%d',mouse,dix)); %title each graph with the
            %mouseID and recording day index
        else
            figure(fi);subplot(4,4,pos);axis square %if background variable
            %is empty then create an axes
            title(sprintf('m%d D%d S%1.2f',mouse,dix)); %add the axes title
            %with mouseID and recording day index; but this time it won't
            %populate with a photo
        end         
    end
end