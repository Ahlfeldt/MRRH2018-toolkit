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
%%% This script executes some descriptive exercises                     %%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
load('data/output/DATAusingSW')

% Compute densities
EmpDensity_n = L_n./Area_n;
lEmpDensity_n = log(L_n)-log(Area_n);
PopDensity_n = R_n./Area_n;
lPopDensity_n = log(R_n)-log(Area_n);
lCommImport_n = log(L_n)-log(R_n);

% Map some input data
RESULT = MAPIT('shape/VG250_KRS_clean_final',lEmpDensity_n,'Log employment density','figs','MAP_EmpDensity') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',lPopDensity_n,'Log population density','figs','MAP_PopDensity') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',lCommImport_n,'Log commuting import','figs','MAP_CommImport') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',h_price,'House price','figs','MAP_HousePrice') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',w_n,'Wage','figs','MAP_Wage') 

% Check distances
avDist = mean(dist_mat, 2);
RESULT = MAPIT('shape/VG250_KRS_clean_final',avDist,'Average distance to other counties','figs','MAP_AvDist') 
% Distances looks sensible

% Correlate commuting probabilities with distance %%%%%%%%%%%%%%%%%%%%%%%%%
clf;
scatter(log(dist_mat), log(comMat));
xlabel('Distance (log)'); % Label x-axis
ylabel('Commuting probability (log)'); % Label y-axis
title('Commuting probability, log-log model'); % Title for the plot
grid on; % Optionally, turn the grid on for easier visualization
print('figs/Scatter_Lambda_log_log', '-dpng', '-r300');
clf;
scatter((dist_mat), log(comMat));
xlabel('Distance (km)'); % Label x-axis
ylabel('Commuting probability (log)'); % Label y-axis
title('Commuting probability, log-lin model'); % Title for the plot
grid on; % Optionally, turn the grid on for easier visualization
print('figs/Scatter_Lambda_log_lin', '-dpng', '-r300');

% Simple bivariate regressions to get slopes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Flatten the matrices into vectors
dist_mat_vec = reshape(dist_mat, [], 1);
comMat_vec = reshape(comMat, [], 1);
log_dist_mat = log(dist_mat_vec);
log_comMat = log(comMat_vec);
% Filtering for positive values in log_comMat
positive_idx = log_comMat > 0;
filtered_log_comMat = log_comMat(positive_idx);
filtered_log_dist_mat = log_dist_mat(positive_idx);
% for the log log model
X_filtered = [ones(size(filtered_log_dist_mat)), filtered_log_dist_mat];
[b, bint, r, rint, stats] = regress(filtered_log_comMat, X_filtered);
slope = b(2);  % Access the second row, first column
disp(['The slope of the regression is: ', num2str(slope)]);

% For the log-lin model 
filtered_dist_mat = dist_mat(positive_idx);
X_filtered = [ones(size(filtered_dist_mat)), filtered_dist_mat];
[b, bint, r, rint, stats] = regress(filtered_log_comMat, X_filtered);
slope = b(2);  % Access the second row, first column
disp(['The slope of the regression is: ', num2str(slope)]);

% Fixed effects regressions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

comMat_vec = reshape(comMat, [], 1);
dist_mat_vec = reshape(dist_mat, [], 1);

% Ensuring all entries are positive before taking logs
positive_idx = comMat_vec > 0;  % Index of positive values in comMat
log_comMat_vec = log(comMat_vec(positive_idx));
log_dist_mat_vec = log(dist_mat_vec(positive_idx));
dist_mat_vec = (dist_mat_vec(positive_idx));

n = size(dist_mat, 1);  % Assuming dist_mat is 401x401
[row_indices, col_indices] = find(reshape(positive_idx, n, n));  % Find row and column indices of positive entries

% Generate dummy variables
origin_dummies = dummyvar(row_indices);
destination_dummies = dummyvar(col_indices);

% Remove the first column to avoid multicollinearity
origin_dummies(:, 1) = [];
destination_dummies(:, 1) = [];

X = [ones(length(log_dist_mat_vec), 1), log_dist_mat_vec, origin_dummies, destination_dummies];

% Assuming the Statistics and Machine Learning Toolbox is available
[b, bint, r, rint, stats] = regress(log_comMat_vec, X);
slope = b(2);  % Access the second row, first column
disp(['The slope of the regression is: ', num2str(slope)]);

% For log-lin model
X = [ones(length(dist_mat_vec), 1), dist_mat_vec, origin_dummies, destination_dummies];
[b, bint, r, rint, stats] = regress(log_comMat_vec, X);
Comm_slope = b(2);  % Access the second row, first column
disp(['The slope of the regression is: ', num2str(Comm_slope)]);
% Slightly larger effect on 

% And now only recover the residuals
X = [ones(length(dist_mat_vec), 1), origin_dummies, destination_dummies];
[b, bint, r, rint, stats] = regress(log_comMat_vec, X);
clf;
scatter(dist_mat_vec, log_comMat_vec);
xlabel('Distance (log)'); % Label x-axis
ylabel('Commuting probability (log)'); % Label y-axis
title('Commuting probability, log-log model'); % Title for the plot
grid on; % Optionally, turn the grid on for easier visualization

% Compute commuter market access
omega_n = w_n.^epsi; 
CommWeight_ni = dist_mat.^(-mu.*epsi);
CMA_n = CommWeight_ni*omega_n;
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(CMA_n),'Log commuting market access','figs','MAP_CMA') 
EmpPot_n = CommWeight_ni*L_n;
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(EmpPot_n),'Log employment potential','figs','EmpPot') 

% Map productivities 
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(A_n),'Log productivity','figs','MAP_A') 
clf;
scatter(log(A_n), log(w_n));
xlabel('Log productivity A'); % Label x-axis
ylabel('Log wage w'); % Label y-axis
title('Productivity vs. wage'); % Title for the plot
grid on; % Optionally, turn the grid on for easier visualization
print('figs/Scatter_A_w', '-dpng', '-r300');

% Map trade shares and price index
RESULT = MAPIT('shape/VG250_KRS_clean_final',tradeshOwn,'Own trade share','figs','MAP_pi_nn') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',P_n,'Tradables price index','figs','MAP_P_n') 

display('<<<<<<<<<<<<<<< Descriptive analysis completed >>>>>>>>>>>>>>>')