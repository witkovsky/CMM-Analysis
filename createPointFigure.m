function createPointFigure(pointid, actual, nominal, mu, nu, beta, Ubeta, ua, un, dataName, phi, ErrorBarSigmaRule, SixSigmaRule)
% createPointFigure - Helper function to plot and save figure for a single point
%
% Inputs:
%   pointid           - index of the measured point
%   actual            - vector of actual measured values
%   nominal           - vector of nominal benchmark values
%   mu, nu            - fitted values after OEFPIL
%   beta, Ubeta       - estimated model parameters and their covariance
%   ua, un            - uncertainties of actual and nominal measurements
%   dataName          - name of the dataset (for labeling and saving)
%   phi               - significance level for confidence intervals
%   ErrorBarSigmaRule - number of sigmas for error bars
%   SixSigmaRule      - neighborhood multiplier for plotting

n_phi = norminv(1 - phi/2);

% Create fine grid around the actual value
xx = linspace(actual(pointid) - SixSigmaRule * ua(pointid), ...
              actual(pointid) + SixSigmaRule * ua(pointid), 101)';
XX = [ones(size(xx)), xx, xx.^2];

% Predicted values and confidence intervals
yhat = XX * beta;
ci = n_phi * sqrt(sum((XX * Ubeta) .* XX, 2));

% Plot
figure
hold on
grid on
plot(actual(pointid), nominal(pointid), '*', 'DisplayName', 'Observed')
plot(mu(pointid), nu(pointid), 'o', 'DisplayName', 'Fitted')
plot(xx, yhat, '-', 'DisplayName', 'Fitted Line')
plot(xx, yhat - ci, 'r--', 'DisplayName', 'Lower Bound')
plot(xx, yhat + ci, 'r--', 'DisplayName', 'Upper Bound')

% Error bars
errorbar(actual(pointid), nominal(pointid), ...
    ErrorBarSigmaRule * un(pointid), ErrorBarSigmaRule * un(pointid), ...
    ErrorBarSigmaRule * ua(pointid), ErrorBarSigmaRule * ua(pointid), ...
    ':', 'DisplayName', 'Standard Errors')

xlabel('Actual value (mm)')
ylabel('Nominal value (mm)')
title(sprintf('%s - Point %d: Observed vs. Fitted Value', dataName, pointid))
legend('Location', 'northwest')
hold off

% Save figure
figureName = sprintf('Fig_%s_Point%d.fig', dataName, pointid);
savefig(figureName);

end