function [tradesh,tradeshOwn,P_n]= getTradesharesTK(product, empl, wage, tradec)
    % Compute matrix of bilateral tradeshares from location specific
    % productivities *product*, employment *empl*, regional wages *wage*,
    % bilateral tradecosts *tradec* and the substitution elasticity parameter
    % *sigg*.
  
% Make scalars from outside the programme accessible
    global sigg nu fixC


    rrho = nu;
    
    % Initialize
    nobs = length(product);

    % Rounding precision
    tol = 6;

    % Calculate the part of the numerator in the tradeshare equation without
    % tradecosts.
    num = product.^(sigg - 1) .* empl.^(1-(1-sigg).*rrho) .* wage.^(1 - sigg);
    % Matrix representation of the entire numerator. Note that in order to
    % correctly multiply the vector num with the tradecosts matrix we need to
    % replicate it so that it has the same dimension as the matrix.
    num = repmat(num, 1, nobs);
    nummat = tradec.^(1 - sigg) .* num;

    % The denominator is simply the sum over all rows in a column of the
    % numerator matrix. To again expand it to a size of nobs x nobs we need to
    % kindly ask repmat again.
    denom = sum(nummat);
    denommat = repmat(denom, nobs, 1);

    % Calculate matrix of tradeshares by piecewise division.
    tradesh = nummat./denommat;

    % Check if all tradeshares sum up to 1
    colsum = round(sum(tradesh, 1), tol);
    if ~(sum(colsum) == length(colsum))
        error('Tradeshares do not sum up to 1!');
    end

    % Onw tradeshare
    tradeshOwn = diag(tradesh);
    % Price index
    P_n = sigg./(sigg-1).*(empl./(sigg.*fixC.*tradeshOwn)).^(1./(1-sigg)).*(wage./product);
end
