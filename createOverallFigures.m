function createOverallFigures(actual, nominal, beta, Ubeta, result, dataName, phi)
% createOverallFigures - Create summary figures for EIV model fit
%
% This function creates two figures:
%   1. Observed vs. Fitted nominal values with confidence bounds
%   2. (Fitted - Actual) difference plot with confidence bounds
%
% Inputs:
%   actual   - vector of actual measured values (horizontal axis)
%   nominal  - vector of nominal (benchmark) values (vertical axis)
%   beta     - fitted model parameters from OEFPIL
%   Ubeta    - covariance matrix of beta estimates
%   result   - full result structure from OEFPIL fit (mu, nu)
%   dataName - name of the dataset (for titles and saving)
%   phi      - significance level for confidence intervals (default 0.05)

if nargin < 7 || isempty(phi)
    phi = 0.05;  % Default significance level
end

% Pre-compute constants
n_phi = norminv(1 - phi/2);

% Create fine grid of actual values for plotting
xx = linspace(min(actual), max(actual), 101)';
XX = [ones(size(xx)), xx, xx.^2];

% Predicted fitted nominal values and their confidence bounds
yhat = XX * beta;
ci = n_phi * sqrt(sum((XX * Ubeta) .* XX, 2));

mu = result.mu;
nu = result.nu;

%% Figure 1: Observed vs Fitted with Confidence Bounds
figure
hold on
grid on
plot(actual, nominal, '*', 'DisplayName', 'Observed')
plot(mu, nu, 'o', 'DisplayName', 'Fitted')
plot(xx, yhat, 'b-', 'DisplayName', 'Fitted Curve')
plot(xx, yhat - ci, 'r--', 'DisplayName', 'Lower Confidence Bound')
plot(xx, yhat + ci, 'r--', 'DisplayName', 'Upper Confidence Bound')

xlabel('Actual value (mm)')
ylabel('Nominal value (mm)')
title(sprintf('%s - EIV Model: Observed vs Fitted Values', dataName))
legend('Location', 'northwest')
hold off

% Save figure
savefig(sprintf('Fig_%s_Observed_vs_Fitted.fig', dataName));

%% Figure 2: Fitted minus Actual with Confidence Bounds
figure
hold on
grid on
plot(xx, yhat - xx, 'b-', 'DisplayName', 'Fitted - Actual')
plot(xx, yhat - xx - ci, 'r--', 'DisplayName', 'Lower Confidence Bound')
plot(xx, yhat - xx + ci, 'r--', 'DisplayName', 'Upper Confidence Bound')

xlabel('Actual value (mm)')
ylabel('Fitted - Actual (mm)')
title(sprintf('%s - EIV Model: Fitted minus Actual', dataName))
legend('Location', 'northwest')
hold off

% Save figure
savefig(sprintf('Fig_%s_FittedMinusActual.fig', dataName));

end
