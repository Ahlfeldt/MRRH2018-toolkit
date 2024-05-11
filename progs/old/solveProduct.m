function product = solveProduct(L_n, R_n, w_n, v_n, dni, sigg, spillover)
    % Solve for unobserved location specific productivities from regional budget
    % identities and the definition of tradeshares.

    rrho = spillover;
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
    product = ones(nobs, 1);

    % Initialize distance and iteration count variables
    disst = 1;
    count = 0;

    % Run loop as long as distance is not (almost) zero and iteration count is
    % lower than *maxiter*.
    while count < maxiter

        % Compute tradeshares with current productivity vector
        %tradesh = getTradeshares(product, empl, wage, tradec, sigg, rrho);
        num = product.^(sigg - 1) .* L_n.^(1-(1-sigg)*rrho) .* w_n.^(1 - sigg);
        num = repmat(num', nobs, 1);
        nummat = dni.^(1 - sigg) .* num;

        denom = sum(nummat, 2);
        denommat = repmat(denom, 1, nobs);
        
    % Calculate matrix of tradeshares by piecewise division.
        tradesh = nummat./denommat;
        

        % Compute income
        income = w_n .* L_n;

        % Compute expenditure
        expend = tradesh' * (v_n .* R_n);

        % Update distance
        disst = round(abs(income - expend), precision);
        
        % Check convergence
        if disst == 0
            % If converged break the loop
            return
        else
            % Update productivities
            product_up = product .* (income./expend);
            product = conPar .* product_up + (1 - conPar) .* product;
            product = product ./ mean(product);

            %Update iteration count
            count = count + 1;
        end
    end

    % If not converged throw an error. Note that this part of the function will
    % only be executed if the while loop hits the maximum of iterations without
    % convergence.
    error('No convergence achieved within the maximum number of iterations!');

end