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
%%% This is the master script that calls other scripts
%%% Please the following toolboxes
%%%% Global optimization
%%%% Statistics and Machine learning 
%%%% Mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Automatically set working directory to the parent of this script

% Get full path of this script
thisFile = matlab.desktop.editor.getActiveFilename;

if ~isempty(thisFile)
    [thisDir,~,~] = fileparts(thisFile);   % directory containing the script
    parentDir = fileparts(thisDir);        % parent folder
    cd(parentDir);                         % move up one level
    fprintf('Working directory set to: %s\n', parentDir);
else
    warning('Could not determine script location. Please run from a saved .m file.');
end

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
nu = 0.0;
psi = 0.42;
% J = 401;
save('data/output/parameters')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GRIDData
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
GRIDCounterfactuals
% Exectues diactic counterfactuals in which large costs are assigned to i)
% trade routes that cross the inner-German border, ii) commuting routes
% that corss the border, iii) communting and trade routes that cross the
% border. It illustrates the outcomes on maps and border discontinuity
% scatter plots
