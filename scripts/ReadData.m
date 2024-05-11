%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Master MATLAB programme file for the SW2020 tolkit by               %%%
%%% Gabriel Ahlfeldt M. Ahlfeldt and Tobias Seidel                      %%%
%%% The toolkit covers a class of quantitative spatial models           %%%
%%% introduced in Monte, Redding, Rossi-Hansberg (2018): Commuting,     %%%
%%% Migration, and Local Employment Elasticities.                       %%%
%%% The toolkit uses data and code compiled for                         %%%
%%% Seidel and Wckerath (2020): Rush hours and urbanization             %%%
%%% Codes and data have been re-organized to make the toolkit more      %%%
%%% accessible. Seval programmes have been added to allow for more      %%%
%%% general applications. Discriptive analyses and counterfactuals      %%%
%%% serve didactic purposes and are unrelated to both research papers   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First version: Gabriel M Ahlfeldt, 05/2024                            %%%
% Based on original code provided by Tobias Seidel                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This script compiles the data                                       %%% 
%%% This script also inverts productivities and computes trade shares   %%%
%%% and the tradable price index                                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read in data
% addpath src/model_code/;
clear;
load('data/output/parameters');
dataComm = 'commuting_wide.csv';                                            %These data contain within-commuting as weighted average
dataHous = 'house_prices.csv';
dataDistance = 'distance_matrix.csv';
dataArea = 'CountyArea.csv';

labor_file = 'labor_tidy.csv';
df = readtable(labor_file);

outVar = 'data/output/modelVar.mat';

% Import commuting data
comMat = csvread(dataComm, 1, 1);
comMat = comMat';
diff = sum(comMat, 2) - sum(comMat', 2);                                    %Check difference between all outcommuters and incommuters
L = sum(comMat, 'all');
uncondCom = comMat ./ L;
condCom = uncondCom./ sum(uncondCom, 2);
%condCom = condCommut(comMat);

% Import wage data
w_n = [df.median_income_workplace];
w_n = w_n ./ mean(w_n);
%v_i = residWage(w_i, condCom);
v_n = condCom * w_n;

% Import employment data
L_n = sum(uncondCom, 1)' * L;
L_n = L_n ./ mean(L_n);
%R_i = residLoc(L_i, uncondCom);
R_n = sum(uncondCom, 2) * L;
R_n = R_n ./ mean(R_n);

% Import house price data
h_price = readtable(dataHous);
h_price = [h_price.rentindex];
lh_price = log(h_price);

% Import distance data and compute trade costs from distances
dist_mat = csvread(dataDistance, 1, 1);
dist_mat = dist_mat/min(dist_mat(:));
dni = dist_mat.^psi;                                                        %Distance elasticity taken from Head/ Mayer, cost elasticity assuming sigma 4 from Broda and Weinstein (2004)

% Import geographic area
Area_n = csvread(dataArea,1,1);

% Define files containing data
nobs = length(L_n);
no_traffic = 'roundtrip_time_base.csv';

% Now read in matrices
baseline = csvread(no_traffic, 1, 1);
baseline = baseline';

% Drop some auxi. variables
clear dataArea dataComm dataDistance dataHous diff labour_file lCommImport_n no_traffic dataHous A_n P_n labor_file uncondComOld

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quantification

% Compute productivities and trade shares 
[A_n,tradesh,tradeshOwn,P_n ] = solveProductTradeTK(L_n, R_n, w_n, v_n, dni);               
 
% Save data
save('data/output/DATAusingSW')

display('<<<<<<<<<<<<<<< Data compilation completed >>>>>>>>>>>>>>>')