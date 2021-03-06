function [ event ] = neoEvents(eventTyp)
% following cases had been generated by BB2 code 
% (File TypedEvent.cs - function PrintMatlabDecoderCodeToDebugOut / see BB2 SVN rev. 1025)

switch (eventTyp);
      % 0x00000000 - Unspecified                             
    case(0);event = 'Unspecified';                             
        % 0x00000001 - Intubation                             
    case(1);event = 'Intubation';                             
        % 0x00000002 - Suction                               
    case(2);event = 'Suction';                             
        % 0x00000003 - Surfactant                            
    case(3);event = 'Surfactant';
        % 0x00000004 - PositionChange                     
    case(4);event = 'PositionChange';                       
        % 0x00000005 - PeepChange                              
    case(5);event = 'PeepChange';                      
        % 0x00000006 - Medication                             
    case(6);event = 'Medication';                      
        % 0x10000000 - Interventions                              
    case(268435456);event = 'Interventions';                              
        % 0x10010000 - ChangeModeIntervention                 
    case(268500992);event = 'Change Mode Intervention';                         
        % 0x10010100 - ChangeModeInterventionPcv                           
    case(268501248);event = 'Change Mode: Pcv';                         
        % 0x10010200 - ChangeModeInterventionVcvVg                         
    case(268501504);event = 'Change Mode: VcvVg';                              
        % 0x10010300 - ChangeModeInterventionHfov                              
    case(268501760);event = 'Change Mode: Hfov';                             
        % 0x10010400 - ChangeModeInterventionPsv                          
    case(268502016);event = 'Change Mode: Psv';
        % 0x10010500 - ChangeModeInterventionCpap        
    case(268502272);event = 'Change Mode: Cpap';                           
        % 0x10010600 - ChangeModeInterventionNimv                         
    case(268502528);event = 'Change Mode: Nimv';                          
        % 0x10010700 - ChangeModeInterventionHfnc                            
    case(268502784);event = 'Change Mode: Hfnc';                      
        % 0x10010800 - ChangeModeInterventionLfnc                  
    case(268503040);event = 'Change Mode: Lfnc';                          
        % 0x10020000 - IntubationIntervention                          
    case(268566528);event = 'Intubation Intervention';
        % 0x10020100 - IntubationInterventionPcv
    case(268566784);event = 'Intubation: Pcv';
        % 0x10020200 - IntubationInterventionVcvVg
    case(268567040);event = 'Intubation: VcvVg';
        % 0x10020300 - IntubationInterventionHfov
    case(268567296);event = 'Intubation: Hfov';
        % 0x10020400 - IntubationInterventionPsv
    case(268567552);event = 'Intubation: Psv';
        % 0x10020500 - IntubationInterventionCpap
    case(268567808);event = 'Intubation: Cpap';
        % 0x10020600 - IntubationInterventionNimv
    case(268568064);event = 'Intubation: Nimv';
        % 0x10020700 - IntubationInterventionHfnc
    case(268568320);event = 'Intubation: Hfnc';
        % 0x10020800 - IntubationInterventionLfnc
    case(268568576);event = 'Intubation: Lfnc';
        % 0x10030000 - ExtubationIntervention
    case(268632064);event = 'ExtubationIntervention';
        % 0x10030100 - ExtubationInterventionCpap
    case(268632320);event = 'Extubation: Cpap';
        % 0x10030200 - ExtubationInterventionNimv
    case(268632576);event = 'Extubation: Nimv';
        % 0x10030700 - ExtubationInterventionHfnc
    case(268633856);event = 'Extubation: Hfnc';
        % 0x10030800 - ExtubationInterventionLfnc
    case(268634112);event = 'Extubation: Lfnc';
    % 0x10030900 - ExtubationIntervention No Support
    case(268634368);event = 'Extubation:  No Support';   
        % 0x10040000 - BeltRemovalIntervention
    case(268697600);event = 'Belt RemovalIntervention';
        % 0x10040100 - BeltRemovalInterventionImaging
    case(268697856);event = 'Belt Removal: Imaging';
        % 0x10040200 - BeltRemovalInterventionChestDrain
    case(268698112);event = 'Belt Removal: ChestDrain';
        % 0x10040300 - BeltRemovalInterventionOther
    case(268698368);event = 'Belt Removal: Other';
        % 0x10050000 - MedicationIntervention
    case(268763136);event = 'Medication Intervention';
        % 0x10050100 - MedicationInterventionSedative
    case(268763392);event = 'Medication: Sedative';
        % 0x10050200 - MedicationInterventionAnalgetic
    case(268763648);event = 'Medication: Analgetic';
        % 0x10050300 - MedicationInterventionMuscleRelaxant
    case(268763904);event = 'Medication: MuscleRelaxant';
        % 0x10110000 - SuctioningIntervention
    case(269549568);event = 'Suctioning Intervention';
        % 0x10120000 - PatientCareIntervention
    case(269615104);event = 'Patient CareIntervention';
        % 0x10130000 - FluidBolusIntervention
    case(269680640);event = 'Fluid BolusIntervention';
        % 0x10150000 - XRayIntervention
    case(269811712);event = 'XRay Intervention';
        % 0x10160000 - OtherIntervention
    case(269877248);event = 'Other Intervention';
        % 0x10210000 - RecruitmentIntervention
    case(270598144);event = 'Recruitment Intervention';
        % 0x10210100 - RecruitmentInterventionStart
    case(270598400);event = 'Recruitment: Start';
        % 0x10210200 - RecruitmentInterventionEnd
    case(270598656);event = 'Recruitment: End';
        % 0x10220000 - SurfactantIntervention
    case(270663680);event = 'Surfactant Intervention';
        % 0x10230000 - VentilatorSettingsIntervention
    case(270729216);event = 'Ventilator Settings Intervention';
        % 0x10240000 - PostureChangeIntervention
    case(270794752);event = 'Posture Change Intervention';
        % 0x10240002 - PostureChangedInterventionDone
    case(270794754);event = 'Posture Changed: Done';
    % KangarooCareIntervention 0x10250000   
    case(270860288);event = 'Kangaroo Care Intervention';    
     % KangarooCareIntervention Start 0x10250100   
    case(270860544);event = 'Kangaroo Care Intervention: Start';
      % KangarooCareIntervention 0x10250200   
    case(270860800);event = 'Kangaroo Care Intervention: End';    
        % 0x20000000 - Findings
    case(536870912);event = 'Findings';
        % 0x20010000 - PneumothoraxFinding
    case(536936448);event = 'Pneumothorax Finding';
        % 0x20010100 - PneumothoraxFindingSuspected
    case(536936704);event = 'Pneumothorax: Suspected';
        % 0x20010200 - PneumothoraxFindingConfirmed
    case(536936960);event = 'Pneumothorax: Confirmed';
        % 0x20020000 - AtelectasisFinding
    case(537001984);event = 'Atelectasis Finding';
        % 0x20020100 - AtelectasisFindingSuspected
    case(537002240);event = 'Atelectasis: Suspected';
        % 0x20020200 - AtelectasisFindingConfirmed
    case(537002496);event = 'Atelectasis: Confirmed';
        % 0x20110000 - BeltDisplacementFinding
    case(537985024);event = 'Belt Displacement Finding';
        % 0x20120000 - DisconnectionFinding
    case(538050560);event = 'Disconnection Finding';
        % 0x20130000 - OtherFinding
    case(538116096);event = 'Other Finding';
        % 0x20210000 - TubeDisplacmentFinding
    case(539033600);event = 'Tube Displacment Finding';
        % 0x20210100 - TubeDisplacmentFindingSuspected
    case(539033856);event = 'Tube Displacment: Suspected';
        % 0x20210200 - TubeDisplacmentFindingConfirmed
    case(539034112);event = 'Tube Displacment: Confirmed';
        % 0x20210300 - TubeDisplacmentFindingCorrected
    case(539034368);event = 'Tube Displacment: Corrected';
        % 0x20220000 - PleuralEffusionFinding
    case(539099136);event = 'Pleural Effusion Finding';
        % 0x20220100 - PleuralEffusionFindingSuspected
    case(539099392);event = 'PleuralEffusion: Suspected';
        % 0x20220200 - PleuralEffusionFindingConfirmed
    case(539099648);event = 'Pleural Effusion: Confirmed';
        
    otherwise; event = 'unknown Event found';
end 




end

