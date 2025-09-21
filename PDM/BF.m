% Load the table if not already loaded
T = readtable(fullfile(pwd, 'Logs', 'RunSummarym.csv'));

% Check class distribution
if any(strcmp(T.Properties.VariableNames, 'FlightStatus'))
    Y = categorical(T.FlightStatus);
    disp('Class Distribution:');
    tabulate(Y)
else
    error('FlightStatus column not found.');
end
