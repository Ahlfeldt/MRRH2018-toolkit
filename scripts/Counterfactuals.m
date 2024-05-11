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
%%% This script executes a series of counterfactuals in which we        %%% 
%%% similate the effects of a hypothetical border that follows the      %%%
%%% the border between formerly separated West Germany and East GErmany %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a trade border between East and West Germany

% Load data
load('data/output/DATAusingSWborder')

% Primitives that do not change => Changes are set to ones
aChange = ones(J, 1);
bChange = ones(J);
dChange = ones(J);
kapChange = ones(J,J);

% Set border cost in trade to large value
dChange(conditionMatrix) = 1000;

% Solve for counterfactual values
[wChange, vChange, qChange, piChange, lamChange, pChange, rChange, ...
    lChange, welfChange] = counterFactsTK(...
        aChange, bChange, kapChange, dChange, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh);

% Map findings
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(qChange),'Relative change in house price; trade border','figs','MAP_COUNT_BORDER_TRADE_Qchange') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(pChange),'Relative change in tradable goods price; trade border','figs','MAP_COUNT_BORDER_TRADE_Pchange') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(rChange),'Relative change in population; trade border','figs','MAP_COUNT_BORDER_TRADE_Rchange') 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a commuting border between East and West Germany

% Load data
load('data/output/DATAusingSWborder')

% Primitives that do not change => Changes are set to ones
aChange = ones(J, 1);
bChange = ones(J);
dChange = ones(J);
kapChange = ones(J,J);

% Set border cost in commuting to large value
kapChange(conditionMatrix) = 1000;

% Solve for counterfactual values
[wChange, vChange, qChange, piChange, lamChange, pChange, rChange, ...
    lChange, welfChange] = counterFactsTK(...
        aChange, bChange, kapChange, dChange, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh);

% Map findings
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(qChange),'Relative change in house price; commuting border','figs','MAP_COUNT_BORDER_COMM_Qchange') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(pChange),'Relative change in tradable goods price; commuting border','figs','MAP_COUNT_BORDER_COMM_Pchange') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(rChange),'Relative change in population; commuting border','figs','MAP_COUNT_BORDER_COMM_Rchange') 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a commuting and trade border between East and West Germany

% Load data
load('data/output/DATAusingSWborder')

% Primitives that do not change => Changes are set to ones
aChange = ones(J, 1);
bChange = ones(J);
dChange = ones(J);
kapChange = ones(J,J);

% Set border cost in commuting and trade to large value
kapChange(conditionMatrix) = 1000;
dChange(conditionMatrix) = 1000;

% Solve for counterfactual values
[wChange, vChange, qChange, piChange, lamChange, pChange, rChange, ...
    lChange, welfChange] = counterFactsTK(...
        aChange, bChange, kapChange, dChange, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh);

% Map findings
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(qChange),'Relative change in house price; trade & commuting border','figs','MAP_COUNT_BORDER_COMMTRADE_Qchange') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(pChange),'Relative change in tradable goods price; trade & commuting border','figs','MAP_COUNT_BORDER_COMMTRADE_Pchange') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(rChange),'Relative change in population; trade & commuting border','figs','MAP_COUNT_BORDER_COMMTRADE_Rchange') 

% Scatter plot of goods market impact %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure; % Create a new figure window
scatter(BorderDist_n, log(qChange), 'o', 'LineWidth', 1.5, 'DisplayName', 'Housing'); % Scatter plot of BorderDist_n vs. qChange
hold on; % Hold on to add more plots to the current figure
scatter(BorderDist_n, log(pChange), 's', 'LineWidth', 1.5, 'DisplayName', 'Tradable goods'); % Scatter plot of BorderDist_n vs. pChange
xline(0, 'k', 'LineWidth', 2, 'HandleVisibility', 'off'); % Add a vertical black line at BorderDist_n = 0, excluded from legend
yline(0, 'k', 'LineWidth', 2, 'HandleVisibility', 'off'); % Add a vertical black line at BorderDist_n = 0, excluded from legend
hold off; % Release the hold to prevent more additions to this figure

xlabel('Border Distance (km)'); % Label for the x-axis
ylabel('Log change in prices'); % General label for the y-axis
title('Effects of introducing a domestic border'); % Title for the plot
legend('show', 'Location', 'southwest'); % Display a legend to identify qChange and pChange in the bottom left corner
grid on; % Add grid lines to make reading the plot easier

% Save the figure
% Define the folder and filename
folder = 'figs';
filename = 'scatter_COUNT_BORDER_COMMTRADE_PriceChanges.png';
fullpath = fullfile(folder, filename); % Create the full file path
print(fullpath, '-dpng', '-r300'); % Save the plot as a PNG file with 300 dpi

% Scatter plot of labour market impact %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure; % Create a new figure window
scatter(BorderDist_n, log(wChange), 'o', 'LineWidth', 1.5, 'DisplayName', 'Wage'); % Scatter plot of BorderDist_n vs. wChange
hold on; % Hold on to add more plots to the current figure
scatter(BorderDist_n, log(lChange), 's', 'LineWidth', 1.5, 'DisplayName', 'Employment'); % Scatter plot of BorderDist_n vs. lChange
xline(0, 'k', 'LineWidth', 2, 'HandleVisibility', 'off'); % Add a vertical black line at BorderDist_n = 0, excluded from legend
hold off; % Release the hold to prevent more additions to this figure

xlabel('Border Distance (km)'); % Label for the x-axis
ylabel('Log change'); % General label for the y-axis
title('Scatter Plot of Changes vs. BorderDist_n'); % Title for the plot
legend('show', 'Location', 'southwest'); % Display a legend in the bottom left corner
grid on; % Add grid lines to make reading the plot easier

% Define the folder and filename
folder = 'figs';
filename = 'scatter_COUNT_BORDER_COMMTRADE_LabourChanges.png'; % Change filename to reflect new variables
fullpath = fullfile(folder, filename); % Create the full file path

% Ensure the directory exists, create it if it does not
if ~exist(folder, 'dir')
    mkdir(folder);
end

% Save the figure
print(fullpath, '-dpng', '-r300'); % Save the plot as a PNG file with 300 dpi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now repeat with half the trade cost
global psi 
psi = 0.21;
save('data/output/parameters')

% Recompile data with new parameter value
OwnData
BorderData

% Load data
load('data/output/DATAusingSWborder')

% Primitives that do not change => Changes are set to ones
aChange = ones(J, 1);
bChange = ones(J);
dChange = ones(J);
kapChange = ones(J,J);

% Set border cost in commuting and trade to large value
kapChange(conditionMatrix) = 1000;
dChange(conditionMatrix) = 1000;

% Solve for counterfactual values
[wChange, vChange, qChange, piChange, lamChange, pChange, rChange, ...
    lChange, welfChange] = counterFactsTK(...
        aChange, bChange, kapChange, dChange, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh);

% Map findings
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(qChange),'Relative change in house price; trade & commuting border','figs','MAP_COUNT_BORDER_COMMTRADE_Qchange_lowTradeCost') 
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(pChange),'Relative change in tradable goods price; trade & commuting border','figs','MAP_COUNT_BORDER_COMMTRADE_Pchange_lowTradeCost')
RESULT = MAPIT('shape/VG250_KRS_clean_final',log(rChange),'Relative change in population; trade & commuting border','figs','MAP_COUNT_BORDER_COMMTRADE_Rchange_lowTradeCost')

% Scatter plot of goods market impact %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure; % Create a new figure window
scatter(BorderDist_n, log(qChange), 'o', 'LineWidth', 1.5, 'DisplayName', 'Housing'); % Scatter plot of BorderDist_n vs. qChange
hold on; % Hold on to add more plots to the current figure
scatter(BorderDist_n, log(pChange), 's', 'LineWidth', 1.5, 'DisplayName', 'Tradable goods'); % Scatter plot of BorderDist_n vs. pChange
xline(0, 'k', 'LineWidth', 2, 'HandleVisibility', 'off'); % Add a vertical black line at BorderDist_n = 0, excluded from legend
yline(0, 'k', 'LineWidth', 2, 'HandleVisibility', 'off'); % Add a vertical black line at BorderDist_n = 0, excluded from legend
hold off; % Release the hold to prevent more additions to this figure

xlabel('Border Distance (km)'); % Label for the x-axis
ylabel('Log change in prices'); % General label for the y-axis
title('Effects of introducing a domestic border'); % Title for the plot
legend('show', 'Location', 'southwest'); % Display a legend to identify qChange and pChange in the bottom left corner
grid on; % Add grid lines to make reading the plot easier

% Save the figure
% Define the folder and filename
folder = 'figs';
filename = 'scatter_COUNT_BORDER_COMMTRADE_PriceChanges_lowTradeCost.png';
fullpath = fullfile(folder, filename); % Create the full file path
print(fullpath, '-dpng', '-r300'); % Save the plot as a PNG file with 300 dpi

% Scatter plot of labour market impact %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure; % Create a new figure window
scatter(BorderDist_n, log(wChange), 'o', 'LineWidth', 1.5, 'DisplayName', 'Wage'); % Scatter plot of BorderDist_n vs. wChange
hold on; % Hold on to add more plots to the current figure
scatter(BorderDist_n, log(lChange), 's', 'LineWidth', 1.5, 'DisplayName', 'Employment'); % Scatter plot of BorderDist_n vs. lChange
xline(0, 'k', 'LineWidth', 2, 'HandleVisibility', 'off'); % Add a vertical black line at BorderDist_n = 0, excluded from legend
hold off; % Release the hold to prevent more additions to this figure

xlabel('Border Distance (km)'); % Label for the x-axis
ylabel('Log change'); % General label for the y-axis
title('Scatter Plot of Changes vs. BorderDist_n'); % Title for the plot
legend('show', 'Location', 'southwest'); % Display a legend in the bottom left corner
grid on; % Add grid lines to make reading the plot easier

% Define the folder and filename
folder = 'figs';
filename = 'scatter_COUNT_BORDER_COMMTRADE_LabourChanges_lowTradeCost.png'; % Change filename to reflect new variables
fullpath = fullfile(folder, filename); % Create the full file path

% Ensure the directory exists, create it if it does not
if ~exist(folder, 'dir')
    mkdir(folder);
end

% Save the figure
print(fullpath, '-dpng', '-r300'); % Save the plot as a PNG file with 300 dpi

% Set parameter value back to baseline value
global psi 
psi = 0.42;
save('data/output/parameters')

% Recompile data with new parameter value
OwnData
BorderData

display('<<<<<<<<<<<<<<< Couterfactuals completed >>>>>>>>>>>>>>>')