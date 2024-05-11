%% Read in data
addpath('../../bld')
addpath(project_paths('IN_MODEL_CODE'))


dataWage = project_paths('OUT_DATA', 'tidy_wage.csv');
dataEmpl = project_paths('OUT_DATA', 'tidy_employment.csv');
dataDist = project_paths('OUT_DATA', 'tidy_distance.csv');
dataComm = project_paths('OUT_DATA', 'tidy_commuting.csv');
dataHous = project_paths('OUT_DATA', 'tidy_land.csv');
dataTradec = project_paths('OUT_ANALYSIS', 'tradecosts.csv');

outVar = project_paths('OUT_ANALYSIS', 'modelVar.mat');

% Import commuting data
comMat = csvread(dataComm, 1, 1);
condCom = condCommut(comMat);
uncondCom = comMat ./ sum(comMat(:));

% Import wage data
wage = readtable(dataWage);
w_i = [wage.wage_i];
w_i = w_i ./ max(w_i);
v_n = residWage(w_i, condCom);

% Import employment data
empl = readtable(dataEmpl);
L_i = [empl.region_employ];
L_i = L_i ./ mean(L_i);
R_n = residLoc(L_i, condCom);

% Import house price data
h_price = csvread(dataHous, 1, 2);

% Import distance data and compute trade costs from distances
trade_mat = csvread(dataTradec, 1, 1);
% trade_mat = ones(length(w_i));
dist_mat = csvread(dataDist, 1, 1);
%% Productivity solution
sigg = 4;
fixC = 1;
alp = 0.6;
epps = 2.3;

A_i = solveProduct(L_i, R_n, w_i, v_n, trade_mat, sigg);
A_i = A_i ./ max(A_i) .* 100;

% Compute tradeshares consistent with productivities
tradesh = getTradeshares(A_i, L_i, w_i, trade_mat, sigg);

% Compute prices consistent with tradeshares
c_price = getPrices(L_i, tradesh, trade_mat, w_i, A_i, sigg, fixC);

% Solve for matrix of bilateral amenities
% B_ni = solveAmenities(uncondCom, c_price, h_price, w_i, epps, alp);

% Compute vector of pollution contributions
eCn = getPollution(R_n, condCom, dist_mat, 1);
eTotal = sum(eCn);

% Save model generated variables
save(outVar, 'v_n', 'R_n', 'A_i', 'w_i', 'uncondCom', 'L_i', 'tradesh', ...
    'eCn', 'eTotal', 'dist_mat', 'epps', 'sigg', 'alp');