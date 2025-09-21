% STEP 1: Load dataset
filePath = fullfile(pwd,'Logs', 'RunSummary_CLEANED.csv');
if ~isfile(filePath)
    error('❌ CSV file not found: %s', filePath);
end

T = readtable(filePath);
fprintf('Checking dataset...\n   %d    %d\n\n', height(T), width(T));

% Convert FlightStatus to categorical
T.FlightStatus = categorical(T.FlightStatus);

% 2. Define features and labels
X = T{:, {'N1','N2','Thrust','FuelFlow','FanCycles','LPCCycles','HPCCycles','HPTCycles','LPTCycles'}};
Y = T.FlightStatus;

% 3. Train-test split
cv = cvpartition(Y, 'HoldOut', 0.3);
XTrain = X(training(cv), :);
YTrain = Y(training(cv));
XTest = X(test(cv), :);
YTest = Y(test(cv));

% 4. Decision Tree Classifier
tree = fitctree(XTrain, YTrain);
YPredTree = predict(tree, XTest);
[prec, rec, f1] = computeMetrics(YTest, YPredTree);
fprintf('\n--- Decision Tree ---\n');
fprintf('Precision: %.2f\nRecall: %.2f\nF1 Score: %.2f\n', prec, rec, f1);
figure; confusionchart(YTest, YPredTree, 'Title', 'Decision Tree Confusion');

% 5. Random Forest Classifier (TreeBagger)
rf = TreeBagger(100, XTrain, YTrain, ...
'OOBPrediction', 'on', ...
'OOBPredictorImportance', 'on', ...
'Method', 'classification');

YPredRF = predict(rf, XTest);
YPredRF = categorical(str2double(YPredRF));
[precRF, recRF, f1RF] = computeMetrics(YTest, YPredRF);
fprintf('\n--- Random Forest ---\n');
fprintf('Precision: %.2f\nRecall: %.2f\nF1 Score: %.2f\n', precRF, recRF, f1RF);
figure; confusionchart(YTest, YPredRF, 'Title', 'Random Forest Confusion');

% 6. Feature Importance Plot
figure;
bar(rf.OOBPermutedPredictorDeltaError);
title('Random Forest - Feature Importance');
ylabel('Predictor Importance');
xticklabels({'N1','N2','Thrust','FuelFlow','FanCycles','LPCCycles','HPCCycles','HPTCycles','LPTCycles'});
grid on;

% 7. Metric helper function
function [precision, recall, f1] = computeMetrics(trueLabels, predLabels)
TP = sum((trueLabels == '1') & (predLabels == '1'));
FP = sum((trueLabels == '0') & (predLabels == '1'));
FN = sum((trueLabels == '1') & (predLabels == '0'));
precision = TP / (TP + FP + eps);
recall = TP / (TP + FN + eps);
f1 = 2 * (precision * recall) / (precision + recall + eps);
end