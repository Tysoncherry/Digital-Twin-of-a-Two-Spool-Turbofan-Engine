% 2️⃣ ---- Display ONE specific fault case ----
% Change this name to any of: 
% 'Baseline', 'FanEffDrop', 'HPCEffDrop', 'N1Drag', 'FuelStarve'
faultToShow = 'FanEffDrop';

idx = find(strcmp(fault_names, faultToShow));
if isempty(idx)
    error('Fault name not found. Check spelling.');
end

singleCase = array2table(values(idx,:), ...
    'VariableNames', variables, ...
    'RowNames', {faultToShow});

disp('=== Selected Fault Case ===');
disp(singleCase);

% 3️⃣ ---- Loop through all cases one by one ----
disp(' ');
disp('=== All Fault Cases (press any key to step through) ===');
for i = 1:numel(fault_names)
    T = array2table(values(i,:), ...
        'VariableNames', variables, ...
        'RowNames', {fault_names{i}});
    disp(T);
    pause;   % waits for key press before showing next
end

% 4️⃣ ---- Optional: Plot the selected case ----
figure;
bar(values(idx,:));
set(gca, 'XTickLabel', variables, 'FontWeight','bold');
ylabel('Value');
title(['Fault Mode: ', fault_names{idx}]);
grid on;
