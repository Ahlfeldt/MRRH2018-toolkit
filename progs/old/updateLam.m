%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Master MATLAB programme file for the MMRH2018 tolkit by             %%%
%%% Gabriel Ahlfeldt M. Ahlfeldt and Tobias Seidel                      %%%
%%% The toolkit uses data and code compiled for                         %%%
%%% Seidel and Wckerath (2020): Rush hours and urbanization             %%%
%%% Codes and data have been re-organized to make the toolkit more      %%%
%%% accessible. Seval programmes have been added to allow for more      %%%
%%% general applications. Discriptive analyses and counterfactuals      %%%
%%% serve didactic purposes and are unrelated to the research paper     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First version: Gabriel M Ahlfeldt, 05/2024                            %%%
% Based on original code provided by Tobias Seidel                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%$ This function updates workplace wages for given                     %%%
%%% change in workplace employment, trade shares; residential wages     %%%
%%% residential populat                                                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lamChange = updateLam(bChange, pChange, qChange, wChange, ...
                               kapChange, lamObs, alp, epps)
    % Compute matrix of changes in commuting probabilities.
    % 
    % Inputs:
    %   - bChange: Matrix of size NxN. Changes in bilateral amenities.
    %   - pChange: Vector of size Nx1. Changes in regional price indices.
    %   - qChange: Vector of size Nx1. Changes in regional house prices.
    %   - wChange: Vector of size Nx1. Changes in regional wages.
    %   - kapChange: Matrix of size NxN. Changes in bilateral commuting costs.
    %   - lamObs: Matrix of size NxN. Changes in commuting probabilities.
    %   - alp: Scalar. Parameter for share of consumption expenditure.
    %   - epps: Scalar. Parameter for the elasticity of substitution between
    %           consumption varieties.
    % 
    % Output:
    %   - lamChange: Matrix of size NxN. Changes in unconditional bilateral
    %                commuting probabilities.

    nobs = length(pChange);

    % Replicate both price vector and wage vector
    pq_mat = repmat(pChange.^alp .* qChange.^(1 - alp), 1, nobs);
    wage_mat = repmat(wChange', nobs, 1);

    % Calculate numerator
    nummat = bChange .* pq_mat.^(-epps) .* (wage_mat./kapChange).^epps;

    % Calculate denominator
    denom = sum(lamObs(:) .* nummat(:));

    % Return result
    lamChange = nummat ./ denom;