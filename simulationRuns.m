simParameters = [];

% for tti = [2,4,7]
    % clear;
    simParameters.schStrat = "StaticMCS";
    % simParameters.schStrat = "RR";
    simParameters.mcsInt = 5;
    simParameters.NumFramesSim = 20; % Simulation time in terms of number of 10 ms frames (100 = 10s
    simParameters.mcsTable = '256QAM';
    simParameters.NumUEs = 15
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

    simParameters.TTIGranularity = 4;
    dt = datestr(now,'yymmdd-HHMMSS');
    newFolderName = strcat('Results/TTI_Run_',dt,'/tti_',string(simParameters.TTIGranularity),"_MCSWalk_",string(simParameters.mcsTable),"/");

    mkdir(newFolderName)
    % for i = 1:1
        i = 5;
        disp(i)
        tblFileName = strcat(newFolderName,'_MCS',string(i));
        simParameters.mcsInt = 5;
        resultsTable = mainFunc(simParameters);
        writetable(resultsTable,tblFileName);
    % end

% end

% simFileName = strcat(newFolderName,'_MCS',i);



