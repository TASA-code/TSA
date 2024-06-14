clc
clear
close all
 

% Initializing all conditions pertaining the the function
% Width
w = 2;
dw = 0.05;
Lw = w/dw;
 

% Height
h = 2;
dh = 0.05;
Lh = h/dh;
 
% Timestep
dt = 0.1;
T_sim = 120;

% Thermal conductivity (m^2/s)
% Aluminium
a = 9.7e-5;
 
% Boundary conditions
T = ones(Lh,Lw) * 393.15;
 

% Set initial heat source in the middle
hp1_x = round(Lw / 2)-9;
hp1_y = round(Lh / 2)-7;
T(hp1_y, hp1_x) = 500;
 

hp2_x = round(Lw / 2)+9;
hp2_y = round(Lh / 2)+7;
T(hp2_y, hp2_x) = 500;

hp3_x = round(Lw / 2);
hp3_y = round(Lh / 2);
T(hp3_y, hp3_x) = 700;





% Meshgrid setup
x = linspace(0,w,40);
y = linspace(0,h,40);
[X, Y] = meshgrid(x,y);

% filename = 'result.mp4';
% writerObj = VideoWriter(filename, 'MPEG-4');
% open(writerObj);

% figure;
% fig1 = subplot(2,4,1:4);
% fig2 = subplot(2,4,5:8);


% Run the function for each time interval
for t = 0:dt:T_sim
    T_new = T; % Create a copy of T to update values
    for i = 2:Lw-1
        for j = 2:Lh-1
            term1 = (T(j, i-1) - 2*T(j,i) + T(j, i+1));
            term2 = (T(j-1, i) - 2*T(j, i) + T(j+1, i));
            T_new(j, i) = T(j, i) + a * dt * ((term1 / dw^2) + (term2 / dh^2));       
        end
    end
    T = T_new; % Update T with the new values

    T(hp1_y, hp1_x) = 500;
    T(hp2_y, hp2_x) = 500;
    T(hp3_y, hp3_x) = 500;


    % subplot(fig1);
    % surf(T)
    % colorbar
    % grid minor
    % title(num2str(t))
    % view([10.7092,28.5708])

    % subplot(fig2);
    % contourf(X,Y,T)
    % colorbar
    % grid minor
    % xlabel('Plate width');
    % ylabel('Plate height');
    % zlabel('Temperature (K)');


    % frame = getframe(gcf);
    % writeVideo(writerObj, frame);

    % drawnow;

end


% close(writerObj)

 

% Display Result
figure()
contourf(X,Y,T)
grid minor
colorbar
 
figure()
surf(T)
grid minor
colorbar
view([10.7092,28.5708])
 
% Legend and label
xlabel('Plate width');
ylabel('Plate height');
zlabel('Temperature (K)');
legend(['Temperature function after ', num2str(T_sim), ' sec'], 'Location', 'NorthEast');
