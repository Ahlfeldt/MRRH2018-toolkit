function pChange = updatePrices(emplChange, wChange, piChange, ...
                                prodChange, sigg, rrho)
    % Compute the vector of changes in prices.
    %
    % Inputs:
    %   - emplChange: Vector of size Nx1. Changes in regional employment.
    %   - wChange: Vector of size Nx1. Changes in wages for each location.
    %   - piChange: Matrix of size NxN. Changes in bilateral trade shares.
    %   - prodChange: Vector of size Nx1. Changes in regional productivities.
    %   - sigg: Scalar. Parameter of elasticity of subsitution between
    %           varieties of the consumption good.
    %
    % Output:
    %   - pChange: Vector of size Nx1. Changes in regional price index.

    pChange = (emplChange.^(1-(1-sigg)*rrho) ./ diag(piChange)).^(1 / (1 - sigg));
