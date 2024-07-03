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

function [wChange, vChange, qChange, piChange, lamChange, pChange, rChange, ...
    lChange, welfChange] = counterFactsTK(aChange, bChange, ...
    kapChange, dChange, wObs, vObs, lamObs, lObs, rObs, piObs)
    % Given the model parameters {alpha, sigma, epsilon, delta, kappa} and
    % counterfactual changes in the exogenous variables {Ai, Bn, kappa_ni,
    % tradecosts} compute the change in the endogenous variables.
    %
    % Notes:
    %  In the below, we refer to "relative changes". These correspond to
    %  ratios x_hat = x_prime / x as convention in exhact algebra
    %  notations. See Codebook Section A.2 for further detail
    %
    % Inputs:
    %   - aChange: Vector of size Nx1. Relative changes in regional productivities.
    %   - bChange: Matrix of size NxN. Relative changes in bilateral amenities.
    %   - kapChange: Matrix of size NxN. Relative changes in bilateral commuting costs.
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
    %   - epsi: Scalar. Frechet shape parameter.
    %   - sigg: Scalar. Elasticity of substitution between varieties.
    %   - alp: Scalar. Share of consumption expenditure.
    %   - dell: Scalar. Supply elasticity of housing.
    %   - polScale: Scalar. Scaling parameter for per distance unit pollution.
    %   - nu: Scalar. Productivity spillover parameter.
    %
    % Output:
    %   - wChange: Vector of size Nx1. Relative changes in regional wages.
    %   - vChange: Vector of size Nx1. Relative changes in average residential wages.
    %   - qChange: Vector of size Nx1. Relative changes in regional house prices.
    %   - piChange: Matrix of size NxN. Relative changes in bilateral trade shares.
    %   - lamChange: Matrix of size NxN. Relative changes in bilateral commuting
    %                probabilities.
    %   - pChange: Vector of size Nx1. Relative changes in regional price indices.
    %   - rChange: Vector of size Nx1. Relative changes in residential locations.
    %   - lChange: Vector of size Nx1. Relative changes in regional employment.
    %   - ecChange: Vector of size Nx1. Relative changes in regional contributions to
    %               pollution.
    %   - eTotChange: Scalar. Change in total pollution.
    %   - welfChange: Scalar. Change in aggregate worker welfare.
%     lObs = L_n;
%     lamObs =uncondCom;
%     vObs =v_n;
%     wObs = w_n;
%     rObs = R_n;
%     piObs = tradesh;
%     nu = spillover;
    
display('...Solving for the counterfactual...')

global nu delta alp sigg epsi
    nobs = length(aChange);
    lBar = sum(lObs);

    % Initialize guesses of change in wages and commuting probabilities
    wChange = ones(nobs, 1);
    lamChange = ones(nobs);

    % Enter loop: Executes an infinitive loop that continues until a break
    % condition is satisfied
    while true
        % Compute change in residential wages
        vChange = updateResWageTK(bChange, wChange, kapChange, lamObs, ...
            vObs, wObs);
        % Compute change in employment
        lChange = updateEmplTK(lamChange, lamObs, lObs, lBar);
        % Compute change in residential choices
        rChange = updateResidentsTK(lamChange, lamObs, rObs, lBar);
        % Compute change in house prices
        qChange = updateHousePriceTK(vChange, rChange);
        % Compute change in tradeshares
        piChange = updateTradeshTK(lChange, dChange, wChange, aChange, ...
            piObs);
        % Compute change in prices
        pChange = updatePricesTK(lChange, wChange, piChange, aChange, dChange);
        % Update change in wages and commuting probability
        wTilde = updateWageTK(lChange, piChange, vChange, rChange, lObs, ...
                            wObs, piObs, vObs, rObs);
        w_new = (wTilde.* wObs)./ mean(wTilde.* wObs);
        wTilde = w_new./wObs;
                        
        lamTilde = updateLamTK(bChange, pChange, qChange, wChange, kapChange, ...
                             lamObs);
                         
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


    % Compute total welfare change from population mobility as derived in
    % Counterfactuals subsection in Codebook
    pq_mat = repmat(pChange.^alp .* qChange.^(1 - alp), 1, nobs);
    wage_mat = repmat(wChange', nobs, 1);
    welfChange = bChange.^(1/epsi) .* (kapChange .* pq_mat).^(-1) .* ...
        wage_mat .* lamChange.^(-1/epsi);
    % Display percentage change
    percentageChange = (welfChange(1,1) - 1) * 100;
    % Displaying the formatted text with the embedded numeric value
    fprintf('...Change in welfare is %.2f%%\n', percentageChange);