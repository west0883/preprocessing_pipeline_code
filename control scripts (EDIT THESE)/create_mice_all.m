% create_mice_all.m
% Sarah West
% 8/17/21

% Creates and saves the lists of data you'll use for the given experiement
% (mouse names and days of data collected). 

% Each row of the structure is a different mouse. 


%% Parameters for directories
clear all;

experiment_name='Motorized Treadmill';

dir_base='Y:\Sarah\Analysis\Experiments\';
dir_exper=[dir_base experiment_name '\']; 

dir_out=dir_exper; 

%% List of days

mice_all(1).name='1087'; 
mice_all(1).days(1).name='071021';
mice_all(1).days(1).stacks='all'; 
mice_all(1).days(2).name='071221';
mice_all(1).days(2).stacks='all'; 
mice_all(1).days(3).name='071321';
mice_all(1).days(3).stacks='all'; 

            
mice_all(2).name='1088';
mice_all(2).days(1).name='070921';
mice_all(2).days(1).stacks='all'; 
mice_all(2).days(2).name='071221';
mice_all(2).days(2).stacks='all'; 
mice_all(2).days(3).name='071921';
mice_all(2).days(3).stacks='all';
mice_all(2).days(4).name='093021';
mice_all(2).days(4).stacks='all';
     

mice_all(3).name='1096';
mice_all(3).days(1).name='070921';
mice_all(3).days(1).stacks='all';
mice_all(3).days(2).name='071321';
mice_all(3).days(2).stacks='all';
mice_all(3).days(3).name='072021';
mice_all(3).days(3).stacks='all';
mice_all(3).days(4).name='092321';
mice_all(3).days(4).stacks='all';


mice_all(4).name='1099';
mice_all(4).days(1).name='071021';
mice_all(4).days(1).stacks=[1 3:13]; 
mice_all(4).days(2).name='071921';
mice_all(4).days(2).stacks='all';                    
mice_all(4).days(3).name='072021';
mice_all(4).days(3).stacks='all';
mice_all(4).days(4).name='093021';
mice_all(4).days(4).stacks='all';




save([dir_out 'mice_all.mat'], 'mice_all');
            
