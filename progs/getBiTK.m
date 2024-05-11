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
%%% MATLAB programme file for Ahlfeldt's teaching walkthrough for       %%%
%%% Seidel and Wckerath (2020): Rush hours and urbanization             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First version: Gabriel M Ahlfeldt, 05/2024                            %%%
% Based on original code provided by Tobias Seidel                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This function is not part of the orginal directory                  %%%
%%% This function invertes workplace amenities that rationalize         %%%
%%% observed employment for given wages and commuting costs             %%%
%%% It also saves the conditional commuting probabilities               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [L_n_hat,lambda_ni_n,B_i,uncondCom,comMat]= getBiTK(wage, costmatrix, pop, emp, L)
 % This program uses the following inputs
        % wage is a n x 1 vector of observed vages at the workplace
        % costmatrix is a n by n matrix of bilateral travel cost (km or time or euros)  
        % pop is a n x 1 vector of residence employment
        % emp is a n x 1 vector of workplace employment
        % L is a scalar capturing the total population of the economy
    % This program produces the following outputs
        % L_n_hat is the predicted workplace employment (should match observed employment up to convergence tolerance) 
        % lambda_ni_n are the predicted conditional commuting probabilities
            % that are consistent with the travel time matrix
        % Workplace amenity B_i
        % uncondCom are predicted unconditional commuting probabilities
        % comMat are predicted bilateral commuting flows
    % The names of the inputs need to correspond to objects that exist in
    % the workspace. The names of the outputs can be freely chosen
     
% Define scalars as globals so that they can be read from outside the programme    
    global mu epsi J ;

display('...Quantifying the model...')

% Set counter
x = 1;

% Initial guess of workplace amenities
B_i = ones(J,1);

% Start loop to solve for workplace amenities
while x<=1000 

% Predict employment using conditinal commuting probabilities
transwage = wage';                                                          % Transpose wage vector to 1 x n so that it is assigned to workplaces
lambda_ni_n = repmat(B_i', J, 1).*repmat((transwage).^epsi, J, 1).*costmatrix.^(-epsi.*mu); % compute numerator of conditional commuting probability equation(12) in MRRH
lambda_ni_n = lambda_ni_n ./ sum(lambda_ni_n, 2);                           % Standardize so that the rows sum to one
L_n_hat = lambda_ni_n'*pop;                                                 % Matrix multiplication of conditional commuting probabilites and redidence employment to get workplace employment. Notice that we need to transpose the matrix since we residence/destinations need to be in culmns 
B_i = B_i .* (emp./L_n_hat);                                                % Adjust guess of workplace amenity; increase it if observed emplyoment is larger than predicted employment
obj = sum(abs(emp-L_n_hat)).*100;                                           % Compute objective that we want to minimize 
if obj < 0.001                                                              % Implement stopping rule based on objective
    x = 1000;                                                               % Setting counter to 1000 will end the outer oop
    display('...Employment converged...')
end
x=x+1;
end
% Compute residential choice probability
choiceR = pop./sum(pop);
choiceRmat = repmat(choiceR,1,J);
% Compute unconditional choice probabilities
uncondCom = choiceRmat.*lambda_ni_n;
% Compute commuting flow
comMat = uncondCom.*L;
clf;
scatter(log(L_n_hat),log(emp));                                             % Final visual confirmation that we have matched employment