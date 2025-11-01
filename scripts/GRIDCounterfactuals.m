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
% First version: Gabriel M Ahlfeldt, 11/2025                            %%%
% Based on original code provided by Tobias Seidel                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This script executes a series of counterfactuals in which we        %%% 
%%% similate the effects of a hypothetical border that follows the      %%%
%%% the border between formerly separated West Germany and East GErmany %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulates a HSR in Bay Area

% Load data
load('data/output/DATAusingGRID')

% Primitives that do not change => Changes are set to ones
aChange = ones(J, 1);
bChange = ones(J);
dChange = ones(J);
kapChange = ones(J,J);
dChange = ones(J,J);

% Prepare change in commuting cost matrix
%dataDistance = 'distance_matrix.csv';
%dist_mat = csvread(dataDistance, 1, 1);

% Prepare change in commuting cost matrix
dataDistance = 'GRID/TTMATRIX-toolkit/output/TTMATRIX-HSR-noHSR.csv'; % read no HSR
TTnoHSR_mat = csvread(dataDistance, 1, 1);
TTnoHSR_mat(1:size(TTnoHSR_mat,1)+1:end) = 1; % replace values on diagonal to 1
dataDistance = 'GRID/TTMATRIX-toolkit/output/TTMATRIX-HSR-HSR.csv'; % Read HSR
TTHSR_mat = csvread(dataDistance, 1, 1);
TTHSR_mat(1:size(TTnoHSR_mat,1)+1:end) = 1; % replace values on diagonal to 1

% Compute relative change in commuting cost
kapChange = TTHSR_mat./TTnoHSR_mat;
kapChange_avg = mean(kapChange, 2);

% Extract only entries that are not equal to 1
kappcChanges = kapChange(kapChange ~= 1);
kappcChanges = (kappcChanges-1).*100;
clf
close all
histogram(kappcChanges, 'NumBins', 20)
xlabel('% change in travel time on affected routes')
ylabel('Frequency')
title('Distribution of travel time changes (excluding unchanged pairs)')
exportgraphics(gcf, 'figs/GRID_FIG_COUNT_HSR_hist.png', 'Resolution', 300)
% Weighted average travel time change by region
attChange = sum(kapChange .* uncondCom, 2) ./ sum(uncondCom, 2);
histogram(attChange)

% Solve for counterfactual values
[wChange, vChange, qChange, piChange, lamChange, pChange, rChange, ...
    lChange, welfChange] = counterFactsTK(...
        aChange, bChange, kapChange, dChange, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh);

% Map findings
clf
close all
RESULT = GRIDMAPIT('GRID/GRID-toolkit/output/grid-data',kapChange_avg,'Relative change in average travel time; commuting HSR','figs','GRID_MAP_COUNT_HSR_comm_attChange') 

RESULT = GRIDMAPIT('GRID/GRID-toolkit/output/grid-data',log(qChange),'Relative change in house price; commuting HSR','figs','GRID_MAP_COUNT_HSR_comm_Qchange') 
RESULT = GRIDMAPIT('GRID/GRID-toolkit/output/grid-data',log(pChange),'Relative change in tradable goods price; commuting HSR','figs','GRID_MAP_COUNT_HSR_comm_Pchange') 
RESULT = GRIDMAPIT('GRID/GRID-toolkit/output/grid-data',log(rChange),'Relative change in population; commuting HSR','figs','GRID_MAP_COUNT_HSR_comm_Rchange') 
% Add wage result
RESULT = GRIDMAPIT('GRID/GRID-toolkit/output/grid-data',log(wChange),'Relative change in wage; commuting HSR','figs','GRID_MAP_COUNT_HSR_comm_Wchange') 
% Add employment result
RESULT = GRIDMAPIT('GRID/GRID-toolkit/output/grid-data',log(lChange),'Relative change in employment; commuting HSR','figs','GRID_MAP_COUNT_HSR_comm_Lchange') 

% Example vectors (replace with your actual data)

% Residents
    J = length(rChange);    % Number of data points
    x = [0 100];            % Time axis: from year 0 to 100
    
    % Create a new figure
    figure;
    hold on;
    
    % Plot each line with conditional color and style
    for j = 1:J
        y = [0, (rChange(j) - 1) * 100];  % % change from year 0 to 100
    
        if kapChange(j) < 1
            plot(x, y, '--', 'Color', [0 0 1]);  % Blue dashed line
        else
            plot(x, y, '-', 'Color', [0.5 0.5 0.5]);  % Solid grey line
        end
    end
    
    % Add labels and grid
    xlabel('Years');
    ylabel('% change');
    title('Residents');
    grid on;
exportgraphics(gcf, 'figs/FIG_COUNT_HSR_rChange.png', 'Resolution', 300)


% Residents
    clf;
    J = length(rChange);    % Number of data points
    x = [0 100];            % Time axis: from year 0 to 100
    
    % Create a new figure
    figure;
    hold on;
    
    % Plot each line with conditional color and style
    for j = 1:J
        y = [0, (lChange(j) - 1) * 100];  % % change from year 0 to 100
    
        if kapChange(j) < 1
            plot(x, y, '--', 'Color', [0 0 1]);  % Blue dashed line
        else
            plot(x, y, '-', 'Color', [0.5 0.5 0.5]);  % Solid grey line
        end
    end
    
    % Add labels and grid
    xlabel('Years');
    ylabel('% change');
    title('Employment');
    grid on;
exportgraphics(gcf, 'figs/FIG_COUNT_HSR_lChange.png', 'Resolution', 300)

% Rents
    clf
    J = length(qChange);    % Number of data points
    x = [0 100];            % Time axis: from year 0 to 100
    
    % Create a new figure
    figure;
    hold on;
    
    % Plot each line with conditional color and style
    for j = 1:J
        y = [0, (qChange(j) - 1) * 100];  % % change from year 0 to 100
    
        if kapChange(j) < 1
            plot(x, y, '--', 'Color', [0 0 1]);  % Blue dashed line
        else
            plot(x, y, '-', 'Color', [0.5 0.5 0.5]);  % Solid grey line
        end
    end
    
    % Add labels and grid
    xlabel('Years');
    ylabel('% change');
    title('Rent');
    grid on;
exportgraphics(gcf, 'figs/FIG_COUNT_HSR_qChange.png', 'Resolution', 300)


% Wage
    clf;
    J = length(wChange);    % Number of data points
    x = [0 100];            % Time axis: from year 0 to 100
    
    % Create a new figure
    figure;
    hold on;
    
    % Plot each line with conditional color and style
    for j = 1:J
        y = [0, (wChange(j) - 1) * 100];  % % change from year 0 to 100
    
        if kapChange(j) < 1
            plot(x, y, '--', 'Color', [0 0 1]);  % Blue dashed line
        else
            plot(x, y, '-', 'Color', [0.5 0.5 0.5]);  % Solid grey line
        end
    end
    
    % Add labels and grid
    xlabel('Years');
    ylabel('% change');
    title('Wage');
    grid on;
exportgraphics(gcf, 'figs/FIG_COUNT_HSR_wChange.png', 'Resolution', 300)

% Also let trade cost change
% ----------------------------------------------+
dChange = kapChange; % Unrealistically assume that trade cost change proportionate to travel time changes

% Solve for counterfactual values
[wChange, vChange, qChange, piChange, lamChange, pChange, rChange, ...
    lChange, welfChange] = counterFactsTK(...
        aChange, bChange, kapChange, dChange, w_n, v_n, uncondCom, L_n, ...
        R_n, tradesh);
% Export map
RESULT = GRIDMAPIT('GRID/GRID-toolkit/output/grid-data',log(pChange),'Relative change in tradable goods price; commuting & trade HSR','figs','GRID_MAP_COUNT_HSR_comm_PchangeWtrade') 



display('<<<<<<<<<<<<<<< Couterfactuals completed >>>>>>>>>>>>>>>')