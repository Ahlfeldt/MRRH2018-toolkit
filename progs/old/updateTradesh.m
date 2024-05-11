function piChange = updateTradesh(emplChange, tradecChange, wageChange, ...
                                  prodChange, piObs, sigg, rrho)
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

    nobs = length(emplChange);

    % Calculate the part of the numerator in the tradeshare equation without
    % tradecosts.
    num = prodChange.^(sigg - 1) .* emplChange.^(1-(1-sigg)*rrho) .* ...
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
