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
%%% This is the master script that calls other scripts
%%% Please the following toolboxes
%%%% Global optimization
%%%% Statistics and Machine learning 
%%%% Mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Root folder of working directory %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% User 1 GA X-Kölln desktop
% User 2 GA notebook
% User 3 GA Server
% User 4 AH
user = 1                                                                    % Define users
if user==1;                                                                 % Root directory of primary user
    cd 'D:\Dropbox\_HUB_HerreraA\Course\Repository\Replication_Directories\SW2020-toolkit';             
elseif user==2;                                                             % Root directory of secondary user. Add more users if necessary
    cd '';
elseif user==3;                                                             % Root directory of secondary user. Add more users if necessary
    cd '';
elseif user==4;
    cd '';
end;
addpath('data/input')                                                       % Adding path to data
addpath('progs')                                                            % Adding path to programmes
addpath('scripts')                                                          % Adding path to scripts that execture various steps of the analysis
clear;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
global epsi mu alp delta sigg fixC nu J psi;                             % Define all parameters as globals so that they can be found by programmes
alp = 0.7;
epsi = 4.6;
mu = 0.47;
delta = 0.38;
sigg = 4;
fixC = 1;
nu = 0.05;
psi = 0.42;
J = 401;
save('data\output\parameters')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ReadData                                                                   
% Executes script that reads in baseline data from SW2020. This data set
% contains bilateral commuting flows similar to the data used by MMRH2017.
% Routes with zero commutes have commuting costs set to infinity.
% Therefore, this data set is inconsistent with standard travel time
% matrices. If you wish to work with your own travel time matrices and run
% counterfactuals it will be more convenient to use OwnData.m to compile
% your own data set
% This script also inverts productivities and computes trade shares and the
% tradable price index

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Descriptives
% Executres script that generates several maps and scatter plots that
% illustrate the data and some variables solved within the model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OwnData
% Adjusts the data set to standard travel time matrices that may form the
% basis of counterfactuals. To this end, it generates artificial commuting
% flows that are consistent with observed workplace and residence
% employment. Use this data generation script when working with your own
% commuting time matrices. This script is also the natural starting point
% when transferring the model to other contexts where you do not observe
% commuting flows.
% This script also inverts productivities and computes trade shares and the
% tradable price index

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BorderData
% Generates border variabels that identify in which part of Germany 
% and how far from the former inner-German border it is located. It uses 
% these variables to generte a distance running variable that takes
% negative values in West Germany and positive values in East Germany

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Counterfactuals
% Exectues diactic counterfactuals in which large costs are assigned to i)
% trade routes that cross the inner-German border, ii) commuting routes
% that corss the border, iii) communting and trade routes that cross the
% border. It illustrates the outcomes on maps and border discontinuity
% scatter plots
