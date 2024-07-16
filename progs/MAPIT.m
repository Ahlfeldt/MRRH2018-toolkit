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
%%% This function is not part of the orginal directory                  %%%
%%% This function merges a county-level outcome to a shapefile of       %%%
%%% counties, generates a map, and saves it at a desired                %%%
%%% destination                                                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This below program uses the following inputs
    % shapefile is the the county shapefile to which the outputs are beign merged
        % variable is the outcome you wish to map  
        % name is the title you wish appear on the map    
        % folder is the location where you wish to save the map
        % filename is the filename of the map to be generated
% The below program produces the following outputs
        % RESULT is a placeholder used to display confirmation of
            % successful cmpletion
        % A map with the desired filename will be saved in the selected
            % folder in png format
function RESULT = MAPIT(shapefile, variable, name, folder, filename)
    % This function generates a map by merging a county-level outcome with a shapefile,
    % and saves it as a PNG file at the specified location.
    
    % Clear existing figures
    clf;
    close all;
    
    % Define the number of colors for the colormap
    numColors = 256; % Typical colormap length
    numCategories = 10; % Number of categories for Jenks natural breaks

    % Create a custom colormap transitioning from yellow to red, with a slightly lighter red for the highest value
    customColormap = [ones(numCategories, 1), linspace(1, 0, numCategories)', zeros(numCategories, 1)];
    customColormap(end, :) = [0.9, 0, 0]; % Slightly lighter red for the highest value
    
    % Read the shapefiles
    SHAPE = shaperead(shapefile); % User-specified shapefile
    STATES = shaperead(fullfile('shape', 'states')); % States shapefile
    
    % Calculate Jenks natural breaks
    breaks = jenks(variable, numCategories);
    
    % Assign each shape to a category based on Jenks breaks
    for i = 1:length(variable)
        SHAPE(i).Category = find(breaks >= variable(i), 1) - 1;
    end
    
    % Define the symbol specifications for the map
    colorRange = makesymbolspec('Polygon', ...
        {'Category', [0 numCategories-1], 'FaceColor', customColormap}, ...
        {'Default', 'EdgeColor', [0.75, 0.75, 0.75], 'LineWidth', 0.1});
    
    % Generate the map
    mapshow(SHAPE, 'Symbolspec', colorRange);
    hold on;
    mapshow(STATES, 'DisplayType', 'polygon', 'EdgeColor', 'k', 'FaceColor', 'none', 'LineWidth', 0.25);
    
    % Add a color bar with equal-sized intervals
    hcb = colorbar;
    colormap(customColormap);
    
    % Adjust color bar ticks and labels
    caxis([0 numCategories]);
    ticks = 0.5:1:numCategories-0.5;
    tickLabels = cell(1, numCategories);
    for k = 1:numCategories
        if k == 1
            tickLabels{k} = sprintf('%.2f - %.2f', min(variable), breaks(k));
        else
            tickLabels{k} = sprintf('%.2f - %.2f', breaks(k-1), breaks(k));
        end
    end
    set(hcb, 'Ticks', ticks, 'TickLabels', tickLabels);
    set(get(hcb, 'Title'), 'String', 'Value');
    
    % Set the title of the map
    title(name);
    
    % Construct the full filename and save the map as a PNG file
    outputFile = fullfile(folder, [filename, '.png']);
    print(gcf, outputFile, '-dpng', '-r600'); % Save as PNG at 600 DPI
    
    % Confirm successful execution
    RESULT = 'Map generated and saved';
end

function breaks = jenks(data, numCategories)
    % JENKS Calculate Jenks natural breaks for data classification.
    %
    % breaks = jenks(data, numCategories) calculates the Jenks natural
    % breaks for the input data vector and the desired number of categories.
    
    data = sort(data);
    mat1 = zeros(length(data), numCategories);
    mat2 = inf(length(data), numCategories);
    
    for i = 1:length(data)
        mat1(i, 1) = sum(data(1:i));
        mat2(i, 1) = sum((data(1:i) - mean(data(1:i))).^2);
    end
    
    for j = 2:numCategories
        for i = j:length(data)
            s1 = 0;
            s2 = 0;
            v = inf;
            for m = i:-1:j
                s1 = s1 + data(m);
                s2 = s2 + data(m) * data(m);
                if m > 1
                    v1 = mat2(m-1, j-1);
                else
                    v1 = 0;
                end
                v2 = s2 - (s1 * s1) / (i - m + 1);
                if (v1 + v2) < v
                    mat1(i, j) = m;
                    mat2(i, j) = v1 + v2;
                    v = v1 + v2;
                end
            end
        end
    end
    
    k = length(data);
    breaks = zeros(numCategories, 1);
    breaks(end) = data(end);
    for j = numCategories-1:-1:1
        id = mat1(k, j+1) - 1;
        breaks(j) = data(id);
        k = id;
    end
end


% Code ends 