function createExamplePoint4ConfidenceRegionC(actual, ua, beta, Ubeta, dataName, phi, psi, SixSigmaRule)
% createExamplePoint4ConfidenceRegionC - Plot (fitted - actual) differences and Region C
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

% Grid across full actual range
xx = linspace(min(actual), max(actual), 101)';
XX = [ones(size(xx)), xx, xx.^2];

% Main prediction
yhat = XX * beta;

% Shifted grids for device uncertainty
xx_minus = xx - n_psi * sigx;
XX_minus = [ones(size(xx_minus)), xx_minus, xx_minus.^2];
yhat_minus = XX_minus * beta;
ci_minus = n_phi * sqrt(sum((XX_minus * Ubeta) .* XX_minus, 2));

xx_plus = xx + n_psi * sigx;
XX_plus = [ones(size(xx_plus)), xx_plus, xx_plus.^2];
yhat_plus = XX_plus * beta;
ci_plus = n_phi * sqrt(sum((XX_plus * Ubeta) .* XX_plus, 2));

% External tolerance (Region C bounds)
MPE_plus = (1.8 + 3.33 * xx / 1000) / 1000;
MPE_minus = -(1.8 + 3.33 * xx / 1000) / 1000;

% Plot
figure
hold on
grid on
plot(xx, yhat - xx, 'b-', 'DisplayName', 'Fitted - Actual')
plot(xx, yhat_minus - xx - ci_minus, 'k--', 'DisplayName', 'Lower Bound C')
plot
