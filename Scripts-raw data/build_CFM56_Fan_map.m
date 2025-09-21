% Scripts/build_CFM56_Fan_map.m
% Define speed vector and flow vector (you must replace with actual values)
speed_vec_fan = [0.5 0.7 0.9 1.0 1.1 1.2];     % Normalized speed
flow_vec_fan  = [20 40 60 80 100 120];         % Corrected mass flow (kg/s)

% 2D map of pressure ratio (rows: speeds, cols: flows)
Fan_PR_data = [
    1.2 1.3 1.35 1.4 1.38 1.35;
    1.3 1.4 1.5  1.6 1.55 1.45;
    1.35 1.5 1.65 1.75 1.7 1.55;
    1.4 1.6 1.8 1.9 1.85 1.65;
    1.38 1.55 1.75 1.85 1.8 1.6;
    1.35 1.45 1.6 1.7 1.65 1.5
];

% 2D map of efficiency (rows: speeds, cols: flows)
Fan_eta_data = [
    0.75 0.78 0.80 0.79 0.77 0.74;
    0.78 0.82 0.85 0.84 0.82 0.78;
    0.80 0.86 0.89 0.88 0.85 0.80;
    0.81 0.88 0.91 0.9  0.87 0.82;
    0.8  0.85 0.89 0.88 0.85 0.8;
    0.78 0.82 0.86 0.84 0.8  0.76
];

% Save to Data folder
save('D:\Thesis\Turbofan_DigitalTwin_Thesis\Data/CFM56_Fan_map.mat','speed_vec_fan','flow_vec_fan','Fan_PR_data','Fan_eta_data');
disp("✔ Fan map data saved to Data/CFM56_Fan_map.mat");
