function createCalibratedMeasurementMinusXFigure(actual, ua, beta, Ubeta, dataName, phi, psi, SixSigmaRule)
% createCalibratedMeasurementMinusXFigure - Plot (fitted - actual) including calibrated uncertainty
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

% Settings
sigx = 0.0008;  % standard deviation of device measuring capability

n_phi = norminv(1 - phi/2);
n_psi = norminv(1 - psi/2);

% Select representative point (middle point)
pointid = round(length(actual)/2);

% Define grid around selected actual value
xx = linspace(actual(pointid) - SixSigmaRule * ua(pointid), ...
              actual(pointid) + SixSigmaRule * ua(pointid), 101)';
XX = [ones(size(xx)), xx, xx.^2];

% Fit nominal values
yhat = XX * beta;

% Shift grid by ± uncertainty
xx_minus = xx - n_psi * sigx;
XX_minus = [ones(size(xx_minus)), xx_minus, xx_minus.^2];
yhat_minus = XX_minus * beta;
ci_minus = n_phi * sqrt(sum((XX_minus * Ubeta) .* XX_minus, 2));

xx_plus = xx + n_psi * sigx;
XX_plus = [ones(size(xx_plus)), xx_plus, xx_plus.^2];
yhat_plus = XX_plus * beta;
ci_plus = n_phi * sqrt(sum((XX_plus * Ubeta) .* XX_plus, 2));

%% Create the figure
figure
hold on
grid on
%plot(xx, yhat - xx, 'b-', 'DisplayName', 'Fitted - Actual')
plot(xx, yhat_minus - xx - ci_minus, 'k--', 'DisplayName', 'Lower Bound (Shifted -)')
plot(xx, yhat_plus - xx + ci_plus, 'k--', 'DisplayName', 'Upper Bound (Shifted +)')

xlabel('Actual value (mm)')
ylabel('Deviation (mm)')
%title(sprintf('%s - Calibrated Measurement (Fitted - Actual)', dataName))
legend('Location', 'northwest')
hold off

% Save figure
savefig(sprintf('Fig_%s_CalibratedMeasurementMinusX.fig', dataName));

end