% check_if_corrupt_fast.m
% Sarah West
% 9/2/21
% Checks if a file/stack is corrupt WITHOUT HAVING TO LOAD IT :D
% Basis code is from https://stackoverflow.com/questions/38325121/check-if-mat-file-is-corrupt-without-load
% matfile doesn't need to load in the whole file, and it issues a warning
% if the file is corrupt. 

% Warning ID is : 'MATLAB:whos:UnableToRead'

matfile([filename]);
[~, warnId] = lastwarn;

if strcmp(warnId, 'MATLAB:whos:UnableToRead')
    % File is corrupt
end