simParameters = [];
rng('shuffle');
for i = 1:1
    rng('shuffle');
    clear -except i
    simParameters.folderName = 'Run1/'
    % PulseWidthValues = 10e-6:10e-6:500e-6
    % randomPWIndex = randi(length(PulseWidthValues)); % Generate a random index
    % PulseWidth = PulseWidthValues(randomPWIndex); % Select the random value
    PulseWidth = (randperm(500,1)+5)*10^(-6)
    pulseStartIndx = randperm(3840,1)    

    % clear;
    simParameters.schStrat = "StaticMCS";
    % simParameters.schStrat = "RR";
    simParameters.mcsInt = 5;
    simParameters.NumFramesSim = 3; % Simulation time in terms of number of 10 ms frames (100 = 10s
    simParameters.mcsTable = '256QAM';
    simParameters.NumUEs = 10


    simParameters.PulseWidth = PulseWidth;
    simParameters.PulseStartIndx = pulseStartIndx;
    ;
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

    simParameters.TTIGranularity = 2;
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



