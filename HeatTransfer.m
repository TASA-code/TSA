clc
clear
close all
 

% Initializing all conditions pertaining the the function
% Width
w = 2;
dw = 0.05;
Lw = w/dw;
 

% Height
h = 1;
dh = 0.05;
Lh = h/dh;
 

% Timestep
dt = 0.1;
 

% Thermal conductivity (m^2/s)
% Aluminium
a = 9.7e-5;
 

% Boundary conditions
T = ones(Lh,Lw);
T = T * 273;
 

% Set initial heat source in the middle
hp1_x = round(Lw / 2)-9;
hp1_y = round(Lh / 2)-7;
T(hp1_y, hp1_x) = 900;
 

hp2_x = round(Lw / 2)+9;
hp2_y = round(Lh / 2)+7;
T(hp2_y, hp2_x) = 900;



 

% Meshgrid setup
x = linspace(0,w,40);
y = linspace(0,h,20);
[X, Y] = meshgrid(x,y);
 

% Run the function for each time interval
for t = 0:dt:600
    T_new = T; % Create a copy of T to update values
    for x = 2:Lw-1
        for y = 2:Lh-1
            term1 = (T(y, x-1) - 2*T(y, x) + T(y, x+1));
            term2 = (T(y-1, x) - 2*T(y, x) + T(y+1, x));
            T_new(y, x) = T(y, x) + a * dt * ((term1 / dw^2) + (term2 / dh^2));       
        end
    end
    T = T_new; % Update T with the new values

    T(hp1_y, hp1_x) = 900;
    T(hp2_y, hp2_x) = 900;
end
 

 

% Display Result
 

figure()
contourf(X,Y,T)
grid minor
colorbar
 

figure()
surf(T)
grid minor
colorbar
view([-60 27.0])
 

% Legend and label
xlabel('Plate width');
ylabel('Plate height');
zlabel('Temperature (K)');
legend('Tempurature function after 3 sec', 'Location', 'NorthEast');