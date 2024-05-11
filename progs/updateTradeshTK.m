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

function piChange = updateTradeshTK(emplChange, tradecChange, wageChange, ...
                                  prodChange, piObs)
    % Compute matrix of changes for bilateral tradevalues.
    %
    % Inputs:
    %   - emplChange: Vector of size Nx1. Change in regional employment.
    %   - tradecChange: Matrix of size NxN. Changes in bilateral tradecosts.
    %   - wageChange: Vector of size Nx1. Change in regional wages.
    %   - prodChange: Vector of size Nx1. Change in regional specific
    %                 productivities.
    %   - piObs: Matrix of size NxN. Observed trade shares.
    %   - sigg: Scalar. Parameter for elasticity of substitution between
    %           varieties of the consumption good.
    %
    % Output:
    %   - piChange: Matrix of size NxN. Change in bilateral tradeshares.

% Make global parameters accessible
global sigg nu

    nobs = length(emplChange);

    % Calculate the part of the numerator in the tradeshare equation without
    % tradecosts.
    num = prodChange.^(sigg - 1) .* emplChange.^(1-(1-sigg)*nu) .* ...
            wageChange.^(1 - sigg);

    % Matrix representation of the entire numerator. Note that in order to
    % correctly multiply the vector num with the tradecosts matrix we need to
    % replicate it so that it has the same dimension as the matrix.
    num = repmat(num, 1, nobs);
    nummat = tradecChange.^(1 - sigg) .* num;

    % Calculatie the denominator as the columnsum of the numerator matrix
    denom = sum(piObs .* nummat);
    denommat = repmat(denom, nobs, 1);

    piChange = nummat ./ denommat;
