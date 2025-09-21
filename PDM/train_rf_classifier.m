function train_rf_classifier()
    % TRAIN_RF_CLASSIFIER - Trains a Random Forest on RunSummary.csv and evaluates performance.
    %
    % Notes / fixes:
    % - robust handling of FlightStatus whether it's numeric, cell of strings, string array, or categorical
    % - robust feature selection if some columns are missing
    % - fixed file name check/err msg
    % - uses TreeBagger with class labels passed as cellstr (predict returns cellstr)

    % Load data
    csvFile = fullfile(pwd,'Logs', 'RunSummary.csv');  % fixed filename (was RunSummarym.csv)
    if ~isfile(csvFile)
        error('RunSummary.csv not found in Logs folder (%s).', csvFile);
    end
    T = readtable(csvFile);

    fprintf('Loaded %d rows, %d variables\n', size(T,1), size(T,2));

    % Check and create target if missing
    if ~ismember('FlightStatus', T.Properties.VariableNames)
        warning('No FlightStatus column. Creating random labels.');
        T.FlightStatus = double(rand(height(T),1) > 0.3); % 0 = Ground, 1 = Fly
    end

    % Features to use (safe selection if some are missing)
    desiredFeatures = {'N1','N2','Thrust','FuelFlow', ...
                       'FanCycles','LPCCycles','HPCCycles','HPTCycles','LPTCycles'};
    presentFeatures = intersect(desiredFeatures, T.Properties.VariableNames, 'stable');
    if isempty(presentFeatures)
        error('None of the desired features (%s) are present in the table.', strjoin(desiredFeatures,', '));
    end
    if numel(presentFeatures) < numel(desiredFeatures)
        warning('Using subset of features: %s', strjoin(presentFeatures,', '));
    end
    X = T(:, presentFeatures);

    % Response handling (robust)
    Y_raw = T.FlightStatus;

    % Convert Y to categorical and keep both string labels and numeric codes
    try
        % If it's already categorical, this is harmless; if cellstr/string/numeric, it converts.
        Ycat = categorical(Y_raw);
    catch
        % Fallback: if weird cell contents, attempt to cellstr then categorical
        if iscell(Y_raw)
            Ycat = categorical(cellstr(Y_raw));
        else
            error('Unable to convert FlightStatus to categorical.');
        end
    end

    % numeric codes for splitting and evaluation
    [Ycodes, Ynames] = grp2idx(Ycat);   % Ycodes are 1..K, Ynames is cellstr of labels
    Ycell = cellstr(Ycat);              % labels as cellstr for TreeBagger

    % Convert features to numeric array (table2array will error if non-numeric columns present)
    % Attempt to convert columns individually if needed
    Xtable = X;
    for c = 1:width(Xtable)
        if ~isnumeric(Xtable{:,c})
            % try to convert strings/cell to numbers, else throw
            if iscellstr(Xtable{:,c}) || isstring(Xtable{:,c}) || iscategorical(Xtable{:,c})
                Xtable{:,c} = str2double(cellstr(Xtable{:,c}));
            else
                error('Feature column "%s" is non-numeric and cannot be converted.', Xtable.Properties.VariableNames{c});
            end
        end
    end
    X = table2array(Xtable);

    % Split into training and testing using numeric codes
    rng(1); % Reproducible
    cv = cvpartition(Ycodes, 'HoldOut', 0.3);
    XTrain = X(training(cv), :);
    XTest  = X(test(cv), :);

    YTrainCell = Ycell(training(cv));
    YTestCell  = Ycell(test(cv));
    YTestCodes = Ycodes(test(cv));  % numeric ground truth for evaluation

    % Train Random Forest (TreeBagger) - pass class labels as cellstr
    rf = TreeBagger(50, XTrain, YTrainCell, ...
                    'OOBPrediction','On', 'OOBPredictorImportance','On', ...
                    'Method','classification', 'NumPredictorsToSample','all');

    % Predict (returns cell array of labels)
    [YPredCell, scores] = predict(rf, XTest);

    % Map predicted labels back to numeric codes to compute accuracy/confusion
    YPredCodes = zeros(size(YPredCell));
    % Build a map from label to index (based on Ynames)
    label2idx = containers.Map(Ynames, 1:numel(Ynames));
    for i = 1:numel(YPredCell)
        if isKey(label2idx, YPredCell{i})
            YPredCodes(i) = label2idx(YPredCell{i});
        else
            % unexpected label -> NaN (shouldn't happen)
            YPredCodes(i) = NaN;
        end
    end

    % Evaluate
    fprintf('Random Forest Results:\n');
    try
        % Show confusion chart using the original label names
        confusionchart(categorical(YTestCell), categorical(YPredCell));
    catch
        % If interactive plotting fails, fall back to numeric confusion matrix
        cm = confusionmat(YTestCodes, YPredCodes);
        disp('Confusion matrix (rows = true, cols = predicted):');
        disp(array2table(cm, 'VariableNames', Ynames, 'RowNames', Ynames));
    end

    validIdx = ~isnan(YPredCodes);
    acc = sum(YPredCodes(validIdx) == YTestCodes(validIdx)) / numel(YTestCodes(validIdx));
    fprintf('Accuracy: %.2f%%\n', acc*100);

    % Optional: feature importance (if available)
    if ~isempty(rf.OOBPermutedPredictorDeltaError)
        figure;
        bar(rf.OOBPermutedPredictorDeltaError);
        xticklabels(presentFeatures);
        xtickangle(45);
        title('Feature Importance (OOB Permuted Predictor Delta Error)');
    end
end
