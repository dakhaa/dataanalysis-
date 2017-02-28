%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *CRADL Data Analysis Software* 
% The code analyses the CRADL EIT data stey by step and was developped by: 
% Andres Waldmann (awa@swisstom.com) 
% Louiza Sophocleous (louiza.sophocleous@gmail.com) 
% Tobias Becher (Tobias.Becher@uksh.de)
% Martijn Miedema (m.miedema@amc.uva.nl)
% Rebecca Yerworth (r.yerworth@ucl.ac.uk) 
% Inez Frerichs (Inez.Frerichs@uksh.de)

% initial version 9th February 2017
% current version 28.02.2017 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all 
clear 

% file path \ this is different for each User 
filePath = 'K:\2016\CRADL\testdata\FailingElectrodes'
doplotFilter = 1; % plot filtered data
imgSize = 32; % EIT image is 32x32 pixels 

%TODO add here ex Patient ID and save xls and pdf using the patient ID 

  for task =1:5   % just select what you need 
                     % task 1: convert *zri to *mat (time consuming)
                     % taks 2: filter EIT data 
                     % task 3: breath detection (need composit signal from
                     %         task 1) 
                     % task 4: calculate TI images using data from task 1
                     %          & 3
                     % task 5: calculate outcome parameters using data from
                     %         task 4 only
                     % task 6: failing electrodes 
                     % task 7 get all the events -> write to event log 
                     
       switch task 
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
           case 1 % convert to mat (very slow and you need disk space) run over night 
                  % TODO: 1) verify this 2) write "problematic files" into
                  % text file 3) see if folder exist 
               
               zriFiles =  dir([filePath,'\*.zri']); % get all zri File in path
               
               for iFiles = 1:length(zriFiles)  % loop all zri files   
                   try 
                       
                       data = bb2dataread([filePath,'\',zriFiles(iFiles).name]); % read zri files 
                       % all data but in math -> this file we can be open in ibeX                      
                       save([filePath,'\',zriFiles(iFiles).name(1:end-4),'.mat'],'data'); 

                       % save electrode state -> Outcome parameter!
                       
                       % TODO ask if folder is available and onyl creat it                      
                       % failing electrodes and compensation time 
                       ReconState = data.measurement.MeasurementState.ReconState; % when more then 6 are failing 
                       MeasState = data.measurement.MeasurementState.MeasState; % when device is compensationg 
                       ElectrodeQuality = data.measurement.ElectrodeQuality; 
                       save([filePath,'\ElectrodeQuality\ElectrodeQuality_',zriFiles(iFiles).name(1:end-4),'.mat'],'ElectrodeQuality','ReconState','MeasState'); 
                        
                       % TODO maybe write to text files 
                       display(['File: ',num2str(iFiles),'/',num2str(length(zriFiles))]); % just to see how long is still going
                       clear data; 
                       
                   catch 
                       % to do, write this in a file 
                       display(['Could not open: ',filePath,'\',zriFiles(iFiles).name]); 
                   end     
               end 
               
	       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
           case 2 % filter EIT data, bandpass filter 0.15 to 1.8Hz   (time consuming)
               
               % TODO: 
               % 1) remove calibration time before filtering-> verify this  
               % 2) verify filter
               
               imgFiles =  dir([filePath,'\*.mat']); % get all zri File in path
               fcut = [0.15 1.8]; % bandpass filter 
               for iFiles = 1:length(imgFiles)
                     load([filePath,'\',imgFiles(iFiles).name]);
                     
                     
                      % during the calibration time we simply continue the
                      % last good measured data -> later we will remove
                      % there sequence of the recording other ideas  
                    
                      % still it will influnce the filtering but less :) 
                      calibrating = (data.measurement.MeasurementState.ReconState+data.measurement.MeasurementState.MeasState>1); 
                      startCalibration = find(diff(calibrating) == 1); % start of calibration 
                      endCalibration = find(diff(calibrating) == -1);  % end of calibration 
                     % figure, plot(squeeze(sum(sum(data.measurement.ZeroRef )))), hold all;

                     % add "missing" data 
                      for iCal = 1:length(startCalibration)
                          gap = startCalibration(iCal):endCalibration(iCal); 
                          data.measurement.ZeroRef(:,:,gap(1)-1:gap(end)+1) = repmat(data.measurement.ZeroRef(:,:,startCalibration(iCal)-1),1,1,length(gap)+2); 
                     end 
                     % plot(squeeze(sum(sum(data.measurement.ZeroRef )))), hold all;
                     
                     
                     % TODO: verify this very carefully
                     Wc = [fcut/(data.imageRate/2)];  % fs/2                
                     [b,a]= butter(2, Wc,'bandpass'); 

                     % save global sum signal unfiltered -> for EELI trand 
                     if (isfield(data.measurement,'CompositValueUnfiltered'))
                            data.measurement.CompositValueUnfiltered = data.measurement.CompositValueUnfiltered; 
                     else
                            data.measurement.CompositValueUnfiltered = squeeze(sum(sum(data.measurement.ZeroRef ))); % we will need the unfiltered signal for the EELI trend
                     end 
                      % over write image data to avoid too much data                     
                     data.measurement.ZeroRef =  imgFiltFilt(b,a,data.measurement.ZeroRef); 
                     data.measurement.CompositValue = squeeze(sum(sum(data.measurement.ZeroRef )));

                     if doplotFilter == 1% for testing we could plot some figures 
                        plot(detrend(squeeze(sum(sum(data.measurement.CompositValue))),'r'));
                        title(['Filtered data / file name:', imgFiles(iFiles).name]), xlabel('samples (n)');
                     end 
                     
                     % save filtred data structure 
                     save([filePath,'\',imgFiles(iFiles).name(1:end-4),'.mat'],'data'); 
                        
                     % save the filtered composit seperately for breath detection 
                     mkdir([filePath,'\','Composit']); % creat sub-folder 
                     imageSumSignal = data.measurement.CompositValue; % use entire image not only lung region 
                     
                     fs = data.imageRate; 
                     save([filePath,'\Composit\Composit_',imgFiles(iFiles).name(1:end-4),'.mat'],'imageSumSignal','fs');
                     
                     display(['Filtering EIT data   File: ',num2str(iFiles),'/',num2str(length(imgFiles))]); % just to see how long is still going

                end 
               
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
           case 3  % breath detection 
               % -> TODO: 
               % 1) replace by Svens function
               % 2) save RR / I:E ratio 
               % 3) care about areas with failing electrodes 
               compositFiles =  dir([filePath,'\Composit\*.mat']); % get all zri File in path
               for iFiles = 1:length(compositFiles)  % loop all zri files 
                   load([filePath,'\Composit\',compositFiles(iFiles).name]); 
                   
%                    [breathInfoEIT, threshCrossings, breathPhase] = ...
%                       detectBreathPhase((imageSumSignal), fs/2, 1/60*[15 150], 0); 

                % TODO: 1) optimize this function
                %       2) add fs to the function 
                %       3) save RR and I:E Ratio for each breaths 
                [breathInfoEIT, threshCrossings, breathPhase, thresholdSig, Breath_rate_FFT] = ...
                    detectBreathPhase_LNU(imageSumSignal, fs/2, 1/60*[15 150], 0); 
                  
                  
                   figure, plot(imageSumSignal); hold on; 
                   plot(breathInfoEIT(1,:),imageSumSignal(breathInfoEIT(1,:)),'dr'); hold on; % not sure why we have to add +1 
		   plot(breathInfoEIT(2,:),imageSumSignal(breathInfoEIT(2,:)),'dg'); 
                   t = title(['Breath-detection: ',compositFiles(iFiles).name]);  set(t,'interprete','non'), grid on
                   axis tight; 
                            
                   % save breath detection                                
                   mkdir([filePath,'\','BreathDetection']); % creat sub-folder 
                   % take care that we do not overwiret the img file 
                   save([filePath,'\BreathDetection\',compositFiles(iFiles).name(end-17:end-4),'.mat'],'breathInfoEIT'); 
  
                   % TODO maybe save this as *fig or in a pdf for quality
                   % controll 
               end 
               
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
           case 4 % calculate tidal images (end of inspiration - start of inspiration   
               % TODO. remove TI with failing electrodes -> depent on
               % breath detection
               imgFiles =  dir([filePath,'\*.mat']); % get all zri File in path
               breathFiles = dir([filePath,'\BreathDetection','\*.mat']);
               for iFiles = 1:length(imgFiles)                   
                   fileSel = strcmp(imgFiles(iFiles).name,{breathFiles.name}); % find breath detection file for img file 
                   clear data; 
                   load([filePath,'\',imgFiles(iFiles).name]);
                   load([filePath,'\BreathDetection\',breathFiles(find(fileSel)).name]);
                   
                   TI.img = data.measurement.ZeroRef(:,:,breathInfoEIT(2,:))-data.measurement.ZeroRef(:,:,breathInfoEIT(1,:)); 
                   % we just take the patient position at end of
                   % inspriation 
                   TI.pos = data.measurement.Position.longitudinal(breathInfoEIT(2,:)); 
                   
                   % time stamp at end of inspiration 
                   temp = data.measurement.TimeStamp(breathInfoEIT(2,:)); 
                   % time stuff / conversion from c# timestamp to matlab
                   % timestamp 367 day different at the origin...
                   % http://stackoverflow.com/questions/5855208/convert-matlab-datenum-to-datetime
                   TI.timestamp = datestr((temp+367*24*60*60*1000)/(60*60*24)/1000, 'yyyy-mm-dd HH:MM:SS'); % date/time in units "days"
                    
                   clear temp; 
                  % patient info 
                   TI.patient = data.patient; % just save all the patient data also   
                   TI.imageRate = data.imageRate; % tech and SW numbers 
                   TI.TICVersion = data.TICVersion; 
                   TI.SBCVersion = data.SBCVersion; 
                   TI.SB = data.SensorBelt.SN; 
                   
                   % EELI (end expiratory lung impedance 
                   TI.EELI = data.measurement.CompositValueUnfiltered(breathInfoEIT(1,:)); % use unfiltered results for EEIL 
                   % EILI (ent inspiratory lung impedance 
                   TI.EILI = data.measurement.CompositValueUnfiltered(breathInfoEIT(2,:)); 
                   
                   
                   if (isfield(data,'eventTimestamp'))
                        TI.Events.timestamp = datestr((data.eventTimestamp+367*24*60*60*1000)/(60*60*24)/1000, 'yyyy-mm-dd HH:MM:SS');
                        TI.Events.typ = data.eventType; 
                        % get event position in global time stamp 
                        % TODO test this in detail 
                        TI.Events.pos = floor(interp1(data.measurement.TimeStamp(breathInfoEIT(2,:)), 1:length(data.measurement.TimeStamp(breathInfoEIT(2,:))), data.eventTimestamp));
                   end 
                   mkdir([filePath,'\','TI']); % create sub-folder 
                   save([filePath,'\TI\',imgFiles(iFiles).name],'TI'); 
                   clear TI; 
               end 
               
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % outcome parameter as defin in NCT02962505 
           case 5 %    % TODO we need to sort the eit files before doing the calculations! 
       
               TIfiles =  dir([filePath,'\TI','\*.mat']); % get all zri File in path  
               
               % define ROI
               ROI_Anterior = zeros(imgSize,imgSize); ROI_Anterior(1:imgSize/2,:)=1;%figure,imagesc(ROI_Anterior)
               ROI_Posterior = ~ROI_Anterior;%figure,imagesc(ROI_Posterior)
               ROI_Right = zeros(imgSize,imgSize); ROI_Right(:,1:imgSize/2)=1;%figure,imagesc(ROI_Right)
               ROI_Left = ~ROI_Right; 
               
               breathPos = 1;  
               for iFiles = 1:length(TIfiles) 
                  clear TI; 
                 
                   load([filePath,'\TI\',TIfiles(iFiles).name]); 
                   
                
                   %% 1. Change in aggregate measure of ventilation homogeneity (coefficient of variation and global inhomogeneity index of regional tidal volume) by > 10% compared with baseline [ Time Frame: 72 hours ]
                   % i guess resape is much faster then for-loops  
                   
                   % we have TI with a size to 32x32 pixel maps, we are
                   % selecting only the lung pixels and creating a vector
                   % out of it. STD, Mean, Median can den easily be
                   % calculated using this vector. Pleas verify. 
                   lungElements = reshape(TI.patient.ROI.Inside,32*32,1); % lung contour 
                   TIreshaped = reshape(TI.img,32*32,size(TI.img,3)); % creat vector with 1024 values (32*32)
                   lungPixels =  TIreshaped(find(lungElements~=0),:);  % get only the values of the lung pixels                  
                   
                   % coefficiant of variation CV = STD/Mean. 
                   CV(breathPos:breathPos+size(TI.img,3)-1)= std(lungPixels)./mean(lungPixels); 
                   
                   % GI, see instructions 
                   temp = lungPixels-repmat(median(lungPixels),size(lungPixels,1),1); % substract median 
                   GI(breathPos:breathPos+size(TI.img,3)-1) = sum(abs(temp))./sum(lungPixels);
                   
                   % ventilated area (0.25*max(TI) define  in % of thorax pixels)
                   maxTI = squeeze(max(max(TI.img)));  % max values of each TI 
                   maxTIcutoff = 0.25*maxTI;  % as define in the data analyis protocol 
                   
                   % TODO try to aviod this FOR-loop some one has an idea?
                   % or init ventilatedArea to make things faster 
                   for iTI = 1:size(TI.img,3)
                        VentilatedArea(breathPos-1+iTI) = length(find(lungPixels(:,iTI)>maxTIcutoff(iTI)))./length(lungPixels(:,iTI))*100; 
                   end
                   
                   % Patient position at end of inspiration 
                   patientPos(breathPos:breathPos+size(TI.pos,2)-1) = TI.pos; 
                   
                    % EELI
                   EELI(breathPos:breathPos+size(TI.EELI,1)-1) = TI.EELI; 
                   % EILI 
                   EILI(breathPos:breathPos+size(TI.EILI,1)-1) = TI.EILI; 

                   % time of tidal image (time stamp at end of inspiration)  
                   timeStamp(breathPos:breathPos+size(TI.timestamp,1)-1,:)= TI.timestamp;    
                   
                   % events  
                   if (isfield(TI,'Events'))
                       eventMat(breathPos+TI.Events.pos,:) = cellstr(TI.Events.typ)'; 
                       eventTime(breathPos+TI.Events.pos,:) = cellstr(TI.Events.timestamp); 
                   end 

              
                   
                   %%  2. Change in right-to-left and/or anteroposterior ventilation distribution by >10% compared with baseline [ Time Frame: 72 hours ]
                   TI.img(find(TI.img<0)) = 0; % set negative values to zero as discribed in the data analysis protocol
                   Lung = squeeze(sum(sum(TI.img)));  % 100% 
                                     
                   % anterior 
                   LungVent(breathPos:breathPos+length(Lung)-1,1) = squeeze(sum(sum( TI.img.*repmat(ROI_Anterior,1,1,size(TI.img,3)))));              % anterior in AU
                   LungVent(breathPos:breathPos+length(Lung)-1,2) = squeeze(sum(sum( TI.img.*repmat(ROI_Anterior,1,1,size(TI.img,3)))))./Lung*100;    % anterior in (%)                               
                   % posterior 
                   LungVent(breathPos:breathPos+length(Lung)-1,3) = squeeze(sum(sum( TI.img.*repmat(ROI_Posterior,1,1,size(TI.img,3)))));              % anterior in AU                              
                   LungVent(breathPos:breathPos+length(Lung)-1,4) = squeeze(sum(sum( TI.img.*repmat(ROI_Posterior,1,1,size(TI.img,3)))))./Lung*100;   % posterior in (%)                   
                   % right 
                   LungVent(breathPos:breathPos+length(Lung)-1,5) = squeeze(sum(sum( TI.img.*repmat(ROI_Right,1,1,size(TI.img,3)))));                 % right in AU
                   LungVent(breathPos:breathPos+length(Lung)-1,6) = squeeze(sum(sum( TI.img.*repmat(ROI_Right,1,1,size(TI.img,3)))))./Lung*100;       % right in (%)
                   % left 
                   LungVent(breathPos:breathPos+length(Lung)-1,7) = squeeze(sum(sum( TI.img.*repmat(ROI_Left,1,1,size(TI.img,3)))));            % left in AU
                   LungVent(breathPos:breathPos+length(Lung)-1,8) = squeeze(sum(sum( TI.img.*repmat(ROI_Left,1,1,size(TI.img,3)))))./Lung*100;  % left in (%)
   
                   
                   % CoV (not outcome but nice) define as anterior (0%) /  posterior(100%) and right(0%) to left(100%) percentage value 
                   [CoVrl_tmp, CoVvd_temp] = covCalculator(TI.img); % call subfaunction 
                   
                   CoVrl(breathPos:breathPos+length(CoVrl_tmp)-1) = CoVrl_tmp; 
                   CoVvd(breathPos:breathPos+length(CoVvd_temp)-1) = CoVvd_temp;       
                   
                   % maybe we could to a video of all TI imagesc
                   fNames(breathPos) = {TIfiles(iFiles).name}; % stor the file name 

                 
                   % counter for breath 
                   breathPos = breathPos+length(Lung);
               end 
                                 
                   % now put all in a xls sheet this is queite slow maybe
                   % its worth doing this differently 
                   
                   % TODO: replace name by patinent ID 
                   xlsTitel = {'File-Name','TI numer','Date (DDMMYYYY)','Time (hh:mm:ss)',...
                       'GI Index','Coefficient of Variation','Center of Ventilation ventral to dorsal (%)'...
                       'Center of Ventilatin right to left (%)','Anterior (AU)','Anterior (%)',...
                       'Posterios (AU)','Posterios (%)','Right (AU)','Right (%)','Left (AU)','Left (%)',...
                       'Ventilated area (%)','R:L (outcome 3)','EELI','EILI','Event time','Event typ','Patinet position(°)'};
                   sheetName = 'unfiltered TestVersion Feb2017'; 
                   xlswrite([filePath,'\Results.xlsx'],xlsTitel,sheetName,'A1'); % title 
                   xlswrite([filePath,'\Results.xlsx'],fNames',sheetName,'A2'); % file names
                   xlswrite([filePath,'\Results.xlsx'],(1:length(GI))',sheetName,'B2'); % breath count 
                   
                   % this may fail in other xls version!! 
                   xlswrite([filePath,'\Results.xlsx'],(cellstr(timeStamp(:,1:10))),sheetName,'C2'); % breath count 
                   xlswrite([filePath,'\Results.xlsx'],(cellstr(timeStamp(:,11:end))),sheetName,'D2'); % breath count 
                    % maybe faster when copy everything in one matrix
                    % before writing it to xls 
                   xlswrite([filePath,'\Results.xlsx'],GI',sheetName,'E2'); % GI
                   xlswrite([filePath,'\Results.xlsx'],CV',sheetName,'F2'); % CV
                   xlswrite([filePath,'\Results.xlsx'],CoVvd',sheetName,'G2'); % COV ventral to dorsal
                   xlswrite([filePath,'\Results.xlsx'],CoVrl',sheetName,'H2'); % COV right to left   
                   xlswrite([filePath,'\Results.xlsx'],(LungVent),sheetName,'I2'); % vent verteilung 
                   xlswrite([filePath,'\Results.xlsx'],VentilatedArea',sheetName,'Q2'); % vent verteilung
                   xlswrite([filePath,'\Results.xlsx'],LungVent(:,5)./LungVent(:,7),sheetName,'R2'); % Right to L 
                   
                   xlswrite([filePath,'\Results.xlsx'],EELI',sheetName,'S2'); % patint position at end of inspiration
                   xlswrite([filePath,'\Results.xlsx'],EILI',sheetName,'T2'); % patint position at end of inspiration

                   
                   xlswrite([filePath,'\Results.xlsx'],eventTime,sheetName,'U2'); % patint position at end of inspiration
                   xlswrite([filePath,'\Results.xlsx'],eventMat,sheetName,'V2'); % patint position at end of inspiration
                   xlswrite([filePath,'\Results.xlsx'],patientPos',sheetName,'W2'); % patint position at end of inspiration
                   % maybe we could add the respiratory rate 
                   
                   
                   %TODO: 1) see what happens if we have no events in the
                   %entire recordings 
                   % 2)  add patient gender to the overview sheet 
                   % 3) replace "results.xlsx" by "patient ID" 
                   % 4) see how many entries we can save in xlsx -> depends
                   % on version 
                   sheetName = 'PatinetData'; 
                   xlsTitel = {'Patient Overview';'';'Patient';'Weight (g)';'PMA (weeks)';'Chest circumference (mm)';'Used belt size (mm)';'Number of analysed files';...
                       '';'Tech data';'Image rate (Hz)';'TIC SW';'SBC SW';'Neo Converter';...
                       '';'Events:';'Time'}; 
                   xlswrite([filePath,'\Results.xlsx'],xlsTitel,sheetName,'A1'); % title 
                   xlswrite([filePath,'\Results.xlsx'],mean(TI.patient.weightNeo),sheetName,'B4'); % not sure but sometimes we have severl weigths in all the files  
                   xlswrite([filePath,'\Results.xlsx'],mean(TI.patient.PatientPma),sheetName,'B5'); % not sure but sometimes we have severl weigths in all the files  
                   xlswrite([filePath,'\Results.xlsx'],2*TI.patient.halfChest,sheetName,'B6'); 
                   xlswrite([filePath,'\Results.xlsx'],TI.patient.PatientIntendedBeltSize,sheetName,'B7');  
                   xlswrite([filePath,'\Results.xlsx'],length(TIfiles),sheetName,'B8');   
                   
                   xlswrite([filePath,'\Results.xlsx'],TI.imageRate,sheetName,'B11'); % not sure but sometimes we have severl weigths in all the files  
                   xlswrite([filePath,'\Results.xlsx'],{TI.TICVersion},sheetName,'B12'); % not sure but sometimes we have severl weigths in all the files  
                   xlswrite([filePath,'\Results.xlsx'],{TI.SBCVersion},sheetName,'B13'); % not sure but sometimes we have severl weigths in all the files  
                   xlswrite([filePath,'\Results.xlsx'],{TI.SB},sheetName,'B14'); % not sure but sometimes we have severl weigths in all the files  
                   xlswrite([filePath,'\Results.xlsx'],{'Event type'},sheetName,'B17'); % not sure but sometimes we have severl weigths in all the files  
                  
                   try % TODO this we need to add each time we are writing events to the file  
                   pos = find(~cellfun(@isempty,eventMat)); % get non empty entries 
                   xlswrite([filePath,'\Results.xlsx'],eventMat(pos),sheetName,'B18'); % not sure but sometimes we have severl weigths in all the files  
                   xlswrite([filePath,'\Results.xlsx'],eventTime(pos),sheetName,'A18'); % not sure but sometimes we have severl weigths in all the files  
                   catch 
                       display('No Event found in this recording! Please verify with CRF')
                   end
                   
                   
                   % TODO: 1) add patient postion 
                   %       2) overview page with patient data  
                   parameter = {GI;CV;EELI;CoVvd;CoVrl;VentilatedArea;LungVent(:,5)./LungVent(:,7);LungVent(:,2);LungVent(:,4);LungVent(:,6);LungVent(:,8);patientPos};
                   figTitel = {'Global Inhomogenity index','Coefficient of Variation (CV)','End expiratory lung impednace (EELI)'...
                       'Center of Ventilatin right to left (%)','Center of Ventilatin ventral to dorsal (%)','Ventilated area (%)','R-L-Ratio','Ventilation Anterior(%)','Ventilation Posterior(%)','Ventilation Right (%)','Ventilation Left (%)','Patient Position'}
                   % do pdf report with some data 
                   for iparameter = 1:length(parameter)
                     saveName{iparameter}=   createPDF(parameter{iparameter},timeStamp,eventMat,eventTime,figTitel{iparameter})
                   end 
                   append_pdfs([filePath,'\_Report_V0.pdf'],saveName{:}); % put all pdfs together 
                   delete(saveName{:}); 
                   
       end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
      %% case 6 % failing electrodes 
           
      %% 4. Percentage of EIT examination time with at least 26 out of 32 sensors exhibiting skin contact impedance of < 700 Ohm [ Time Frame: 72 hours ]
                   %  failing = 2 / partially failing = % 1 / good = 0
                   % we should do this in an different task because we are
                   % not only looking at breath by breath data but at each
                   % measures frame. 
                   % -> save failings 
                   % -> save compensation time of the device 
                   % -> all this data are stored in step one :) 
                   
       %% case 7 % moving mean filter with size 30 
       % load xls data and save it as a new xls sheet with filtered data 
       
       %% case 8 save ther events 
       % Rebecca we have already all the events and time stamps in the TI
       % data, therefore we do not need to scann all the files again. i
       % guess is very easy todo :) 
       %
       end 
       
   
