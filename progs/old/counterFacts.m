%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Master MATLAB programme file for the MMRH2017 tolkit by             %%%
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

function [wChange, vChange, qChange, piChange, lamChange, pChange, rChange, ...
    lChange, welfChange] = counterFacts(aChange, bChange, ...
    kapChange, dChange, wObs, vObs, lamObs, lObs, rObs, piObs, ...
    distMat, epps, sigg, alp, delta, rrho)
    % Given the model parameters {alpha, sigma, epsilon, delta, kappa} and
    % counterfactual changes in the exogenous variables {Ai, Bn, kappa_ni,
    % tradecosts} compute the change in the endogenous variables.
    %
    % Inputs:
    %   - aChange: Vector of size Nx1. Changes in regional productivities.
    %   - bChange: Matrix of size NxN. Changes in bilateral amenities.
    %   - kapChange: Matrix of size NxN. Changes in bilateral commuting costs.
    %   - dChange: Matrix of size NxN. Changes in bilateral trade costs.
    %   - wObs: Vector of size Nx1. Observed regional wages.
    %   - vObs: Vector of size Nx1. Observed average residential wages.
    %   - lamObs: Matrix of size NxN. Observed bilateral commuting
    %             probabilities.
    %   - lObs: Vector of size Nx1. Observed regional employment.
    %   - rObs: Vector of size Nx1. Observed residential locations.
    %   - piObs: Matrix of size NxN. Observed bilateral trade shares.
    %   - ecObs: Vector of size Nx1. Observed regional contributions to
    %            pollution.
    %   - eTotObs: Scalar. Observed total pollution.
    %   - distMat: Matrix fo size NxN. Bilateral distances.
    %   - epps: Scalar. Frechet shape parameter.
    %   - sigg: Scalar. Elasticity of substitution between varieties.
    %   - alp: Scalar. Share of consumption expenditure.
    %   - dell: Scalar. Supply elasticity of housing.
    %   - polScale: Scalar. Scaling parameter for per distance unit pollution.
    %   - rrho: Scalar. Productivity spillover parameter.
    %
    % Output:
    %   - wChange: Vector of size Nx1. Changes in regional wages.
    %   - vChange: Vector of size Nx1. Changes in average residential wages.
    %   - qChange: Vector of size Nx1. Changes in regional house prices.
    %   - piChange: Matrix of size NxN. Changes in bilateral trade shares.
    %   - lamChange: Matrix of size NxN. Changes in bilateral commuting
    %                probabilities.
    %   - pChange: Vector of size Nx1. Changes in regional price indices.
    %   - rChange: Vector of size Nx1. Changes in residential locations.
    %   - lChange: Vector of size Nx1. Changes in regional employment.
    %   - ecChange: Vector of size Nx1. Changes in regional contributions to
    %               pollution.
    %   - eTotChange: Scalar. Change in total pollution.
    %   - welfChange: Scalar. Change in aggregate worker welfare.
%     lObs = L_n;
%     lamObs =uncondCom;
%     vObs =v_n;
%     wObs = w_n;
%     rObs = R_n;
%     piObs = tradesh;
%     rrho = spillover;
    
    nobs = length(aChange);
    lBar = sum(lObs);

    % Initialize change in wages and commuting probabilities
    wChange = ones(nobs, 1);
    lamChange = ones(nobs);

    % Enter loop (break condition? maybe difference between wage and commuting
    % probability in each iteration step.)
    while true
        % Compute change in residential wages
        vChange = updateResWage(bChange, wChange, kapChange, lamObs, vObs, ...
                                wObs, epps);
        % Compute change in employment
        lChange = updateEmpl(lamChange, lamObs, lObs, lBar);
        % Compute change in residential choices
        rChange = updateResidents(lamChange, lamObs, rObs, lBar);
        % Compute change in house prices
        qChange = updateHousePrice(vChange, rChange, delta);
        % Compute change in tradeshares
        piChange = updateTradesh(lChange, dChange, wChange, aChange, ...
            piObs, sigg, rrho);
        % Compute change in prices
        pChange = updatePrices(lChange, wChange, piChange, aChange, sigg, rrho);
        % Update change in wages and commuting probability
        wTilde = updateWage(lChange, piChange, vChange, rChange, lObs, ...
                            wObs, piObs, vObs, rObs);
        w_new = (wTilde.* wObs)./ mean(wTilde.* wObs);
        wTilde = w_new./wObs;
                        
        lamTilde = updateLam(bChange, pChange, qChange, wChange, kapChange, ...
                             lamObs, alp, epps);
                         
        % Check the difference between old and new guess for wage and commuting
        % probability.
        if all(abs(wChange - wTilde) < 10^(-4)) && ...
                all(abs(lamChange(:) - lamTilde(:)) < 10^(-4))
            % If the difference is small enough break the loop
            break
        else
            % If not compute new guesses as a convex combination between old
            % guess and update.
            wChange = 0.25 * wTilde + 0.75 * wChange;
            lamChange = 0.25 * lamTilde + 0.75 * lamChange;
        end
    end

    % After other changes have converged, compute changes in local pollution
    % contributions and overall pollution.
    % ecChange = polScale * sum(lObs) ./ ecObs .* ...
    %     sum(lamChange .* lamObs .* distMat, 2);

    % eTotChange = sum(ecChange .* ecObs) / sum(ecObs);

    % Compute total welfare change from population mobility.
    pq_mat = repmat(pChange.^alp .* qChange.^(1 - alp), 1, nobs);
    wage_mat = repmat(wChange', nobs, 1);
    welfChange = bChange.^(1/epps) .* (kapChange .* pq_mat).^(-1) .* ...
        wage_mat .* lamChange.^(-1/epps);
