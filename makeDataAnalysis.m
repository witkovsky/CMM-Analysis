function result = makeDataAnalysis(nominal, un, actual, ua, data, dataName, phi, psi, ErrorBarSigmaRule, SixSigmaRule)
% makeDataAnalysis - Analyze calibration data using OEFPIL fitting and create diagnostic plots
%
% ... (description stays same)

% Set default parameters if missing
if nargin < 10 || isempty(SixSigmaRule), SixSigmaRule = 10; end
if nargin < 9 || isempty(ErrorBarSigmaRule), ErrorBarSigmaRule = 1; end
if nargin < 8 || isempty(psi), psi = 0.025; end
if nargin < 7 || isempty(phi), phi = 0.025; end

%% Step 1: Define the model function
fun = @(mu, nu, beta) beta(1) + beta(2).*mu + beta(3).*mu.^2 - nu;

%% Step 2: Set up the uncertainty matrices
q = length(actual);
idq = 1:q;
U = {
    sparse(idq, idq, ua.^2),
    sparse(idq, idq, un.^2),
    []
};

%% Step 3: Perform OEFPIL fit
mu0 = actual;
nu0 = nominal;
beta0 = [1; 1; 1];

options.method = 'oefpilrs2';
options.tol = 1e-14;
options.isPlot = false;

result = OEFPIL2D(actual, nominal, U, fun, mu0, nu0, beta0, options);

mu = result.mu;
nu = result.nu;
beta = result.beta;
Ubeta = result.Ubeta;

%% Step 4: Create individual figures for each measured point
for pointid = 1:q
    createPointFigure(pointid, actual, nominal, mu, nu, beta, Ubeta, ua, un, dataName, phi, ErrorBarSigmaRule, SixSigmaRule)
end

%% Step 5: Create overall model fit figures
createOverallFigures(actual, nominal, beta, Ubeta, result, dataName, phi)

%% Step 6: Create calibrated device measurement figure
createCalibratedMeasurementFigure(actual, ua, beta, Ubeta, dataName, phi, psi, SixSigmaRule)

%% Step 7: Create calibrated device measurement (Fitted - Actual) figure
createCalibratedMeasurementMinusXFigure(actual, ua, beta, Ubeta, dataName, phi, psi, SixSigmaRule)

%% Step 8: Create Region D figure
createRegionDFigure(actual, ua, beta, Ubeta, dataName, phi, psi, SixSigmaRule)

%% Step 9: Create Example Figure for Point 3
createExamplePoint3ConfidenceBounds(actual, ua, beta, Ubeta, dataName, phi, SixSigmaRule)

%% Step 10: Create Example Figure for Point 4
createExamplePoint4ConfidenceRegionC(actual, ua, beta, Ubeta, dataName, phi, psi, SixSigmaRule)

end
