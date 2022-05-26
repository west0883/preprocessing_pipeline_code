% HemoRegression.m
% Sarah West
% 9/12/21

% Runs hemodynamic correction on a 2-channel stack by regressing each blue
% pixel against the corresponding violet pixel and keeping only the
% residuals.

function [residual_data]=HemoRegression(bData, vData)
   % Inputs--> pixels x frames ; inputted into regress as frames x pixels 
   bData=bData'; 
   vData=vData'; 
   
   residual_data=NaN(size(bData)); 
   frames=size(vData,1); 
   parfor i=1:size(bData,2)

         [~,~,r] = regress(bData(:,i), [vData(:,i) ones(frames,1)]);

         residual_data(:, i)=r;
   end
   residual_data=residual_data'; 
end 
