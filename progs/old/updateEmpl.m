function emplChange = updateEmpl(lamChange, lamObs, emplObs, emplBar)
    % Compute the vector of changes for Employment.
    % 
    % Inputs:
    %   - lamChange: Matrix of size NxN. Changes in bilateral unconditional
    %                commuting probabilities.
    %   - lamObs: Matrix of size NxN. Observed unconditional commuting
    %             probabilities.
    %   - emplObs: Vector of size Nx1. Observed regional employment.
    %   - emplBar: Scalar. Overall employment.
    % 
    % Output:
    %   - emplChange: Vector of size Nx1. Computed changes in equilibrium
    %                 employment.

    % Compute commuting term
    comTerm = sum(lamObs .* lamChange, 1);

    % Return employment change parameter.
    emplChange = emplBar .* (comTerm' ./ emplObs);
    
%     %Normalization
%     A = emplChange.*emplObs;
%     B = A./mean(A);
%     emplChange = B./emplObs;
