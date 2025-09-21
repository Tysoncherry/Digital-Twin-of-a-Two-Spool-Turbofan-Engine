Simulink Digital Twin of a Two-Spool Turbofan Engine
Overview

This repository contains the MATLAB/Simulink models, JSON metadata, and example datasets developed for the Master’s thesis
“Simulink-Based Digital Twin of a Two-Spool Turbofan Engine Using Product Data for Predictive Maintenance.”
The project builds a physics-based digital twin of a CFM56-class high-bypass turbofan, integrates a Product Data Management (PDM) layer, supports fault injection, and demonstrates machine-learning-based predictive maintenance.

Features

Modular Simulink/Simscape model of fan, LPC, HPC, combustion chamber, turbines, and dual nozzles.

JSON-driven PDM layer for component versions, install dates, cycle counts, and efficiency modifiers.

Mission-phase logic (take-off, climb, cruise, descent, landing) with automatic phase detection.

Fault injection (e.g., fan degradation, HPC stall, combustor flameout, HPT cooling loss).

Dataset generation and ML classifiers (Decision Tree & Random Forest) for “Go/No-Go” engine readiness.

Repository Layout
├─ /SimulinkModel      # .slx files and referenced subsystems
├─ /JSON_Metadata      # Example product-data JSON schemas
├─ /Datasets           # Generated CSVs for ML training/testing
├─ /ML_Models          # MATLAB scripts for Decision Tree / Random Forest
└─ README.md

Requirements

MATLAB R2023b or later

Simulink + Simscape + Simscape Driveline

Statistics and Machine Learning Toolbox

(Optional) GasTurb maps for alternative engine data

Quick Start

Clone this repo and open DigitalTwin.slx in MATLAB.

Run init_metadata.m to load sample JSON PDM data.

Click Run in Simulink to start the base simulation.

To inject faults, edit parameters in FaultManager.m or use the GUI block.

Use generate_dataset.m to produce training data and run train_RF.m for the Random Forest example.

Reproducing Thesis Results

Validation & Verification: Follow Section 4 of the thesis for solver settings and reference conditions.

Machine Learning: See /ML_Models/ for scripts to reproduce the 96 % Random Forest accuracy.

Citation

If you use this work, please cite:

Ram Charan Vuyyala, Simulink-Based Digital Twin of a Two-Spool Turbofan Engine Using Product Data for Predictive Maintenance, Master’s Thesis, Schmalkalden University of Applied Sciences, 2025.
