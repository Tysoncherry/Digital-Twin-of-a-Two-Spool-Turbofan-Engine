% Read the CSV file
data = readtable('RunSummarym.csv');

% Change 'Label' and 'Feature1' to actual column names in your CSV
label_col = 'Label';        % Column name for health/fault label
feature_col = 'SensorValue'; % Column name to plot (e.g., a sensor)

% Unique fault labels (Assuming: 'Healthy', 'Fault1', 'Fault2', etc.)
labels = unique(data.(label_col));
healthy_label = 'Healthy';  % Change this if your healthy label is different
fault_labels = setdiff(labels, healthy_label);

% Loop through each fault and plot vs healthy
for i = 1:length(fault_labels)
    fault = fault_labels{i};

    % Extract data
    healthy_data = data(strcmp(data.(label_col), healthy_label), :);
    fault_data = data(strcmp(data.(label_col), fault), :);

    % Plot
    figure;
    plot(1:height(healthy_data), healthy_data.(feature_col), 'g', 'DisplayName', 'Healthy');
    hold on;
    plot(1:height(fault_data), fault_data.(feature_col), 'r', 'DisplayName', fault);
    title(['Healthy vs ' fault]);
    xlabel('Sample Index');
    ylabel(feature_col);
    legend;
    grid on;
end
