function residChange = updateResidents(lamChange, lamObs, residObs, emplBar)
    % Compute the vector of changes in residential locations.
    % 
    % Inputs:
    %   - lamChange: Matrix of size NxN. Changes in bilateral unconditional
    %                commuting probabilities.
    %   - lamObs: Matrix of size NxN. Observed unconditional commuting
    %             probabilities.
    %   - residObs: Vector of size Nx1. Observed residential locations.
    %   - emplBar: Scalar. Overall employment.
    % 
    % Output:
    %   - emplChange: Vector of size Nx1. Computed changes in residential
    %                 locations.

    % Compute commuting term
    comTerm = sum(lamObs .* lamChange, 2);

    % Return residential change vector.
    residChange = emplBar .* (comTerm ./ residObs);
    
%     %Normalization
%     A = residChange.*residObs;
%     B = A./mean(A);
%     residChange = B./residObs;
