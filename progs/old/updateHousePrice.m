function qChange = updateHousePrice(vChange, residChange, dell)
    % Compute updated house prices
    %
    % Inputs:
    %   - vChange: Vector of size Nx1. Changes in average residential wage.
    %   - residChange: Vector of size Nx1. Change in residential location.
    %   - dell: Scalar. Housing supply elasticity.
    %
    % Output:
    %   - qChange: Vector of size Nx1. Computed change in regional house
    %              prices.

    qChange = (vChange .* residChange).^(1 ./ (1 + dell));