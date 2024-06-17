function T = SetBC(T, DATA, Lw, Lh)
    % Assuming x and y are vectors representing coordinates
    [numRows, numCols] = size(T);
    x = linspace(0, Lw, numCols);
    y = linspace(0, Lh, numRows);
    
    % Create a meshgrid of x and y coordinates
    [X, Y] = meshgrid(x, y);
    
    for i = 1:length(DATA.BC.conditions)

        x_coor = DATA.BC.conditions{i}(1);
        y_coor = DATA.BC.conditions{i}(2);
        len    = DATA.BC.conditions{i}(3);
        width  = DATA.BC.conditions{i}(4);

        % Set initial heat source in the middle
        x_start = round(Lw*(x_coor - 0.5*len));
        x_end   = round(Lw*(x_coor + 0.5*len));
        
        y_start = round(Lh*(y_coor - 0.5*width));
        y_end   = round(Lh*(y_coor + 0.5*width));
        
        % Create logical indices for the specified conditions
        logicalIndex = (X >= x_start & X <= x_end) & (Y >= y_start & Y <= y_end);
        

        material = {};
        material.index = i;
        material.area  = len * width;
        material.location = logicalIndex;

        T(logicalIndex) = ThermalCond(material, DATA, T);
     
        % Assign the value to the elements of T that meet the condition
        % T(logicalIndex) = DATA.BC.conditions{i}(6);
    end
end