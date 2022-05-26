% CreateFileStrings.m
% Sarah West
% 9/1/21

% Takes an input cell array of character strings and outputs the file
% string with the correct mouse and day in them. 

% Input: 
% file_format_cell--cell array. Establish the format of the file names of compressed data. Each piece
% needs to be a separate entry in a cell array. Put the string 'mouse', 'day',
% or 'stack number' where the mouse, day, or stack number will be. If you 
% concatenated this as a sigle string, it should create a file name, with the 
% correct mouse/day/stack name inserted accordingly. 


function [file_string]=CreateFileStrings(file_format_cell, mouse, day, stack_number)
    
    % Make a new cell array to manipulate. 
    file_format_output_cell=file_format_cell;
    
    % See if there is an entry for mouse number
     if any(contains(file_format_cell,'mouse number'))==1
         mouse_index=find(contains(file_format_cell,'mouse number'));
         
         % If there is, make sure the mouse entry isn't empty 
         if isempty(mouse)==0
             
             % Put the mouse number in place of the mouse number tag
             file_format_output_cell{mouse_index}=mouse; 
         
         % If the mouse input is empty, throw an error
         else 
             error('no mouse number was given'); 
         end 
     end 
    
     
    % See if there is an entry for day
     if any(contains(file_format_cell,'day'))==1
         day_index=find(contains(file_format_cell,'day'));
         
         % If there is, make sure the mouse entry isn't empty 
         if isempty(day)==0
             
             % Put the mouse number in place of the mouse number tag
             file_format_output_cell{day_index}=day; 
         
         % If the mouse input is empty, throw an error
         else 
             error('no day was given'); 
         end 
     end 
     
     % See if there is an entry for stack number
     if any(contains(file_format_cell,'stack number'))==1
         stack_index=find(contains(file_format_cell,'stack number'));
         
         % If there is, make sure the stack number entry isn't empty 
         if isempty(stack)==0
             
             % Put the mouse number in place of the mouse number tag
             file_format_output_cell{stack_index}=stack_number; 
         
         % If the stack input is empty, throw an error
         else 
             error('no stack number was given'); 
         end 
     end 
    
    % Now concatenate everything into a single string.
    file_string=horzcat(file_format_output_cell{:}); 
end 