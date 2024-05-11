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
%%$ This function updates changes in trade shares pi_ni for given       %%%
%%% change in workplace employment, trade cost; wages and productivity  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pChange = updatePricesTK(emplChange, wChange, piChange, prodChange,tradecChange)
    % Compute the vector of changes in prices.
    %
    % Inputs:
    %   - emplChange: Vector of size Nx1. Changes in regional employment.
    %   - wChange: Vector of size Nx1. Changes in wages for each location.
    %   - piChange: Matrix of size NxN. Changes in bilateral trade shares.
    %   - prodChange: Vector of size Nx1. Changes in regional productivities.
    %   - tradecChange: Matrix of size NxN. Changes in bilateral tradecosts.
    %           varieties of the consumption good.
    %
    % Output:
    %   - pChange: Vector of size Nx1. Changes in regional price index.


    % Make global parameters accessible
    global sigg nu

    pChange = (emplChange.^(1-(1-sigg)*nu) ./ diag(piChange)).^(1 / (1 - sigg)) ...
            .*diag(tradecChange).*wChange./prodChange;
