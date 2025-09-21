% Step 1: Load the Excel file
T = readtable('mission_phase_data.xlsx');

% Step 2: Define phase order (optional but ensures consistency)
phaseCategories = {'Taxi','Takeoff','Climb','Cruise','Descent','Landing'};

% Ensure both columns are categorical and ordered
T.TruePhase = categorical(T.TruePhase, phaseCategories);
T.PredPhase = categorical(T.PredPhase, phaseCategories);

% Step 3: Generate confusion matrix
figure;
cm = confusionchart(T.TruePhase, T.PredPhase);
cm.Title = 'Mission-Phase Classification Confusion Matrix (CFM56-style)';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';

% Step 4: Save figure for thesis
saveas(gcf, 'mission_phase_confmat.png');  % You can also use .pdf if preferred
