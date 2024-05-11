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
%%% This function recovers fundamental productivities that satisfy the  %%%
%%% income equals expenditure condition and uses them to comute trade   %%%
%%% trade shares and the tradable goods price index                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [product,tradesh,tradeshOwn,P_n ]= solveProductTradeTK(L_n, R_n, w_n, v_n, dni)
 % This program uses the following inputs
        % L_n is a n x 1 vector of workplace employment
        % R_n is a n x 1 vector of residence employment
        % w_n is a n x 1 vector of observed wages at the workplace
        % v_n is a n x 1 vector of computed expected wages at residence
        % dni is a n by n matrix of bilateral trade costs
    % This program produces the following outputs
        % product is the vector of productivities A_i
        % trash is matrio
    % The names of the inputs need to correspond to objects that exist in
    % the workspace. The names of the outputs can be freely chosen

% Make global scalars accessible
    global sigg nu fixC

    rrho = nu;
    nobs = length(L_n);
    % Maximum number of iterations before ending the loop and throwing a
    % nonconverge error.
    maxiter = 2000;
    % Rounding precision of distance to check if it is almost zero.
    precision = 6;
    % parameter to compute the convex combination between old and updated
    % productivities
    conPar = .25;

    % Initialize productivity vector
    product = ones(nobs, 1);                                                % Set productivity A_bar_i guesses to 1

    % Initialize distance and iteration count variables
    disst = 1;                                                              % disst is the abosolute difference between income an expenditure whose minimization is the objective of the algorithm
    count = 0;                                                              % a counter of iteration invoking a stopping rule if the algorithm does not converge

    % Run loop as long as distance is not (almost) zero and iteration count is
    % lower than *maxiter*.
    while count < maxiter

        % Compute tradeshares with current productivity vector
        % Begin by computing the numerator in SW2020 Eq. (10)
            num = product.^(sigg - 1) .* L_n.^(1-(1-sigg)*rrho) .* w_n.^(1 - sigg); % Generate i-specific components (where products are being produced)
            num = repmat(num', nobs, 1);                                    % Transpose the matrix so that spending origins n are in columns and replicate by J rows to obtain a JxJ matrix
            nummat = dni.^(1 - sigg) .* num;                                % Multiply by d_ni^(1-sigma) trade component to obtain denominator in matrix form

        denom = sum(nummat, 2);                                             % Compute the denominator in SW2020 Eq. (10) by taking the sums across columns within rows resulting in Jx1 vector
        denommat = repmat(denom, 1, nobs);                                  % We replicate this Jx1 vector J times to get a JxJ matrix
        
    % Calculate matrix of tradeshares by piecewise division.
        tradesh = nummat./denommat;                                         % Compute trade shares in SW2020 Eq. (10)
        

        % Compute income
        income = w_n .* L_n;                                                % What forms spend on worker income in i; the left-hand side of SW2020 Eq. (12)

        % Compute expenditure
        expend = tradesh' * (v_n .* R_n);                                   % The right-hand side in SW202 Eq. (12), i.e. the revenues firms in i generate from selling to workers living in n (notice that landlords spend rental income locally, hence there is no alpha)
                                                                            % Trade share give what workers living in n spend on goods produced in i (in columns).
                                                                            % Here we aggregate over the expenditure by workers in n (in columns), therefore we need to transpose the trade matrix
        % Update distance
        disst = round(abs(income - expend), precision);                     % Equilibrium condition is income equals expenditure
        
        % Check convergence
        if disst == 0
            % if converged, compute tradeshares and price index
                num = product.^(sigg - 1) .* L_n.^(1-(1-sigg).*rrho) .* w_n.^(1 - sigg);
                % Matrix representation of the entire numerator. Note that in order to
                % correctly multiply the vector num with the tradecosts matrix we need to
                % replicate it so that it has the same dimension as the matrix.
                num = repmat(num, 1, nobs);                                 % This time we do not transpose the num matrix since we want the spending destination i to be in columns
                nummat = dni.^(1 - sigg) .* num;
            
                % The denominator is simply the sum over all rows in a column of the
                % numerator matrix. To again expand it to a size of nobs x nobs we need to
                % use repmat again.
                denom = sum(nummat);
                denommat = repmat(denom, nobs, 1);
            
                % Calculate matrix of tradeshares by piecewise division.
                tradesh = nummat./denommat;
                % Onw tradeshare
                tradeshOwn = diag(tradesh);
                % Price index
                P_n = sigg./(sigg-1).*(L_n./(sigg.*fixC.*tradeshOwn)).^(1./(1-sigg)).*(w_n./product);
            % If converged break the loop
            return
        else % Continue
            % Update productivities
            product_up = product .* (income./expend);                       % If worker income exceeds expenditure, firms in i are not attracting enough revenues. Need to be more productive to attract more revenues and rationalize wage bill under zero profits
            product = conPar .* product_up + (1 - conPar) .* product;       % Update guess to weighted combination of old and new guesses
            product = product ./ mean(product);                             % Productivity is identified up to a constant. Therefore we normalize to by the mean

            %Update iteration count
            count = count + 1;
        end
    end

    % If not converged throw an error. Note that this part of the function will
    % only be executed if the while loop hits the maximum of iterations without
    % convergence.
    error('No convergence achieved within the maximum number of iterations!');

end