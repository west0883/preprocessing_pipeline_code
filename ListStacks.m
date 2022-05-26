% ListStacks.m
% 9/8/21
% Sarah West

% Takes a vector of numbers and returns them as character strings in the
% format of the stack number name the user uses. 

function [stackList]=ListStacks(numberVector, digitNumber)

% Inputs:
% number_vector-- a vector of integers corrsponding to the stack numbers
% the user wants. OR it is the character string 'all'.
% digitnumber-- the number of digits in the stack number name the user
% wants.

% Outputs:
% stackList-- a character array of a list of stack numbers to use, with
% each entry a differnt stack number in characters with the number of
% digits given in digitnumber. Each stack number is a row. OR, if 
% number_vector is 'all', it is also a character string 'all'.
    
    % Convert the input digit number to a character for easier use with
    % sprintf. 
    digitChar=num2str(digitNumber);
    
    % Initiate holdList, an empty cell array.
    holdList=cell(length(digitNumber),1); 
    
    % Make a for loop for each stack entry, because sprintf doesn't have a
    % convenient way to separate outputs. 
    for numi=1:length(numberVector) 
        holdList{numi}=sprintf(['%0' digitChar 'd'], numberVector(numi)); 
    end
    
    % Concatenate holdList. 
    stackList=vertcat(holdList{:});
end