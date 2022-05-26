% check_if_corrupt.m
% Sarah West
% 9/2/21
% Checks if a file/stack is corrupt WITHOUT HAVING TO LOAD IT :D
% Basis code is from https://stackoverflow.com/questions/38325121/check-if-mat-file-is-corrupt-without-load
% matfile doesn't need to load in the whole file, and it issues a warning
% if the file is corrupt. 
% Need to figure out the warning ID to put in for 'relevantWarningID'

matfile([filename]);
[~, warnId] = lastwarn;

if strcmp(warnId, 'relevantWarningId')
    % File is corrupt
end