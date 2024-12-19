simParameters = [];
rng('shuffle');
for i = 1:1000
    rng('shuffle');
    clear -except i
    simParameters.folderName = 'Run_30Khz_1/'
    simParameters.numerology = 1 %0 = 15KHz , 1 = 30KHz
    suppBW_15 = [ 10 15 20  25  30  40  50 ]
    rbsBW_15 =  [ 52 79 106 133 160 216 270    ]
    suppBW_30 = [10 15 20 25 30 40  50  60  70  80  90  100]
    rbsBW_30 =  [24 38 51 65 78 106 133 162 189 217 245 273]
    radarBWarr = [1 2 5 10 20]
    radarBWoffsetArr = [0 1 2 5 10 25]

    % PulseWidth = 500*10^-6
    %1 frame is 7680*2^simParameters.numerology;
    % so 0.3ms = 0.3*7680*2^simParameters.numerology
    fs = 7680000*2^simParameters.numerology;
    prf_steps = 500:5:5000
    prf_steps = prf_steps(mod(fs, prf_steps) == 0) %make sure fs / prfSteps are only integers
    pwSteps = 0.1:0.1:100
    prf = prf_steps(randperm(length(prf_steps),1))
    PulseWidth = pwSteps(randperm(length(pwSteps),1))*10^(-6)
    StrtIndx = randperm(250,1)/1000   
    pulseStartIndx = StrtIndx*7680*2^simParameters.numerology
    bw = radarBWarr(randperm(length(radarBWarr),1))
    bw_offset = radarBWoffsetArr(randperm(length(radarBWoffsetArr),1))

    simParameters.pulseAttenuation = -0;
    
    % simParameters.schStrat = "StaticMCS";

    simParameters.schStrat = "RR";
    simParameters.mcsInt = 10;
    simParameters.NumFramesSim = 10; % Simulation time in terms of number of 10 ms frames (100frames = 1s   1frame = 0.010s]
    simParameters.mcsTable = '256QAM';
    simParameters.NumUEs = 20

    ttis = [2 4 7 14]
    TTI = ttis(randperm(4,1))
    if TTI == 14
        simParameters.slotOrSymbol = 0; % Set the value to 0 (slot-based scheduling) or 1 (symbol-based scheduling)
    else
        simParameters.slotOrSymbol = 1; % Set the value to 0 (slot-based scheduling) or 1 (symbol-based scheduling)
    end

    simParameters.TTIGranularity = TTI;    
    simParameters.prf = prf %2000 %2000 Hz is good for validation. 2000Hz = 1 pulse per 0.5ms slot f=1/t
    simParameters.PulseWidth = PulseWidth;
    simParameters.PulseStartIndx = int32(pulseStartIndx);
    simParameters.PulseBW = bw * 10^6
    simParameters.PulseBWoffset = bw_offset * 10^6
    % Assign position to the UEs assuming that the gNB is at (0, 0, 0). N-by-3
    % matrix where 'N' is the number of UEs. Each row has (x, y, z) position of a
    % UE (in meters)
     % simParameters.UEPosition = [   
     %   300     0     0;
     %   300     0     0;
     %   300     0     0;
     %   300     0     0;
     %   300     0     0;
     %   ];
    simParameters.UEPosition = repmat([300, 0, 0], simParameters.NumUEs, 1);
    % simParameters.ulAppDataRate = [10e6,10e6,10e6,10e6,10e6];
    % simParameters.dlAppDataRate = [10e6,10e6,10e6,10e6,10e6];

    simParameters.ulAppDataRate = repmat([10e6], simParameters.NumUEs, 1);
    simParameters.dlAppDataRate = repmat([10e6], simParameters.NumUEs, 1);

    
    dt = datestr(now,'yymmdd-HHMMSS');
    newFolderName = strcat('Results/TTI_Run_',dt,'_PWSl_',string(pulseStartIndx),'/tti_',string(simParameters.TTIGranularity),"_MCSWalk_",string(simParameters.mcsTable),"/");

    % mkdir(newFolderName)
    % % for i = 1:1
    %     i = 5;
    %     disp(i)
    %     tblFileName = strcat(newFolderName,'_MCS',string(i));
    %     simParameters.mcsInt = 5;
    %     % resultsTable = mainFunc(simParameters);
    %     % writetable(resultsTable,tblFileName);
    try
        mainFunc(simParameters);
    catch ME
        % print(ME.message)
        ME
    end

        % end

end

% simFileName = strcat(newFolderName,'_MCS',i);



