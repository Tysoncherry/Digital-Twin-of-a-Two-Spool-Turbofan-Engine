% STEP 1: Load dataset
filePath = fullfile(pwd, 'Logs', 'RunSummarym.csv');
if ~isfile(filePath)
    error('❌ CSV file not found: %s', filePath);
end

T = readtable(filePath);
fprintf('Checking dataset...\n %d rows %d columns\n\n', height(T), width(T));

% STEP 2: Convert FlightStatus into categorical labels
if ~any(strcmp(T.Properties.VariableNames, 'FlightStatus'))
    error('Missing FlightStatus column in CSV');
end

Y = categorical(T.FlightStatus);
Y = renamecats(Y, {'Ground', 'Fly'});

% STEP 3: Select numeric features
X = T{:, {'N1','N2','Thrust','FuelFlow', ...
          'FanCycles','LPCCycles','HPCCycles','HPTCycles','LPTCycles'}};

% STEP 4: Train/Test split
rng(42);
cv = cvpartition(height(T), 'HoldOut', 0.2);
XTrain = X(training(cv), :); YTrain = Y(training(cv), :);
XTest = X(test(cv), :); YTest = Y(test(cv), :);

% STEP 5: Train Decision Tree
fprintf('Training Decision Tree...\n');
treeMdl = fitctree(XTrain, YTrain, 'SplitCriterion','gdi', 'MaxNumSplits', 20);
[YPredTree, scoresTree] = predict(treeMdl, XTest);

% STEP 6: Train Random Forest
fprintf('Training Random Forest...\n');
rfMdl = TreeBagger(50, XTrain, YTrain, 'OOBPrediction','on', 'Method','classification');
[YPredRF, scoresRF] = predict(rfMdl, XTest);
YPredRF = categorical(YPredRF);

% STEP 7: Define metric calculator
function reportMetrics(YTrue, YPred, modelName)
    fprintf('\n📊 Metrics for %s:\n', modelName);
    C = confusionmat(YTrue, YPred);
    TP = C(2,2); TN = C(1,1); FP = C(1,2); FN = C(2,1);
    precision = TP / (TP + FP);
    recall = TP / (TP + FN);
    f1 = 2 * (precision * recall) / (precision + recall);
    acc = sum(YPred == YTrue) / numel(YTrue);

    fprintf('✅ Accuracy  : %.2f%%\n', 100*acc);
    fprintf('🔁 Precision : %.2f%%\n', 100*precision);
    fprintf('🔂 Recall    : %.2f%%\n', 100*recall);
    fprintf('📈 F1 Score  : %.2f%%\n', 100*f1);

    figure('Name', sprintf('%s Confusion Matrix', modelName));
    confusionchart(YTrue, YPred);
end

% STEP 8: Report metrics
reportMetrics(YTest, YPredTree, 'Decision Tree');
reportMetrics(YTest, YPredRF, 'Random Forest');

% STEP 9: AUC for Decision Tree
[treeX, treeY, ~, treeAUC] = perfcurve(YTest, scoresTree(:,2), 'Fly');
figure('Name', 'Decision Tree ROC');
plot(treeX, treeY, 'r-', 'LineWidth', 2);
xlabel('False Positive Rate'); ylabel('True Positive Rate');
title(sprintf('Decision Tree ROC (AUC = %.2f)', treeAUC));
grid on;

% STEP 10: AUC for Random Forest
[rfX, rfY, ~, rfAUC] = perfcurve(YTest, scoresRF(:,2), 'Fly');
figure('Name', 'Random Forest ROC');
plot(rfX, rfY, 'b-', 'LineWidth', 2);
xlabel('False Positive Rate'); ylabel('True Positive Rate');
title(sprintf('Random Forest ROC (AUC = %.2f)', rfAUC));
grid on;

% STEP 11: Save models
save('trained_flight_classifier.mat','treeMdl','rfMdl');
fprintf('\n📁 Saved models to trained_flight_classifier.mat\n');
