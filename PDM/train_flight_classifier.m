% STEP 1: Load dataset
filePath = fullfile(pwd,'Logs', 'RunSummarym.csv');
if ~isfile(filePath)
    error('❌ CSV file not found: %s', filePath);
end

T = readtable(filePath);
fprintf('Checking dataset...\n   %d    %d\n\n', height(T), width(T));

% STEP 2: Convert FlightStatus into categorical labels
if ~any(strcmp(T.Properties.VariableNames, 'FlightStatus'))
    error('Missing FlightStatus column in CSV');
end

% Convert 0→Ground, 1→Fly
Y = categorical(T.FlightStatus);
Y = renamecats(Y, {'Ground', 'Fly'});

% STEP 3: Select input features (numeric only)
X = T{:, {'N1','N2','Thrust','FuelFlow', ...
          'FanCycles','LPCCycles','HPCCycles','HPTCycles','LPTCycles'}};

% STEP 4: Train/test split
rng(42); % For reproducibility
cv = cvpartition(height(T), 'HoldOut', 0.2);
XTrain = X(training(cv), :);
YTrain = Y(training(cv), :);
XTest  = X(test(cv), :);
YTest  = Y(test(cv), :);

% STEP 5: Train decision tree
fprintf('Training a decision tree classifier...\n');
Mdl = fitctree(XTrain, YTrain, 'SplitCriterion','gdi', 'MaxNumSplits', 20);

% STEP 6: Predict and evaluate
YPred = predict(Mdl, XTest);
accuracy = sum(YPred == YTest) / numel(YTest);

% STEP 7: Show confusion matrix and accuracy
fprintf('✅ Classification accuracy: %.2f%%\n\n', 100*accuracy);
figure('Name','Flight Classifier Confusion Matrix');
confusionchart(YTest, YPred);

% STEP 8 (Optional): View tree
view(Mdl, 'Mode','graph');

% STEP 9 (Optional): Save model
save('trained_flight_classifier.mat','Mdl');
fprintf('📁 Saved trained model to: trained_flight_classifier.mat\n');
