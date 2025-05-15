function createExamplePoint3ConfidenceBounds(actual, ua, beta, Ubeta, dataName, phi, SixSigmaRule)
% createExamplePoint3ConfidenceBounds - Plot fitted line with confidence bounds at Point 3
%
% Inputs:
%   actual      - vector of actual measured values
%   ua          - standard uncertainties of actual measurements
%   beta        - fitted model parameters
%   Ubeta       - covariance matrix of beta estimates
%   dataName    - name of the dataset (for labeling and saving)
%   phi         - significance level for model confidence intervals
%   SixSigmaRule- range multiplier for plotting around actual values

if nargin < 6 || isempty(SixSigmaRule)
    SixSigmaRule = 10;
end
if nargin < 5 || isempty(phi)
    phi = 0.025;
end

pointid = 3;

n_phi = norminv(1 - phi/2);

% Fine grid around selected actual value
xx = linspace(actual(pointid) - SixSigmaRule * ua(pointid), ...
              actual(pointid) + SixSigmaRule * ua(pointid), 101)';
XX = [ones(size(xx)), xx, xx.^2];

% Prediction and confidence bounds
yhat = XX * beta;
ci = n_phi * sqrt(sum((XX * Ubeta) .* XX, 2));

% Plot
figure
hold on
grid on
plot(xx, yhat, 'b-', 'DisplayName', 'Fitted Line')
plot(xx, yhat - ci, 'r--', 'DisplayName', 'Lower Bound')
plot(xx, yhat + ci, 'r--', 'DisplayName', 'Upper Bound')

xlabel('Actual value (mm)')
ylabel('Benchmark value (mm)')
%title(sprintf('%s - Point %d: Observed vs. Fitted Value', dataName, pointid))
legend('Location', 'northwest')
hold off

% Save figure
savefig(sprintf('Fig_%s_Point%d_ConfidenceBounds.fig', dataName, pointid));

end
