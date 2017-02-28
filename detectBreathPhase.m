function [breathInfo, threshCrossings, breathPhase, thresholdSig] = ...
            detectBreathPhase(impedanceSig, fSampling, fRespRange, doPlot)
%% detectBreathPhase determines the breath phase (inspiration/expiration) in an EIT impedance signal
%
% Inputs:
%   - impedanceSignal   impedance signal (e.g. sum over all EIT pixels)
%   - fSampling         sampling rate of the impedance signal
%   - fRespRange        vector defining the min/max respiration frequency
%   - doPlot            visualizes results if true (opt., default:false)
%
% Outputs:
%   - breathInfo        inspiration start/end, expiration end per breath
%                       ( 3 x nBreaths : [start insp, start exp, end exp])
%   - threshCrossings   rising/falling threshold crossing detection:
%                       (+1/-1: rising/falling crossing, 0: no crosing)
%   - breathPhase       sample-wise vector of the breath phase:
%                       (1: inspiration, 0: expiration)
%
%
% $Rev:: 89            $:  Revision of last commit
% $Author:: awa        $:  Author of last commit
% $Date:: 2014-09-11 1#$:  Date of last commit
%
%
% Note: This code is intentionally written inefficient in order to mimick 
% real-time behaviour and to facilitate the porting of the code to the
% final system.
%
%

%% CONFIGURATION
MINIMAL_BREATH_PERIOD = fSampling / max(fRespRange);
% orig
%MINIMAL_IDENTICAL_CROSSING_SPACING = ceil(3/4*MINIMAL_BREATH_PERIOD);
%MINIMAL_DIFFERENT_CROSSING_SPACING = ceil(1/4*MINIMAL_BREATH_PERIOD);
%thresholdBandpassCutoffs = [1*min(fRespRange) 1*max(fRespRange)];% newly "tuned" settings, currently implemanted in BB2 24.7.2014
% according to documentation
% thresholdBandpassCutoffs = [0.5*min(fRespRange) 3*max(fRespRange)]; % paris settings
% BB2: 1.1.0.5
%thresholdBandpassCutoffs = [1.3*0.25*min(fRespRange) 5.0*0.25*max(fRespRange)]; 
MINIMAL_IDENTICAL_CROSSING_SPACING = max(2,ceil(3/4*MINIMAL_BREATH_PERIOD));
MINIMAL_DIFFERENT_CROSSING_SPACING = max(1,ceil(1/4*MINIMAL_BREATH_PERIOD));

% redesign:
thresholdBandpassCutoffs = [0.325*min(fRespRange) 0.875*max(fRespRange)]; 

%% parse & default inputs
%setDefaultInput('doPlot', false);
%assert(length(fRespRange) == 2);


%% initialization
breathPhase = nan(length(impedanceSig), 1);
 threshCrossings = nan(length(impedanceSig), 1);
waitForRisingCrossing = false;
currentMinimumPosition = 0;
currentMinimumValue = +Inf;
currentMaximumPosition = 0;
currentMaximumValue = -Inf;
lastRisingCrossing = -inf;
lastFallingCrossing = -inf;
iBreath = 0;
breathInfo(:,1) = zeros(1,3);

%% generate threshold signal
%orig
%[b, a] = awa_butter(2, thresholdBandpassCutoffs/fSampling);       % unclear why we device by two 
% BB2
[b, a] = butter(2, thresholdBandpassCutoffs/(fSampling/2));       % unclear why we device by two 
zi = initIir(b, a, mean(impedanceSig(1:3))); % awa
thresholdSig = filter(b, a, impedanceSig, zi);


% figure, plot(impedanceSig), hold all, plot(thresholdSig),  hold all,  plot(thresholdSig1) 
% thresholdSig1 = filter(b, a, impedanceSig);

%thresholdSig1 = awa_filtfilt(b, a, impedanceSig); warning('put back to filt and not filtfilt');


%% mex-file test (invoke c++ class)
% [n, d, o] = butterBandpass(2, fSampling, thresholdBandpassCutoffs(1), ...
%                           thresholdBandpassCutoffs(2), impedanceSig);
% clear mex;
% thresholdSig = o;


%% loop through all samples
for i = 3 : length(impedanceSig)-2*fSampling
    
   
    % awa try with amplitude criteria 
   % range = impedanceSig(i:i+2*fSampling); 
  %  if ( mean(range) > 0)
    
    
        %% simple state machine (rising/falling) crossing
        if waitForRisingCrossing
            %% yes: wait for RISING crossing

            % constantly update current minimum
            if impedanceSig(i-1) < currentMinimumValue;
                currentMinimumPosition = i-1;
                currentMinimumValue = impedanceSig(i-1);
            end

            %% rising crossing occured?
            if (((i-1) - lastRisingCrossing) >= MINIMAL_IDENTICAL_CROSSING_SPACING) && ...
                    (((i-1) - lastFallingCrossing) >= MINIMAL_DIFFERENT_CROSSING_SPACING) && ...
                    (thresholdSig(i-2) < 0) && (thresholdSig(i) > 0)

    %             %% DEBUG: TODO: REMOVE
    %             if (currentMinimumPosition >= i)
    %                 display('aaarg!');
    %             end
                assert(currentMinimumPosition < i);    % safety check ;)
                % TODO: fixthis!!!

                % store crossing position
                threshCrossings(i-1) = 1;   % RISING;

                % confirm last minimum and thus last expiration phase
                breathPhase(currentMaximumPosition: currentMinimumPosition-1) = 0; % EXPIRATION
                %
                % In real-time system: NOTIFY about new expiration phase
                %
                % in MATLAB we simply update the breath information matrix
                if ~((iBreath == 0) && (breathInfo(1, 1) == 0))
                    iBreath = iBreath + 1;
                    breathInfo(2:3,iBreath) = [currentMaximumPosition-1, currentMinimumPosition-1];
                end

                % switch state-machine to falling crossing detection
                waitForRisingCrossing = false;
                % remember this as last crossing
                lastRisingCrossing = i-1;
                % reset maximum
                currentMaximumValue = -inf;
            end
        else
            %% no: wait for FALLING crossing

            % constantly update current maximum
            if impedanceSig(i-1) > currentMaximumValue
                currentMaximumPosition = i-1;
                currentMaximumValue = impedanceSig(i-1);
            end

            %% falling crossing occured?
            if (((i-1) - lastFallingCrossing) >= MINIMAL_IDENTICAL_CROSSING_SPACING) && ...
                    (((i-1) - lastRisingCrossing) >= MINIMAL_DIFFERENT_CROSSING_SPACING) && ...
                    (thresholdSig(i-2) > 0) && (thresholdSig(i) < 0)

                assert(currentMaximumPosition < i);    % safety check ;)
                % TODO: fixthis!!!

                % store crossing position
                threshCrossings(i-1) = -1;   % FALLING;

                % confirm last maximum and thus last inspiration phase
                breathPhase(max(1,currentMinimumPosition) : currentMaximumPosition-1) = 1; % INSPIRATION
                %
                % In real-time system: NOTIFY about new inspiration phase
                % (if necessary, else wait for complete breath, incl. expirat.)
                %
                breathInfo(1,iBreath+1) = [currentMinimumPosition];

                % switch state-machine  to rising crossing detection
                waitForRisingCrossing = true;
                % remember this as last crossing
                lastFallingCrossing = i-1;
                % reset minimum
                currentMinimumValue = +inf;
            end
        end 
   % end
end

% crop breath info if it is too long
breathInfo = breathInfo(:,1:iBreath);


%% visualize if requested
if doPlot
 
    fig = figure(123003);
     set(fig, 'name', 'new algo');
     visualizeBreaths(impedanceSig, thresholdSig, breathInfo, threshCrossings, breathPhase, true, false); 
    
    
end


end
