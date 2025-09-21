function loadworkPDM()
    % LOADPDM  — Read PDM JSONs, apply cycle‑based degradation, and assign
    %            all PDM variables into the MATLAB base workspace.

    % Baseline JSON
    baseFile = fullfile('D:\Thesis\Turbofan_DigitalTwin_Thesis\PDM\PDM_Data_Work.json');
    if ~isfile(baseFile)
        error('Missing baseline PDM file: %s', baseFile);
    end
    pdmBase = jsondecode(fileread(baseFile));

    % Upgrade JSON (optional)
    upgFile = fullfile(pwd,'PDM','PDM_Data_Upgrade.json');
    if isfile(upgFile)
        pdmUpg = jsondecode(fileread(upgFile));
    else
        pdmUpg = pdmBase;
    end

    % List of components
    comps = {'Fan','LPC','HPC','HPT','LPT'};

    for i = 1:numel(comps)
        c = comps{i};

        % Raw base efficiency & cycles
        rawEff = pdmBase.(c).Efficiency_Modifier;
        cyc    = pdmBase.(c).CyclesSinceInstall;
        % Degradation: 0.0005 eff loss per cycle, min 0.80
        degEff = max(0.80, rawEff - 0.0005*cyc);

        % Upgrade efficiency & version
        upEff = pdmUpg.(c).Efficiency_Modifier;
        upVer = pdmUpg.(c).Version;

        % Assign to base workspace
        assignin('base',[ 'Eff_Mod_' c ],    degEff);
        assignin('base',[ 'Ver_'     c ],    pdmBase.(c).Version);
        assignin('base',[ 'Cycles_'  c ],    pdmBase.(c).CyclesSinceInstall);
        assignin('base',[ 'Eff_Mod_' c '_Up'], upEff);
        assignin('base',[ 'Ver_'     c '_Up'], upVer);
    end

    % Default upgrade flag if not set
    if ~evalin('base','exist(''DoUpgrade'',''var'')')
        assignin('base','DoUpgrade',false);
    end
end
