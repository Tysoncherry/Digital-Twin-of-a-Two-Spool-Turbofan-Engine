% batch_sim_runner.m
clear; clc;

% Optional: set RNG for reproducibility
% rng(12345);

numRuns = 200;

% Preallocate results (columns: FanEta, LPCEta, N1Scale, FuelMod, FlightStatus)
results = nan(numRuns, 5);

% Keep track if we've warned about missing FlightStatus to avoid spamming
warnedMissingFlightStatus = false;

for i = 1:numRuns
    % Random fault parameters (within specified bounds)
    fault.Fan_Eta   = randRange(0.75, 1.0);    % Fan efficiency [% of nominal]
    fault.LPC_Eta   = randRange(0.75, 1.0);    % Low-pressure compressor efficiency
    fault.N1_Scale  = randRange(0.90, 1.05);   % Fan spool speed scaling
    fault.Fuel_Mod  = randRange(0.8, 1.2);     % Fuel flow multiplier
    
    % Place Fault struct in base workspace so the Simulink model can read it
    assignin('base','Fault',fault);
    
    % Run Simulink model (adjust model name if different)
    try
        simOut = sim('TopLevel_Turbofan_DT_PDM','ReturnWorkspaceOutputs','on');
    catch ME
        warning('Simulation failed on run %d: %s', i, ME.message);
        % Leave results(i,:) as NaN and continue
        continue;
    end
    
    % Default status = NaN (in case FlightStatus isn't available)
    status = NaN;
    try
        % Attempt to extract FlightStatus from simOut.logsout
        if isprop(simOut, 'logsout') && ~isempty(simOut.logsout)
            element = simOut.logsout.getElement('FlightStatus');
            if ~isempty(element) && isprop(element, 'Values') && ~isempty(element.Values.Data)
                data = element.Values.Data;
                status = data(end);
            else
                if ~warnedMissingFlightStatus
                    warning('FlightStatus element found but contains no data. Recording NaN for FlightStatus.');
                    warnedMissingFlightStatus = true;
                end
            end
        else
            if ~warnedMissingFlightStatus
                warning('simOut.logsout is empty or missing. Recording NaN for FlightStatus.');
                warnedMissingFlightStatus = true;
            end
        end
    catch ME
        if ~warnedMissingFlightStatus
            warning('Could not extract FlightStatus from simOut.logsout. Recording NaN. Error: %s', ME.message);
            warnedMissingFlightStatus = true;
        end
    end
    
    results(i,:) = [fault.Fan_Eta, fault.LPC_Eta, fault.N1_Scale, fault.Fuel_Mod, status];
end

% Save CSV (create folder if needed)
outDir = fullfile('PDM','Logs');
if ~exist(outDir,'dir')
    mkdir(outDir);
end

T = array2table(results, ...
    'VariableNames', {'FanEta','LPCEta','N1Scale','FuelMod','FlightStatus'});
writetable(T, fullfile(outDir,'FaultSweep.csv'));

disp('Batch run complete. Results saved to PDM/Logs/FaultSweep.csv');
