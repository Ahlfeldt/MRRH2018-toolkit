%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Master MATLAB programme file for the MRRH2018 tolkit by             %%%
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
%%% This script modifies the original Seidel and Wickerath dataset to   %%% 
%%% to become consistent with arbitrary commuting cost matrices         %%%
%%% The original data has missing flows on many long bilateral routes   %%%
%%% This will be inconsistent with a standard travel cost matrix        %%%
%%% Also, often the original apporach is not implementable since data   %%%
%%% on bilateral commuting flows is not accessibile                     %%%
%%% In both cases, this script can be used to faciliate the analysis    %%%
%%% This script also inverts productivities and computes trade shares   %%%
%%% and the tradable price index                                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
load('data/output/parameters');
% Read in your matrices; 
dataDistance = 'distance_matrix.csv';
dataComm = 'commuting_wide.csv';           
dist_mat = csvread(dataDistance, 1, 1);
dist_mat = dist_mat./1000; %  
dni = (dist_mat./min(dist_mat(:))).^psi;                                    % Distance elasticity taken from Head/ Mayer, cost elasticity assuming sigma 4 from Broda and Weinstein (2004)
                                                                            % Replace with your distance measure!

% We use a simple SL distance matrix for commuting cost tau
baseline = dist_mat;                                                        % We use SL distance to proxy for commuting distance
                                                                            % Replace with your commuting cost matrix!

% If applicable, add matrices of relative changes in trade and 
% commuting cost matrices here                                                                            

% Read employment: Replace with your employment at workplace and residence
dataComm = 'commuting_wide.csv';                                            %These data contain within-commuting as weighted average
comMat = csvread(dataComm, 1, 1);
comMat = comMat';
L = sum(comMat, 'all');
uncondCom = comMat ./ L;
% Compute employment data
L_n = sum(uncondCom, 1)' * L;
L_n = L_n ./ mean(L_n);
R_n = sum(uncondCom, 2) * L;
R_n = R_n ./ mean(R_n);

% Read wages: Replace with your wages
labor_file = 'labor_tidy.csv';
df = readtable(labor_file);
w_n = [df.median_income_workplace];
w_n = w_n ./ mean(w_n);

% Import house price data
dataHous = 'house_prices.csv';
h_price = readtable(dataHous);
h_price = [h_price.rentindex];

% Import geographic area
dataArea = 'CountyArea.csv';
Area_n = csvread(dataArea,1,1);

% Create a workplace amenity to rationalize commuting flows for matrix
[L_n,condCom,B_i,uncondCom,comMat]= getBiTK(w_n, baseline, R_n, L_n, L);                            % Original workplace employment and commuting probability are being rewritten
% Notice that IF WAGES ARE NOT AVAILABLE, B_i has an isomorphic
% interpretation as transformed wage omega (see ARSW2015). It can be used
% to recover w_n for a given epsi. To this end, simply enter a w_n vegtor
% ones, run the solver and recover wages as w_n = B_i.^(1./epsi)

% Compute expected wage at residence
v_n = condCom * w_n;                                                        % Replacing original data

% Invert productivity
[A_n,tradesh,tradeshOwn,P_n ] = solveProductTradeTK(L_n, R_n, w_n, v_n, dni);               

% Clear old object that do not belong after update of data 
clear dataArea dataComm dataDistance dataHous diff labour_file lCommImport_n no_traffic dataHous labor_file uncondComOld

save('data/output/DATAusingSW')

display('<<<<<<<<<<<<<<< Data compilation completed >>>>>>>>>>>>>>>')