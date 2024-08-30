function ThermalDiff(DATA)

    % Initializing all conditions pertaining the the function
    % Width
    w = DATA.MODEL.W;
    dw = DATA.SETTINGS.dW;
    Lw = round(w/dw);
    
    % Height
    h = DATA.MODEL.L;
    dh = DATA.SETTINGS.dL;
    Lh = round(h/dh);
    
    % Timestep
    dt = DATA.SETTINGS.dt;
    T_sim = DATA.SETTINGS.simT;

    % Thermal conductivity (m^2/s)
    % Aluminium
    a = DATA.MODEL.alpha;
    
    % Meshgrid setup
    x = linspace(0,w,Lw);
    y = linspace(0,h,Lh);
    [X, Y] = meshgrid(x,y);    



    % Boundary conditions
    T = ones(Lh,Lw) * DATA.BC.T_0;
    T = SetBC(T, DATA, Lw, Lh);

    % Run the function for each time interval
    for t = 0:dt:T_sim

        T_new = T; % Create a copy of T to update values

        for i = 2:Lw-1
            for j = 2:Lh-1
                term1 = (T(j, i-1) - 2*T(j,i) + T(j, i+1));
                term2 = (T(j-1, i) - 2*T(j,i) + T(j+1, i));
                T_new(j, i) = T(j, i) + a * dt * ((term1 / dw^2) + (term2 / dh^2));   
            end
        end


        T = T_new; % Update T with the new values

        if DATA.SETTINGS.opt == 1
            T = SetBC(T, DATA, Lw, Lh);
        end

    end


    % close(writerObj)

    figure();
    set(gcf, 'Position', [485,428,939,472])
    sgtitle(['Temperature function after ', num2str(T_sim), ' sec']);


    % subplot(2,4,[1,2,5,6])
    % surf(X,Y,T)
    % grid minor
    % colorbar
    % colormap("jet")
    % view([10.7092,28.5708])

    % subplot(2,4,[3,4,7,8])
    contourf(X,Y,T,60)
    grid minor
    colorbar
    colormap("jet")
    % Legend and label
    xlabel('Plate width');
    ylabel('Plate height');
    zlabel('Temperature (K)');
    axis equal
    saveas(gcf, 'output/result.png')

end