function [ CoVrl, CoVvd ] = covCalculator( TI )
% Center of Ventilation calculation
% the CoV is similar as Center of Mass calculation
% https://en.wikipedia.org/wiki/Center-of-momentum_frame) 

% 1) creat a matrix with the distance from origin 
% 2) repmat and multiply each TI 
% 3) devide by sum 


MatrixSize = size(TI,1); % usually 32 pixels 
Matrixlength = size(TI,3); % number of frames

Sx = repmat(repmat([1:MatrixSize],MatrixSize,1),1,1,Matrixlength); % matricis with the same length as the TIs   
Sy = repmat(repmat([1:MatrixSize]',1,MatrixSize),1,1,Matrixlength);  

% rigth to left
CoVrl = squeeze(sum(sum(Sy.*TI))./sum(sum(TI))); % TODO test this carefully 
CoVrl = CoVrl./MatrixSize*100; % in % (0% right 100% left)
% ventral dorsal 
CoVvd = squeeze(sum(sum(Sx.*TI))./sum(sum(TI))); 
CoVvd = CoVvd./MatrixSize*100; % in % (0% ventral 100% dorsal) 


end

