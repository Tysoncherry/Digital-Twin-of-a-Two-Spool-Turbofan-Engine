% ----- read_CFM56_designPoint.m -----
% This script sets up the design‐point parameters for CFM56-7B
% Source: Martins (2014) "Off-Design Performance Prediction of the CFM56-7B"

% 1) HPC design
Wc_HPC_design   = 52.3;    % kg/s
PR_HPC_design   = 12.4;    % Total pressure ratio
eta_HPC_design  = 0.88;    % Isentropic efficiency
N2_design       = 10500;   % rpm

% 2) HPT design (at N2_design)
Wt_HPT_design   = Wc_HPC_design; 
PR_HPT_design   = 3.6;     % for one stage or combined
eta_HPT_design  = 0.89;
% (Note: HPT design flow and PR use same Wc as HPC at design, since mass is same)
% If there are multiple LPT/HPT stages, split as needed.

% 3) LPC design (on N1 spool)
Wc_LPC_design   = 130;     % kg/s
PR_LPC_design   = 3.2;
eta_LPC_design  = 0.85;
N1_design       = 8000;    % rpm

% 4) LPT design (on N1 spool)
Wt_LPT_design   = Wc_LPC_design; 
PR_LPT_design   = 1.8;
eta_LPT_design  = 0.87;

% 5) Fan design (on N1 spool)
Wc_fan_design   = 180;     % kg/s (core + bypass)
PR_fan_design   = 1.5;
eta_fan_design  = 0.82;
BPR_design      = 5.0;     % bypass ratio

% 6) Global conditions
P_ambient       = 101325;  % Pa
T_ambient       = 288.15;  % K

% 7) Save to MAT-file
save('D:\Thesis\Turbofan_DigitalTwin_Thesis\Data/CFM56_DesignPoint.mat', ...
    'Wc_HPC_design','PR_HPC_design','eta_HPC_design','N2_design', ...
    'Wt_HPT_design','PR_HPT_design','eta_HPT_design', ...
    'Wc_LPC_design','PR_LPC_design','eta_LPC_design','N1_design', ...
    'Wt_LPT_design','PR_LPT_design','eta_LPT_design', ...
    'Wc_fan_design','PR_fan_design','eta_fan_design','BPR_design', ...
    'P_ambient','T_ambient');
