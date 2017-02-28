function y = imgFiltFilt(b,a,x)
%% applies an IIR filter to a 2D image (sequence) in the form of filfilt implementation (without any delay)
% 
% 	if you have the filtering tool box you can replace awa_filtfilt by filtfilt 	
	y = reshape(awa_filtfilt(b,a,reshape(x, size(x,1)*size(x,2), [])')', size(x,1), size(x,2), []);
	
end