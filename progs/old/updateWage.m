function wChange = updateWage(lChange, piChange, vChange, rChange, ...
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