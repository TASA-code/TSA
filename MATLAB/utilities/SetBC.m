function T = SetBC(T, DATA, Lw, Lh)
    % Assuming x and y are vectors representing coordinates
    [numRows, numCols] = size(T);
    x = linspace(0, Lw, numCols);
    y = linspace(0, Lh, numRows);
    
    % Create a meshgrid of x and y coordinates
    [X, Y] = meshgrid(x, y);
    
    for i = 1:length(DATA.BC.conditions)
        % Set initial heat source in the middle
        x_start = round(Lw * DATA.BC.conditions{i}(1));
        x_end   = round(Lw * DATA.BC.conditions{i}(2));
        
        y_start = round(Lh * DATA.BC.conditions{i}(3));
        y_end   = round(Lh * DATA.BC.conditions{i}(4));
        
        % Create logical indices for the specified conditions
        logicalIndex = (X >= x_start & X <= x_end) & (Y >= y_start & Y <= y_end);
        
        % Assign the value to the elements of T that meet the condition
        T(logicalIndex) = DATA.BC.conditions{i}(5);
    end
end