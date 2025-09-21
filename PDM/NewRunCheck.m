function NewRunCheck()
% RUNCHECK — Pre-flight scan of PDM file to detect degraded parts

% Load PDM file
baseFile = fullfile(pwd, 'PDM_Data_Upgrade.json');
if ~isfile(baseFile)
    error('Base PDM file not found: %s', baseFile);
end
pdm = jsondecode(fileread(baseFile));

% Define health thresholds
minEfficiency = 0.90;
maxCycles = struct( ...
    'Fan', 200, ...
    'LPC', 180, ...
    'HPC', 200, ...
    'HPT', 190, ...
    'LPT', 180 ...
);

% Check each part
parts = fieldnames(pdm);
fprintf('--- Pre-Flight Readiness Check ---\n\n');
recommendUpgrade = false;

for i = 1:length(parts)
    part = parts{i};
    data = pdm.(part);
    
    eta = data.Efficiency_Modifier;
    cycles = data.CyclesSinceInstall;
    maxC = maxCycles.(part);
    
    fprintf('%s: η = %.2f, Cycles = %d/%d\n', ...
        part, eta, cycles, maxC);
    
    if eta < minEfficiency
        fprintf('  ⚠ Efficiency below %.2f — REPLACE ADVISED\n', minEfficiency);
        recommendUpgrade = true;
    end
    
    if cycles >= maxC
        fprintf('  ⚠ Cycles exceeded %d — REPLACE REQUIRED\n', maxC);
        recommendUpgrade = true;
    end
end

if recommendUpgrade
    fprintf('\n⚠ Some parts are degraded or expired.\n');
    fprintf('🔁 Switch to PDM_Upgrade.json before simulating.\n');
else
    fprintf('\n✅ All parts healthy. Safe to simulate.\n');
end
fprintf('------------------------------------\n');

end
