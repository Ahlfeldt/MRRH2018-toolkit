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
%%$ This function updates workplace wages for given                     %%%
%%% change in workplace employment, trade shares; residential wages     %%%
%%% residential populat                                                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lamChange = updateLamTK(bChange, pChange, qChange, wChange, ...
                               kapChange, lamObs)
    % Compute matrix of changes in commuting probabilities.
    % 
    % Inputs:
    %   - bChange: Matrix of size NxN. Changes in bilateral amenities.
    %   - pChange: Vector of size Nx1. Changes in regional price indices.
    %   - qChange: Vector of size Nx1. Changes in regional house prices.
    %   - wChange: Vector of size Nx1. Changes in regional wages.
    %   - kapChange: Matrix of size NxN. Changes in bilateral commuting costs.
    %   - lamObs: Matrix of size NxN. Changes in commuting probabilities.
    % 
    % Output:
    %   - lamChange: Matrix of size NxN. Changes in unconditional bilateral
    %                commuting probabilities.

% Make global parameters accessible
global alp epsi

    nobs = length(pChange);

    % Replicate both price vector and wage vector
    pq_mat = repmat(pChange.^alp .* qChange.^(1 - alp), 1, nobs);
    wage_mat = repmat(wChange', nobs, 1);

    % Calculate numerator
    nummat = bChange .* pq_mat.^(-epsi) .* (wage_mat./kapChange).^epsi;

    % Calculate denominator
    denom = sum(lamObs(:) .* nummat(:));

    % Return result
    lamChange = nummat ./ denom;