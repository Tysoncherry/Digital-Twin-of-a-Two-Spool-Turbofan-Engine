% parse_map_file.m
% Usage: change inputFile to your .Map path and run.
inputFile = 'bb287407-4313-4f15-9139-e372f5a8de37.Map';
outputMat  = 'engine_map_parsed.mat';

% Read full file as lines
txt = fileread(inputFile);
lines = regexp(txt, '\r\n|\r|\n', 'split');

% Define section names you expect (modify if your file uses different names)
sectionNames = { 'Min Pressure Ratio', 'Max Pressure Ratio', 'Mass Flow', 'Efficiency' };

% Helper to find section start indices
sectionIdx = containers.Map;
for i = 1:numel(lines)
    L = strtrim(lines{i});
    for s = 1:numel(sectionNames)
        if ~isempty(L) && startsWith(L, sectionNames{s}, 'IgnoreCase', true)
            sectionIdx(sectionNames{s}) = i;
        end
    end
end

% Function to gather numeric rows after a start line until a blank
function numCell = grabNumericBlock(lines, startLine)
    numCell = {};
    n = numel(lines);
    i = startLine + 1; % numbers start after the header line
    % keep collecting until next blank or non-numeric-looking header
    while i <= n
        L = strtrim(lines{i});
        if isempty(L)
            break;
        end
        % if line contains letters and is not just numbers, treat as end
        if ~isempty(regexp(L, '[A-Za-z]', 'once'))
            break;
        end
        % split on whitespace and/or commas
        parts = regexp(L, '[\s,]+', 'split');
        % attempt numeric conversion
        nums = str2double(parts);
        if all(isnan(nums))
            break;
        end
        numCell{end+1} = nums; %#ok<AGROW>
        i = i + 1;
    end
end

% Parse each section into a numeric matrix (rows might be ragged -> pad with NaN)
parsed = struct();
keys = sectionNames;
for k = 1:numel(keys)
    name = keys{k};
    if isKey(sectionIdx, name)
        startLine = sectionIdx(name);
        numRows = grabNumericBlock(lines, startLine);
        if isempty(numRows)
            parsed.(matlab.lang.makeValidName(name)) = [];
            continue
        end
        % find max row length and build matrix
        maxLen = max(cellfun(@numel, numRows));
        M = NaN(numel(numRows), maxLen);
        for r = 1:numel(numRows)
            row = numRows{r};
            M(r,1:numel(row)) = row;
        end
        parsed.(matlab.lang.makeValidName(name)) = M;
    else
        parsed.(matlab.lang.makeValidName(name)) = [];
    end
end

% OPTIONAL: try to detect repeated header rows (like a column of x-values followed by blocks)
% Some .Map files place a parameter row (count) followed by a grid of values.
% We'll attempt to auto-detect common pattern: first numeric row is an index (counts),
% second row may be the x-grid and then blocks of (y + matrix). This is dataset-dependent.
% For now we just save the raw numeric matrices.

% Save result
save(outputMat, '-struct', 'parsed');

fprintf('Saved parsed data to %s\n', outputMat);
fprintf('Variables saved: %s\n', strjoin(fieldnames(parsed), ', '));
