function T = SetBC(T, DATA, Lw, Lh)

    for i = 1:length(DATA.BC.conditions)
        % Set initial heat source in the middle
        HS_x = round(Lw * DATA.BC.conditions{i}(1));
        HS_y = round(Lh * DATA.BC.conditions{i}(2));
        T(HS_y, HS_x) = DATA.BC.conditions{i}(3);
    
    end

end
