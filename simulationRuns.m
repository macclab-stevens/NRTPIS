simParameters = [];
rng('shuffle');
for i = 1:1000
    rng('shuffle');
    clear -except i
    simParameters.folderName = 'Run_30Khz_1/'
    simParameters.numerology = 1 %0 = 15KHz , 1 = 30KHz
    PulseWidth = 500*10^-6
    %1 frame is 7680*2^simParameters.numerology;
    % so 0.3ms = 0.3*7680*2^simParameters.numerology
    prf_steps = 500:50:5000
    pwSteps = 0.1:0.1:100
    prf = prf_steps(randperm(length(prf_steps),1))
    PulseWidth = pwSteps(randperm(length(pwSteps),1))*10^(-6)
    StrtIndx = randperm(250,1)/1000   
    pulseStartIndx = StrtIndx*7680*2^simParameters.numerology
    % clear;
    % simParameters.schStrat = "StaticMCS";
    simParameters.schStrat = "RR";
    simParameters.mcsInt = 5;
    simParameters.NumFramesSim = 5; % Simulation time in terms of number of 10 ms frames (100 = 10s
    simParameters.mcsTable = '256QAM';
    simParameters.NumUEs = 10

    ttis = [2 4 7]
    TTI = ttis(randperm(3,1))

    simParameters.TTIGranularity = TTI;    
    simParameters.prf = prf
    simParameters.PulseWidth = PulseWidth;
    simParameters.PulseStartIndx = int32(pulseStartIndx);
    
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
    newFolderName = strcat('Results/TTI_Run_',dt,'pw',string(simParameters.PulseWidth*10^6),'_PWSl_',string(pulseStartIndx),'/tti_',string(simParameters.TTIGranularity),"_MCSWalk_",string(simParameters.mcsTable),"/");

    mkdir(newFolderName)
    % for i = 1:1
        i = 5;
        disp(i)
        tblFileName = strcat(newFolderName,'_MCS',string(i));
        simParameters.mcsInt = 5;
        % resultsTable = mainFunc(simParameters);
        % writetable(resultsTable,tblFileName);
        mainFunc(simParameters);
    % end

end

% simFileName = strcat(newFolderName,'_MCS',i);



