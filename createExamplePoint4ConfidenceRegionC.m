function createExamplePoint4ConfidenceRegionC(actual, ua, beta, Ubeta, dataName, phi, psi, SixSigmaRule)
% createExamplePoint4ConfidenceRegionC - Plot (fitted - actual) differences and Region C with full detail
%
% Inputs:
%   actual      - vector of actual measured values
%   ua          - standard uncertainties of actual measurements
%   beta        - fitted model parameters
%   Ubeta       - covariance matrix of beta estimates
%   dataName    - name of the dataset (for labeling and saving)
%   phi         - significance level for model confidence intervals
%   psi         - significance level for measurement uncertainty intervals
%   SixSigmaRule- range multiplier for plotting around actual values

if nargin < 7 || isempty(SixSigmaRule)
    SixSigmaRule = 10;
end
if nargin < 6 || isempty(psi)
    psi = 0.025;
end
if nargin < 5 || isempty(phi)
    phi = 0.025;
end

pointid = 4;
sigx = 0.0008;  % standard deviation of device measurement capability

n_phi = norminv(1 - phi/2);
n_psi = norminv(1 - psi/2);

% Grid across the full range of actual values
xx = linspace(min(actual), max(actual), 101)';
XX = [ones(size(xx)), xx, xx.^2];

% Main fitted prediction
yhat = XX * beta;

% Shifted grids considering uncertainty
xx_minus = xx - n_psi * sigx;
XX_minus = [ones(size(xx_minus)), xx_minus, xx_minus.^2];
yhat_minus = XX_minus * beta;
ci_minus = n_phi * sqrt(sum((XX_minus * Ubeta) .* XX_minus, 2));

xx_plus = xx + n_psi * sigx;
XX_plus = [ones(size(xx_plus)), xx_plus, xx_plus.^2];
yhat_plus = XX_plus * beta;
ci_plus = n_phi * sqrt(sum((XX_plus * Ubeta) .* XX_plus, 2));

% External tolerance lines (Region C limits)
regionC_upper = (1.8 + 3.33 * xx / 1000) / 1000;
regionC_lower = (-1.8 - 3.33 * xx / 1000) / 1000;

%% Plot
figure
hold on
grid on

% Main (fitted - actual) line
plot(xx, yhat - xx, 'b-', 'DisplayName', 'Fitted - Actual')

% Confidence bounds with device uncertainty
plot(xx, yhat_minus - ci_minus - xx, 'k--', 'DisplayName', 'Lower Bound C')
plot(xx, yhat_plus + ci_plus - xx, 'k--', 'DisplayName', 'Upper Bound C')

% Region C tolerance limits
plot(xx, regionC_upper, 'm--', 'DisplayName', '+Region C Limit')
plot(xx, regionC_lower, 'm--', 'DisplayName', '-Region C Limit')

xlabel('x (mm)')
ylabel('y - x (mm)')
title(sprintf('%s - Confidence Region C', dataName))
legend('Location', 'northwest')
hold off

% Save figure
savefig(sprintf('Fig_%s_Point%d_ConfidenceRegionC.fig', dataName, pointid));

end
