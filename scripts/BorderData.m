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
%%% This script generates and merges the border variables used in       %%%
%%% counterfactuals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load baseline data
load('data/output/DATAusingSW')

% Create a dummy for counties in the East
East = zeros(J, 1); % Initialize the vector with zeros
East(325:end) = 1; % Set elements from 325 to the end to 1

% Create logical vectors for East and West
isEast = logical(East);  % Convert to logical, where East is true
isWest = ~isEast;        % West is the logical NOT of East

% Create the condition matrix using outer logical OR between East-West and West-East
conditionMatrix = (isEast & isWest') | (isWest & isEast');

% Import border distance
dataBoderDist = 'CountyBorderDist.csv';
BorderDist_n = csvread(dataBoderDist,1,1);
BorderDist_n=BorderDist_n+10;                                               % Add a small distance to improve visibility in scatter plot
BorderDist_n(East == 0) = -abs(BorderDist_n(East == 0));

% Save data
save('data/output/DATAusingSWborder')

display('<<<<<<<<<<<<<<< Border data generated >>>>>>>>>>>>>>>')