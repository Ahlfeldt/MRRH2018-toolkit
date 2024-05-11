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
%%$ This function updates changes in workplace employment L_n for given %%%
%%% cahnges in unconditional commuting probabilities                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function emplChange = updateEmplTK(lamChange, lamObs, emplObs, emplBar)
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
