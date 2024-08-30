function temp = ThermalCond(material, PLATE, T)

    i = material.index;
    material.thick = PLATE.BC.conditions{i}(5);

    % Define material thermal conductivity
    material.temp = PLATE.BC.conditions{i}(6);
    material.k = PLATE.BC.conditions{i}(7);

    % thermal resistance of the component
    material.R = material.thick / (material.k * material.area);


    % Thermal contact conductance
    conductance = 2000;
    R_contact = 1 / (conductance * material.area);

    %  (steel plate) resistance
    R_steel = PLATE.MODEL.thick / (PLATE.MODEL.k * material.area);

    % Calculate the total thermal resistance
    R_total = material.R + R_contact + R_steel;


    material.Tinit = PLATE.BC.conditions{i}(6);

    % Calculate the initial temperature diff.
    delta_T = material.Tinit - T(material.location);

    % Calculate the heat transfer rate 
    Q = delta_T/R_total;


    delta_T_Total = Q * (R_contact + material.R);

    temp = material.Tinit - delta_T_Total;


    % TODO 
    % Check the validity of transient and steady state
    % does it matche the assumption? 


end