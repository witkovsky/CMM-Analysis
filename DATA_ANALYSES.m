%% DATA_ANALYSES.m - Perform calibration data analyses using OEFPIL
%
% This script processes several calibration datasets, fitting a quadratic model 
% to the relationship between actual (measured) and nominal (benchmark) values.
% The fitting uses the OEFPIL algorithm (Optimal Estimation in Functional Problems
% with Independent Linear Constraints) to properly account for uncertainties
% in both the actual and nominal values.
%
% The analysis is based on the procedure described in the paper: 
% "Determination of the Uncertainty of Length Measurement with a
% Three-Coordinate Measuring Device" by Gejza Wimmer, Jakub Palenčár,
% Miroslav Dovica, Rudolf Palenčár, Teodor Tóth, Viktor Witkovský, XXIV
% IMEKO World Congress “Think Metrology”, August 26 - 29, 2024, Hamburg,
% Germany, IMEKO 2024.
%

close all
clear

%% load NEW DATA
load("WIMMER_Ddata_2025.mat")

%% User settings: Significance levels and error bar settings
phi = 0.025;              % Significance level for model confidence intervals (default 0.025)
psi = 0.025;              % Significance level for measurement uncertainty intervals (default 0.025)
ErrorBarSigmaRule = 1;    % Number of sigmas for error bars (default 1)
SixSigmaRule = 10;        % Range multiplier for plotting fine grid (default 10)

%% Define datasets and their display names
datasetNames = {'X_data', 'Y_data', 'Z_data', 'R3D_PL_data', 'R3D_PP_data', ...
                'R3D_ZL_data', 'R3D_ZP_data'};

displayNames = {'X', 'Y', 'Z', 'R3DPL', 'R3DPP', 'R3DZL', 'R3DZP'};

%% Initialize storage for results
results = cell(1, length(datasetNames));

%% Analyze each dataset individually
for idx = 1:length(datasetNames)
    
    % Load dataset
    data = eval(datasetNames{idx});
    
    % Extract raw measured data for possible extensions (currently not used inside makeDataAnalysis)
    % These are the repeated measurements (triplets per position)
    id_row_data = [1:3, 5:7, 9:11, 13:15, 17:19];
    id_col_data = 3:7;
    raw_data = data(id_row_data, id_col_data);

    % Extract 'actual' measured values (average of 3 measurements for each position)
    id_row_actual = [2, 6, 10, 14, 18];  % Use second row of each triplet
    id_col_actual = 8;                   % Column with mean values
    actual = data(id_row_actual, id_col_actual);

    % Extract uncertainties of 'actual' measured values
    id_row_actual_uncertainty = [2, 6, 10, 14, 18];
    id_col_actual_uncertainty = 9;        % Column with standard deviations
    ua = data(id_row_actual_uncertainty, id_col_actual_uncertainty);

    % Extract 'nominal' (benchmark) values
    id_row_nominal = [2, 6, 10, 14, 18];
    id_col_nominal = 2;                   % Column with benchmark values
    nominal = data(id_row_nominal, id_col_nominal);

    % Extract uncertainties of 'nominal' values
    id_row_nominal_uncertainty = [2, 6, 10, 14, 18];
    id_col_nominal_uncertainty = 1;        % Column with uncertainties
    un = data(id_row_nominal_uncertainty, id_col_nominal_uncertainty) / 1000;
    % Note: Divide by 1000 to convert from micrometers (µm) to millimeters (mm)

    % Perform analysis and store result
    results{idx} = makeDataAnalysis(nominal, un, actual, ua, raw_data, ...
                                    displayNames{idx}, ...
                                    phi, psi, ErrorBarSigmaRule, SixSigmaRule);
end
