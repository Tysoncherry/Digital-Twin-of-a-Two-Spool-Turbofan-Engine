% batch_sim_runner.m
clear; clc;
numRuns = 200;
results = [];

for i = 1:numRuns
    % Random fault parameters
    fault.Fan_Eta   = randRange(0.75, 1.0);
    fault.LPC_Eta   = randRange(0.75, 1.0);
    fault.N1_Scale  = randRange(0.90, 1.05);
    fault.Fuel_Mod  = randRange(0.8, 1.2);
    
    assignin('base','Fault',fault);
    
    simOut = sim('TopLevel_Turbofan_DT_PDM','ReturnWorkspaceOutputs','on');
    
    % Assume CheckViability gives out signal 'FlightStatus'
    status = simOut.logsout.getElement('FlightStatus').Values.Data(end);
    
    results(end+1,:) = [fault.Fan_Eta, fault.LPC_Eta, fault.N1_Scale, fault.Fuel_Mod, status];
end

% Save CSV
T = array2table(results, ...
    'VariableNames', {'FanEta','LPCEta','N1Scale','FuelMod','FlightStatus'});
writetable(T,'PDM/Logs/FaultSweep.csv');
disp('Batch run complete. Results saved.');
