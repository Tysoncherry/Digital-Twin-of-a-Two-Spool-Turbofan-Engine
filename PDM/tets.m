% Load RunSummary
T = readtable('RunSummarym.csv');

% Define logical flags
N1_OK = T.N1 > 16000;
Thrust_OK = T.Thrust > 2.4e5;
Fuel_OK = T.FuelFlow > 0.045;

% Check if any component is close to max life (180+ cycles)
Fan_OK = T.FanCycles < 180;
LPC_OK = T.LPCCycles < 180;
HPC_OK = T.HPCCycles < 180;
HPT_OK = T.HPTCycles < 180;
LPT_OK = T.LPTCycles < 180;

% Combine logic
ReadyToFly = N1_OK & Thrust_OK & Fuel_OK & ...
Fan_OK & LPC_OK & HPC_OK & HPT_OK & LPT_OK;

% Reassign status
T.FlightStatus = double(ReadyToFly);

% Export cleaned file
writetable(T, 'RunSummary_CLEANED.csv');
fprintf('✅ RunSummary_CLEANED.csv saved with logic-based FlightStatus.\n');