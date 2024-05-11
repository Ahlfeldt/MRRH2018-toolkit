function vChange = updateResWage(bChange, wChange, comcChange,...
                              lamObs, vObs, wObs, epps)
    % Compute the vector of changes for residential wages.
    % 
    % Inputs:
    %   - bChange: Matrix of size NxN. Representing changes in amenities for 
    %              all residence and workplace combinations.
    %   - wChange: Vector of size Nx1. Changes in wages for each location.
    %   - comcChange: Matrix of size NxN. Changes in bilateral commuting costs.
    %   - lamObs: Matrix of size NxN. Observed unconditional commuting
    %             probabilities.
    %   - vObs: Vector of size Nx1. Observed average wages for residents for
    %           each location.
    %   - wObs: Vector of size Nx1. Observed regional wages for each location.
    %   - epps: Scalar. Parameter for elasticity of substitution between 
    %           varieties of the consumption good.
    % 
    % Output:
    %   - vChange: Vector of size Nx1. Computed changes in average wages for 
    %           residents in each location.

    nobs = length(wChange);
        
    % Compute numerator
    numerat = (bChange .* lamObs .* comcChange.^(-epps)) * ...
        (wChange.^(1 + epps) .* wObs);

    % Compute denominator
    denom = bChange .* lamObs .* comcChange.^(-epps) * wChange.^epps;

    % Compute vChange
    vChange = (numerat ./ denom) ./ vObs;
