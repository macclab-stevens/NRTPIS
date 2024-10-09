simParameters = [];
simParameters.schStrat = "RR";
simParameters.NumFramesSim = 20; % Simulation time in terms of number of 10 ms frames (100 = 10s

simParameters.NumUEs = 10;
% Assign position to the UEs assuming that the gNB is at (0, 0, 0). N-by-3
% matrix where 'N' is the number of UEs. Each row has (x, y, z) position of a
% UE (in meters)
simParameters.UEPosition = [   
   500     0     0;
   700     0     0;
  1000     0     0;
  1400     0     0;
  2000     0     0;
  2750     0     0;
  4000     0     0;
  5500     0     0;
  7500     0     0;
 10000     0     0];


% Application traffic configuration
% Set the periodic DL and UL application traffic pattern for UEs.
% Set the periodic DL and UL application traffic pattern for UEs
% simParameters.dlAppDataRate = 16e4*ones(simParameters.NumUEs,1); % DL application data rate in kilo bits per second (kbps)
simParameters.dlAppDataRate = [10e3,10e3,10e3,10e3,10e3,10e3,10e3,10e3,10e3,10e3];
simParameters.ulAppDataRate = [10e3,10e3,10e3,10e3,10e3,10e3,10e3,10e3,10e3,10e3];

mainFunc(simParameters)