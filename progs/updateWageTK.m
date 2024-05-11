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

function wChange = updateWageTK(lChange, piChange, vChange, rChange, ...
                              lObs, wObs, piObs, vObs, rObs)
    % Update guess for change in regional changes.
    % 
    % Inputs:
    %   - lChange: Vector of size Nx1. Changes in regional employment.
    %   - piChange: Matrix of size NxN. Changes in bilateral trade shares.
    %   - vChange: Vector of size Nx1. Changes in average residential wages.
    %   - rChange: Vector of size Nx1. Changes in residential locations.
    %   - lObs: Vector of size Nx1. Observed regional employment.
    %   - wObs: Vector of size Nx1. Observed regional wages.
    %   - piObs: Matrix of size Nx1. Observed bilateral trade shares.
    %   - vObs: Vector of size Nx1. Observed average residential wages.
    %   - rObs: Vector of size Nx1. Observed residential locations.
    % 
    % Output:
    %   - wChange: Changes in regional wages.

    nobs = length(lChange);

    nummat = piObs .* piChange;
    vrMat = repmat(vChange' .* rChange' .* vObs' .* rObs', nobs, 1);

    num = sum(nummat .* vrMat, 2);
    denom = wObs .* lObs .* lChange;

    wChange = num ./ denom;
    
%         %Normalization
%     A = wChange.*wObs;
%     B = A./mean(A);
%     wChange = B./wObs;