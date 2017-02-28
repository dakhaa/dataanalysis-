% awa 27.02.2017
% DDS P01_0050T und DDS P03_0004/1.0
% load BB2 data
% all exported values are impedance values (inspiration increases the
% impedance and expiration decreases the impedance)
% added neo values Feb. 2017
% event types erweiterung 

function [bb2data] = bb2dataread(filename)
lastDomainID = [];
lastDataID = []; 

fid = fopen(filename);

% read version number
% set indicator to end of file
fseek(fid,0,1);
% find length of file
Filelength = ftell(fid) ;
fseek(fid,0,-1);
ftell(fid);
bb2data.ver = fread(fid, 1, 'int8', 0, 'ieee-le');

k = 1;
ii = 0;
iPatient = 1; 
while ftell(fid) < Filelength 
    %
    timestamp = (fread(fid, 1, 'uint64',0, 'ieee-le')); % read time stamp
   
    domainID = (fread(fid, 1, 'uint8',0, 'ieee-le'));
    
    numberOfDataFiels = (fread(fid, 1, 'uint8', 0, 'ieee-le'));
    
    for i = 1:numberOfDataFiels
        dataID = (fread(fid, 1, 'uint8', 0, 'ieee-le'));
        payloadSize = fread(fid, 1,'ushort', 0, 'ieee-le');
        % startpos = ftell(fid);
        % (domainID)
        switch (domainID)
            case 0  % Protocol Version
                ftell(fid); 
                switch (dataID) 
                    case 0,  bb2data.ProtocollVerision.Major = fread(fid, payloadSize,'uchar', 0, 'ieee-le');
                    case 1,  bb2data.ProtocollVerision.Minor = fread(fid, payloadSize,'uchar', 0, 'ieee-le');
                    otherwise, 
                             display('unknown ID when reading BB2 file');
                             fread(fid, payloadSize);
                end 
     
                
            case 2        % Patient
                switch(dataID)
                    case 0, bb2data.patient.height =  fread(fid, 1,'ushort', 0, 'ieee-le');
                        startfail = ftell(fid);
                    case 1, bb2data.patient.weight =   0.1*fread(fid, 1,'ushort', 0, 'ieee-le');    % Change to kg according to DDS P01_0050T
                    case 2, bb2data.patient.gender =  fread(fid, 1,'uchar', 0, 'ieee-le');
                    case 4, species =  dec2hex(fread(fid, 1,'ushort', 0, 'ieee-le'));   % bb-Vet extention (DataiD-PatientSpecies 
                            switch(species)
                                case '00'; bb2data.patient.species ='Human adult';
                                case '01'; bb2data.patient.species ='Human child';
                                case '02'; bb2data.patient.species ='Human neonate';
                                case '10'; bb2data.patient.species ='Horse';
                                case '11'; bb2data.patient.species ='Foal';
                                case '30'; bb2data.patient.species ='Dog Beagle';
                                case '50'; bb2data.patient.species ='Pig';
                                case '90'; bb2data.patient.species ='Donkey';
                                case 'A0'; bb2data.patient.species ='Sheep';
                                case 'A1'; bb2data.patient.species ='Lamb';
                                case 'C0'; bb2data.patient.species ='Cattle';
                                case 'C1'; bb2data.patient.species ='Calf';
                                   
                                otherwise
                                bb2data.patient.species ='No animal ID was found'; 
                            end
  
                    case 6, temp = fread(fid, 1,'ushort', 0, 'ieee-le');
                        if temp >=16385
                           bb2data.patient.halfChest = temp -16384; % value in mm 
                        else 
                           bb2data.patient.halfChest = temp*10; % value in cm 
                        end
                    case 7, 
                        bb2data.patient.manualPositionCorrection =  fread(fid, payloadSize,'uint8', 0, 'ieee-le'); % bb-neo  
                    case 16 %hex2dec('10'), 
                        bb2data.patient.SVG = fscanf(fid,'%c', payloadSize);
                    case 17 %hex2dec('11'),  
                            %CM = fread(fid, payloadSize,'uchar', 0, 'ieee-le');
                            bb2data.patient.CM.Imagewidth = fread(fid, 1,'ushort', 0, 'ieee-le');
                            bb2data.patient.CM.Imageheight = fread(fid, 1,'ushort', 0, 'ieee-le');
                            bb2data.patient.CM.NumberOfMaps = fread(fid, 1,'ushort', 0, 'ieee-le');
                            % Defined Region of interest DDS
                            % Data:Chest Contour Map
                            kindOfTissue = {'Inside','RightLung','LeftLung','Heart'};
                            for kk = 1:bb2data.patient.CM.NumberOfMaps(1)
                                kindofTissue = fread(fid, 1,'uchar', 0, 'ieee-le');
                                temp  = reshape(fread(fid, bb2data.patient.CM.Imagewidth(1)*bb2data.patient.CM.Imageheight(1),'uchar', 0, 'ieee-le'),bb2data.patient.CM.Imagewidth(1),bb2data.patient.CM.Imageheight(1));
                                tempS = kindOfTissue{kk};
                                bb2data.patient.ROI.(tempS)=temp';
                            end     
                    case 18 %hex2dec('12'), % weight in gram 
                         bb2data.patient.weightNeo(iPatient) =   fread(fid, 1,'ushort', 0, 'ieee-le'); 
                         iPatient = iPatient+1; 
                         
                     case 20 %hex2dec('14'), %PatientIntendedBeltSize
                        bb2data.patient.PatientPma = fread(fid, 1,'uchar', 0, 'ieee-le'); 
                        
                    case 21 %hex2dec('15'), %PatientIntendedBeltSize
                        bb2data.patient.PatientIntendedBeltSize = fread(fid, 1,'ushort', 0, 'ieee-le'); 
                        
%                          PatientBirthDay = 0x13
%                          PatientPma = 0x14,


                    otherwise % if unknown ID
                       display('unknown ID when reading BB2 file')
                      fread(fid, payloadSize);
                end
                
                
            case  3       % Sensorbelt
                switch(dataID)
                    case 0, bb2data.SensorBelt.RefNum = fscanf(fid,'%c', payloadSize);
                    case 1, bb2data.SensorBelt.SN = fscanf(fid,'%c', payloadSize);
                    case 2, bb2data.SensorBelt.Size = fscanf(fid,'%c', payloadSize);
                    case 3, bb2data.SensorBelt.NumEl = fread(fid, payloadSize,'uchar', 0, 'ieee-le');
                    case 4, bb2data.SensorBelt.TimeInUse = fread(fid, 1,'ulong', 0, 'ieee-le');
                    case 5, bb2data.SensorBelt.VendorID = fscanf(fid,'%c', payloadSize);
                                   
                    otherwise % if unknown ID
                      display('unknown ID when reading BB2 file')
                      fread(fid, payloadSize); 
                end
                
                
            case 16 % hex2dec('10')       % Meassurement
                switch(dataID)
                    case 0, 
                        ii = ii+1; 
                        if (ii > 1) && (ii >= length(bb2data.measurement.ElectrodeQuality))
                            % do some extra space allocation to avoid
                            % frame-by-frame allocation which is terribly slow
                            ExtraRange = ii : ii+1000;
                            bb2data.measurement.ElectrodeQuality(ExtraRange,:) = nan(length(ExtraRange),32);
                            bb2data.measurement.ZeroRef(:,:,ExtraRange) = nan(size(bb2data.measurement.ZeroRef, 1), ...
                                                                              size(bb2data.measurement.ZeroRef, 2), ...
                                                                              length(ExtraRange)); 
                        end
                        bb2data.measurement.TimeOfCaption(ii,:) = fread(fid, payloadSize/4, 'uint32', 0, 'ieee-le');
                        bb2data.measurement.TimeStamp(ii) = timestamp; % test this 
                    case 1, 
                        bb2data.measurement.ElectrodeQuality(ii,:) = fread(fid, payloadSize,'uchar', 0, 'ieee-le');
                    case 2, bb2data.measurement.ImageQuality(ii) = fread(fid, payloadSize,'uchar', 0, 'ieee-le');
                    case 3, bb2data.measurement.CompositValue(ii,:) = -fread(fid, payloadSize/4, 'float32', 0, 'ieee-le'); % bb2 compositi is in conductivity
                    case 5, bb2data.measurement.SizeWidth(ii) = fread(fid, 1, 'uchar', 0, 'ieee-le');
                        bb2data.measurement.SizeHeight(ii) = fread(fid, 1, 'uchar', 0, 'ieee-le');
                        ZeroRef = fread(fid, (payloadSize-2)/4, 'float32', 0, 'ieee-le'); % todo test this
                        bb2data.measurement.ZeroRef(:,:,ii) = -reshape(ZeroRef,bb2data.measurement.SizeWidth(ii),bb2data.measurement.SizeHeight(ii))'; % bb2 export is in conductivity
                    case 7, bb2data.measurement.Position.valid(ii) = fread(fid, 1, 'uchar', 0, 'ieee-le');
                        bb2data.measurement.Position.longitudinal(ii) = fread(fid, 1, 'ushort', 0, 'ieee-le');
                        bb2data.measurement.Position.transversal(ii) = fread(fid, 1, 'ushort', 0, 'ieee-le');
                    case 8, bb2data.measurement.BreathPhase.inspirationStart(ii) = fread(fid, 1, 'uint32', 0, 'ieee-le');
                        bb2data.measurement.BreathPhase.expirationStart(ii) = fread(fid, 1, 'uint32', 0, 'ieee-le');
                        bb2data.measurement.BreathPhase.expirationEnd(ii) = fread(fid, 1, 'uint32', 0, 'ieee-le');
                    case 10,bb2data.measurement.MeasurementState.ReconState(ii,:) = fread(fid, 1, 'uchar', 0, 'ieee-le');
                        bb2data.measurement.MeasurementState.MeasState(ii,:) = fread(fid, 1, 'uchar', 0, 'ieee-le');  
                    case 11, widthTI = fread(fid, 1, 'uchar', 0, 'ieee-le'); % added 16112016 ask beat what is inside 
                         heightTI = fread(fid, 1, 'uchar', 0, 'ieee-le');
                         TI = fread(fid, (payloadSize-2), 'uchar', 0, 'ieee-le'); 
                         % bb2data.measurement.MeasurementState.NormalizedDifferentialImage(:,:,iBreath) = reshape(widthTI,heightTI,TI);
                    case 12,IQsatturation= fread(fid,payloadSize/4, 'float32', 0, 'ieee-le'); % added 16112016 ask beat what is inside    
                    otherwise % if unknown ID
                       display('unknown ID when reading BB2 file')
                       fread(fid, payloadSize');
                end
                
                
            case 18 %hex2dec('12')       % Interpretation added 16112016 data from TIC module
                switch (dataID) 
                        
                    case 0,     widthTI = fread(fid, 1, 'uchar', 0, 'ieee-le'); % TI image from TIC
                                heightTI = fread(fid, 1, 'uchar', 0, 'ieee-le');
                                TI = fread(fid, (payloadSize-2)/4, 'float32', 0, 'ieee-le'); 
                                bb2data.interpretation.TI(:,:,iBreath) = reshape(widthTI,heightTI,TI);
                                                        
                    case 1,     widthTI = fread(fid, 1, 'uchar', 0, 'ieee-le'); % stretch image from TIC
                                heightTI = fread(fid, 1, 'uchar', 0, 'ieee-le');
                                cat = fread(fid, 1, 'uchar', 0, 'ieee-le');
                                TI = fread(fid, (payloadSize-3), 'uchar', 0, 'ieee-le'); 
                                bb2data.interpretation.Stretch(:,:,iBreath) = reshape(widthTI,heightTI,TI); 
                                                   
                    case 2,     bb2data.interpretation.Stretch.nCategory = fread(fid, 1, 'uchar', 0, 'ieee-le'); % stretch histogram
                                bb2data.interpretation.StretchHisto(:,iBreath) = fread(fid, bb2data.interpretation.Stretch.nCategory,'uchar',0,'ieee-le'); 
                                bb2data.interpretation.StretchQuartil(:,iBreath)=fread(fid,3,'uchar',0,'ieee-le'); 
                    
                    case 3,     widthTI = fread(fid, 1, 'uchar', 0, 'ieee-le'); % Silent spaces 
                                heightTI = fread(fid, 1, 'uchar', 0, 'ieee-le');
                                SS = fread(fid, (payloadSize-2), 'uchar', 0, 'ieee-le'); 
                                bb2data.interpretation.SilentSpaces(:,:,iBreath) = reshape(widthTI,heightTI,SS);  
                                
                    case 4,     bb2data.interpretation.SilentSpaces.CoV(:,iBreath) = fread(fid, 2, 'uchar', 0, 'ieee-le'); % COVa
                                bb2data.interpretation.SilentSpaces.CoVrelativ(:,iBreath) = fread(fid, 2, 'uchar', 0, 'ieee-le'); % COVa  relativ ??                               
                                bb2data.interpretation.SilentSpaces.CoVref(:,iBreath) = fread(fid, 2, 'uchar', 0, 'ieee-le'); % COVa  relativ ??                               
                                bb2data.interpretation.SilentSpaces.CoVref_relativ(:,iBreath) = fread(fid, 2, 'uchar', 0, 'ieee-le'); % COVa  relativ ??                               
                                bb2data.interpretation.SilentSpaces.NSS(:,iBreath) = fread(fid, 1, 'uchar', 0, 'ieee-le'); % non-dependent Silent spaces                                
                                bb2data.interpretation.SilentSpaces.FSS(:,iBreath) = fread(fid, 1, 'uchar', 0, 'ieee-le'); % dependent Silent spaces                                
                                bb2data.interpretation.SilentSpaces.FLS(:,iBreath) = fread(fid, 1, 'uchar', 0, 'ieee-le'); % Funcional lung size  (FLS)                                
                                
                                iBreath = iBreath+1;
                                                    
                    otherwise % if unknown ID
                    display('unknown ID when reading BB2 file')
                    fread(fid, payloadSize);
                        
                end   
                
                
            case 33 %hex2dec('21')       % Error state
                 bb2data.ErrorState = fread(fid, payloadSize, 'uchar', 0, 'ieee-le');
                
            case 128 %hex2dec('80')       % Maintenance
                switch (dataID) 
                    case 0, bb2data.TICVersion = fscanf(fid,'%c', payloadSize);
                    case 1, bb2data.SBCVersion = fscanf(fid,'%c', payloadSize);
                    otherwise,
                            display('unknown ID when reading BB2 file')
                            fread(fid, payloadSize');
                end
                        
               
            case 64 %hex2dec('40') %convert to bin,
                switch (dataID), 
                    case 0,  bb2data.injctionPattern = fread(fid, payloadSize, 'uchar', 0, 'ieee-le');
                    case 1,  bb2data.imageRate = fread(fid, payloadSize/4, 'float32', 0, 'ieee-le');
                    case 5,  bb2data.injctionPattern = fread(fid, payloadSize, 'uchar', 0, 'ieee-le');
                     otherwise,
                            display('unknown ID when reading BB2 file')
                            fread(fid, payloadSize');
                end 
                
                
            case 255 %hex2dec('FF')% Event 
                switch( dataID ) 
                    case 0, 
                        bb2data.events(k) = ii-1;       % this is not good yet 
                         bb2data.eventTimestamp(k) = timestamp; 

                        if  payloadSize == 0 
                            bb2data.eventType{k} = 'unspecified ';
                            
                        elseif payloadSize == 4
                            % read event typ 

                            eventTyp = fread(fid, 1, 'uint32', 0, 'ieee-le');
                            bb2data.eventType{k} =  neoEvents(eventTyp); % call function for event identification
                        else 
                           display('unknown ID when reading BB2 file -> undifined event type')   
                        end 
                        k=k+1;
                                
                    case 1  % LuFu Parameter 
                      %   fread(fid, payloadSize);
                    
                        ii=ii+1;
                        
                        bb2data.LuFuParam.breathInfo(1,ii) = fread(fid, 1, 'uint64',0, 'ieee-le');
                        bb2data.LuFuParam.breathInfo(2,ii) = fread(fid, 1, 'uint64',0, 'ieee-le');
                        bb2data.LuFuParam.breathInfo(3,ii) = fread(fid, 1, 'uint64',0, 'ieee-le');
                        bb2data.LuFuParam.compVal(1,ii) = -fread(fid, 1, 'float',0, 'ieee-le');
                        bb2data.LuFuParam.compVal(2,ii) = -fread(fid, 1, 'float',0, 'ieee-le');
                        bb2data.LuFuParam.compVal(3,ii) = -fread(fid, 1, 'float',0, 'ieee-le');
                        bb2data.LuFuParam.imageWidth(ii) = fread(fid, 1, 'uint8',0, 'ieee-le');
                        bb2data.LuFuParam.imageHeight(ii) = fread(fid, 1, 'uint8',0, 'ieee-le');
                        bb2data.LuFuParam.LuFuParamsNum(ii) = fread(fid, 1, 'uint8',0, 'ieee-le');
                    
                        LufuType = fread(fid, 1, 'uint8',0, 'ieee-le');
                        stretch = fread(fid, bb2data.LuFuParam.imageWidth(ii)*bb2data.LuFuParam.imageHeight(ii), 'float', 0, 'ieee-le'); % todo prove this
                        bb2data.LuFuParam.stretch(:,:,ii) = reshape(stretch,bb2data.LuFuParam.imageWidth(ii),bb2data.LuFuParam.imageHeight(ii))';
                    
                        LufuType = fread(fid, 1, 'uint8',0, 'ieee-le');
                        COV = fread(fid, bb2data.LuFuParam.imageWidth(ii)*bb2data.LuFuParam.imageHeight(ii), 'float', 0, 'ieee-le'); % todo prove this
                        bb2data.LuFuParam.COV(:,:,ii) = reshape(COV,bb2data.LuFuParam.imageWidth(ii),bb2data.LuFuParam.imageHeight(ii))';
                    
                        LufuType = fread(fid, 1, 'uint8',0, 'ieee-le');
                        RTD = fread(fid, bb2data.LuFuParam.imageWidth(ii)*bb2data.LuFuParam.imageHeight(ii), 'float', 0, 'ieee-le'); % todo prove this
                        bb2data.LuFuParam.RTD(:,:,ii) = reshape(RTD,bb2data.LuFuParam.imageWidth(ii),bb2data.LuFuParam.imageHeight(ii))';
                    
                        LufuType = fread(fid, 1, 'uint8',0, 'ieee-le');
                        Tau = fread(fid, bb2data.LuFuParam.imageWidth(ii)*bb2data.LuFuParam.imageHeight(ii), 'float', 0, 'ieee-le'); % todo prove this
                        bb2data.LuFuParam.Tau(:,:,ii) = reshape(Tau,bb2data.LuFuParam.imageWidth(ii),bb2data.LuFuParam.imageHeight(ii))';
                        
                        
                    otherwise 
                        fread(fid, payloadSize);
                        display('unknown ID when reading BB2 file')
                end 
                
            otherwise
                display('unknown ID when reading BB2 file')      
                fread(fid, payloadSize);

        end
    end
end

% remove space which was allocated too much 
bb2data.measurement.ElectrodeQuality(all(isnan(bb2data.measurement.ElectrodeQuality), 2), :) = [];
bb2data.measurement.ZeroRef(:, :, squeeze(all(all(isnan(bb2data.measurement.ZeroRef), 1), 2))) = [];

fclose(fid);