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
%%$ This function updates changes in residential wages v_n for given    %%%
%%% changes in changes in wages amenities commuting costs               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vChange = updateResWageTK(bChange, wChange, comcChange,...
                              lamObs, vObs, wObs)

    % Compute the vector of changes for residential wages.
    % 
    % Inputs:
    %   - bChange: Matrix of size NxN. Representing changes in amenities for 
    %              all residence and workplace combinations.
    %   - wChange: Vector of size Nx1. Changes in wages for each location.
    %   - comcChange: Matrix of size NxN. Changes in bilateral commuting costs.
    %   - lamObs: Matrix of size NxN. Observed unconditional commuting
    %             probabilities.
    %   - vObs: Vector of size Nx1. Observed average wages for residents for
    %           each location.
    %   - wObs: Vector of size Nx1. Observed regional wages for each location.
    % 
    % Output:
    %   - vChange: Vector of size Nx1. Computed changes in average wages for 
    %           residents in each location.

% Make parameters accessible
global epsi 

    nobs = length(wChange);
        
    % Compute numerator
    numerat = (bChange .* lamObs .* comcChange.^(-epsi)) * ...
        (wChange.^(1 + epsi) .* wObs);

    % Compute denominator
    denom = bChange .* lamObs .* comcChange.^(-epsi) * wChange.^epsi;

    % Compute vChange
    vChange = (numerat ./ denom) ./ vObs;
