% Reference values
ref.Thrust = 22200.0;
ref.N1 = 78.0;
ref.N2 = 94.0;
ref.FuelFlow = 0.70;

% Check ss struct exists in workspace
if exist('ss', 'var')
    % Calculate error percentages
    error.Thrust = 100 * (ss.Thrust - ref.Thrust) / ref.Thrust;
    error.N1 = 100 * (ss.N1 - ref.N1) / ref.N1;
    error.N2 = 100 * (ss.N2 - ref.N2) / ref.N2;
    error.FuelFlow = 100 * (ss.FuelFlow - ref.FuelFlow) / ref.FuelFlow;

    % Print the validation table
    fprintf('--- Cruise Condition Validation ---\n');
    fprintf('Parameter\tRef\tSim\tError(%%)\n');
    fprintf('Thrust (N)\t%.1f\t%.1f\t%.2f%%\n', ref.Thrust, ss.Thrust, error.Thrust);
    fprintf('N1 (%%)\t\t%.1f\t%.1f\t%.2f%%\n', ref.N1, ss.N1, error.N1);
    fprintf('N2 (%%)\t\t%.1f\t%.1f\t%.2f%%\n', ref.N2, ss.N2, error.N2);
    fprintf('Fuel Flow\t%.2f\t%.2f\t%+.2f%%\n', ref.FuelFlow, ss.FuelFlow, error.FuelFlow);

    % Create vectors for plotting
    parameters = {'Thrust (N)', 'N1 (%)', 'N2 (%)', 'Fuel Flow (kg/s)'};
    ref_values = [ref.Thrust, ref.N1, ref.N2, ref.FuelFlow];
    sim_values = [ss.Thrust, ss.N1, ss.N2, ss.FuelFlow];
    error_values = [error.Thrust, error.N1, error.N2, error.FuelFlow];

    % Plot Ref vs Sim
    figure('Name','Cruise Condition: Ref vs Sim','NumberTitle','off');
    bar([ref_values; sim_values]')
    set(gca, 'XTickLabel', parameters)
    legend({'Reference', 'Simulation'})
    ylabel('Value')
    title('Reference vs Simulation Values')

    % Plot Error %
    figure('Name','Cruise Condition Validation Errors','NumberTitle','off');
    bar(error_values)
    set(gca, 'XTickLabel', parameters)
    ylabel('Error (%)')
    title('Validation Error Percentage')
    grid on

else
    error('Simulation results (ss) not found in workspace.');
end
