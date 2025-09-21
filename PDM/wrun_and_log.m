function wrun_and_log()
    % Load PDM
    pdmFile = fullfile(pwd, 'PDM', 'PDM_Data_Work.json');
    if ~isfile(pdmFile), error('PDM file not found'); end
    pdm = jsondecode(fileread(pdmFile));

    % Run Simulink model
    sim('TopLevel_Turbofan_DT_PDM');

    % Output extraction
    N1     = extractFinal(log_N1);
    N2     = extractFinal(log_N2);
    Thrust = extractFinal(log_Thrust);
    Fuel   = extractFinal(log_Fuel);

    % Health limits
    limits.N1     = [20000 30000];
    limits.N2     = [4000 6000];
    limits.Thrust = [250000 350000];
    limits.Fuel   = [0.01 0.1];
    thresholds.eta = 0.88;  % Minimum efficiency before alert

    % Fly or Ground Decision
    status = decideStatus(N1,N2,Thrust,Fuel,limits);

    % 🚨 Health Warning Analysis
    warnings = checkHealthWarnings(pdm, thresholds);

    % Output row
    Timestamp = string(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
    row = {
        Timestamp, N1, N2, Thrust, Fuel, ...
        pdm.Fan.Version, pdm.Fan.CyclesSinceInstall, ...
        pdm.LPC.Version, pdm.LPC.CyclesSinceInstall, ...
        pdm.HPC.Version, pdm.HPC.CyclesSinceInstall, ...
        pdm.HPT.Version, pdm.HPT.CyclesSinceInstall, ...
        pdm.LPT.Version, pdm.LPT.CyclesSinceInstall, ...
        status, warnings
    };

    headers = {
        'Timestamp','N1','N2','Thrust','FuelFlow', ...
        'FanVer','FanCycles','LPCVer','LPCCycles', ...
        'HPCVer','HPCCycles','HPTVer','HPTCycles','LPTVer','LPTCycles', ...
        'Status', 'HealthWarnings'
    };

    % Save to CSV
    outFile = fullfile(pwd,'PDM','Logs','RunSummary.csv');
    if ~isfolder(fullfile(pwd,'PDM','Logs')), mkdir(fullfile(pwd,'PDM','Logs')); end

    if isfile(outFile)
        writetable(cell2table(row), outFile, 'WriteMode','append', 'WriteVariableNames', false);
    else
        writetable(cell2table(row,'VariableNames',headers), outFile);
    end

    fprintf('✅ Logged with health check: %s\n', warnings);
end

function val = extractFinal(sig)
    if isa(sig, 'timeseries'), val = sig.Data(end);
    else, val = sig(end,2);
    end
end

function status = decideStatus(N1,N2,T,F,limits)
    if N1 < limits.N1(1) || N1 > limits.N1(2) || ...
       N2 < limits.N2(1) || N2 > limits.N2(2) || ...
       T < limits.Thrust(1) || T > limits.Thrust(2) || ...
       F < limits.Fuel(1) || F > limits.Fuel(2)
        status = "GROUND";
    else
        status = "FLY";
    end
end

function msg = checkHealthWarnings(pdm, th)
    warn = strings(0);
    parts = {'Fan','LPC','HPC','HPT','LPT'};
    for i = 1:length(parts)
        part = pdm.(parts{i});
        if isfield(part, 'Efficiency_Modifier') && part.Efficiency_Modifier < th.eta
            warn(end+1) = upper(parts{i}) + "_EFF↓";
        end
        if isfield(part, 'MaxCycles') && part.CyclesSinceInstall >= part.MaxCycles
            warn(end+1) = upper(parts{i}) + "_CYC↑";
        end
    end
    if isempty(warn), msg = "OK";
    else, msg = strjoin(warn, "; ");
    end
end