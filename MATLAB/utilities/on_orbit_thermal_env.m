%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   on_orbit_thermal_env.m
%
%
%   This code is about simulating the thermal environment of a on-orbit
%   satellite. With the parameters below, you can generate the temperature
%   variation of a spherical satellite every minute over the span of the
%   year. The output can also be the beta angle, Q_dot_..., or q_dot_...,
%   depending on whatever you need. Note that Q_dot and q_dot represent the
%   power (Watt) and intensity (W/m^2) of the heat sources, respectively.
%
%   Input:
%        h: Height, km
%        i_deg: Inclination, deg
%        RAAN_deg: Right Ascension of the Ascending Node, deg
%        nu_deg: True Anomaly w.r.t. Vernal Equinox, deg
%        r_sat: Radius of Satellite, m
%        alpha: Absorptivity
%        rho: Earth's Albedo
%        epsilon: Emissivity
%        Q_dot_dis: Dissipation, W
%
%   Output:
%        Temp: Temperature, K
%        beta_...(rad/deg): beta angle, rad or deg
%        Q_dot_...(sol/alb/pla/dis): solar/albedo/planet/dissipation, W
%        q_dot_...(sol/alb/pla): solar/albedo/planet, W/m^2
%
%   You can also adjust the time information of the scenario to obtain
%   results for other years by the following parameters:
%
%        start_time: (yyyy, mm, dd, hh, minmin, ss)
%        end_time: (yyyy, mm, dd, hh, minmin, ss)
%        perihelion: time of Earth's perihelion in the year
%        vernal_equinox: time of the vernal equinox in the year
%
%
%
%
%   Copyright (C) System Engineering (SE), TASA - All Rights Reserved
%
%   Written by Braeburn Shen 沈柏勳
%   <shiun@tasa.org.tw>, <930513shiun@gmail.com>
%   30 August 2024.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc, clear all;

% input
h = 601;
i_deg = 97.92;
RAAN_deg = 0;
nu_deg = 0;
r_sat = 0.6;
alpha = 0.05;
rho = 0.3;
epsilon = 0.04;
Q_dot_dis = 60;

% scenario time setting
start_time = datetime(2024, 1, 1, 0, 0, 0);
end_time = datetime(2025, 1, 1, 0, 0, 0);
perihelion = datetime(2024, 1, 3, 0, 39, 0);
vernal_equinox = datetime(2024, 3, 20, 3, 6, 0);
time = start_time:minutes(1):end_time; % time series
t_relat_start = minutes(time-start_time); % compute the duration from the start time
t_relat_peri = minutes(time-perihelion); % compute the duration from the perihelion
t_relat_vernal = minutes(time-vernal_equinox); % compute the duration from the vernal equinox

% define parameter (using SI unit)
S = 1367; % solar constant
e = 0.0167; % eccentricity of Earth's orbit 
nu_earth_dot = 2*pi/numel(time); % time derivative of nu_earth
nu_earth = nu_earth_dot.*t_relat_peri; % true anomaly of Earth
gamma = (2*pi/numel(time))*t_relat_vernal; % ecliptic true solar longitude
delta_epsilon = deg2rad(23.45); % obliquity of the ecliptic
i_rad = deg2rad(i_deg);
J2 = 1.0826e-3; % J2 term from Legendre polynomials
mu = 3.9860e14; % standard gravitational parameter of Earth
Re = 6.3781e6; % Earth radius
a = Re+h*1000; % orbit semi-major axis
n = sqrt(mu/a^3)*(1+3/4*J2*Re^2/a^2*(2-3*sin(i_rad)^2)); % mean motion
OMEGA = deg2rad(RAAN_deg)+(-3/2)*J2*Re^2/a^2*n*cos(i_rad)*60*t_relat_start; % RAAN
T = sqrt(4*pi^2*(h*1000+Re)^3/mu); % period
theta_dot = 2*pi/(T/60); % time derivative of theta
A_tot = 4*pi*r_sat^2; % total surface area of spherical satellite
sigma = 5.67e-8; % Stefan-Boltzmann constant
beta_rad = asin(cos(gamma).*sin(OMEGA)*sin(i_rad)-sin(gamma)*cos(delta_epsilon).*cos(OMEGA)*sin(i_rad)+sin(gamma)*sin(delta_epsilon)*cos(i_rad)); % beta angle
beta_deg = rad2deg(beta_rad);
nu_sat_dot = 2*pi/(T/60); % time derivative of nu_sat
nu_sat = mod(deg2rad(nu_deg)+nu_sat_dot*t_relat_vernal, 2*pi); % true anomaly of satellite w.r.t. vernal equinox
theta_cri = asin(sqrt((cos(beta_rad)).^(-2).*((Re/(Re+h*1000))^2-(sin(beta_rad)).^2))); % critical theta
cood_rot = (2*pi/525960)*t_relat_vernal; % coordinate rotation w.r.t. vernal equinox
theta = mod(nu_sat-cood_rot, 2*pi); % angle between the satellite's position and solar vector project onto orbital plane
theta(theta>pi-theta_cri & theta<pi+theta_cri) = NaN;

% compute solar flux
r = (1-e^2)./(1+e*cos(nu_earth)); % Earth's position
q_dot_sol = S./r.^2;
q_dot_sol(isnan(theta)) = 0;
A_proj_sun = pi*r_sat^2; % projected area of the satellite from Sun
Q_dot_sol = q_dot_sol*A_proj_sun;

% compute albedo flux
H = (h*1000+Re)/Re;
xi = acos(cos(beta_rad).*cos(theta));
x_m = acos(1/H);
delta = pi-2*x_m;
A_cap = 2*pi*r_sat^2*(1-cos(delta/2)); % area of spherical cap of the satellite as seen from Earth
q_dot_alb = zeros(size(xi));

f_b = @(x, xi) ((H*cos(x)-1).*cos(xi).*sin(x).*cos(x)./(H^2+1-2*H*cos(x)).^(1.5)).*acos(-cot(x).*cot(xi));
f_c = @(x, xi) (H*cos(x)-1).*sin(x).*(sin(x).^2-cos(xi).^2).^(1/2)./(H^2+1-2*H*cos(x)).^(1.5);
f_d = @(x, xi) ((H*cos(x)-1).*cos(xi).*sin(x).*cos(x)./(H^2+1-2*H*cos(x)).^(1.5)).*acos(-cot(x).*cot(xi));
f_e = @(x, xi) (H*cos(x)-1).*sin(x).*(sin(x).^2-cos(xi).^2).^(1/2)./(H^2+1-2*H*cos(x)).^(1.5);

for N = 1:length(xi)
    if xi(N) >= 0 && xi(N) <= pi/2-x_m
        F(N) = (2/3)*((2*H+1/H^2)-(2+1/H^2)*(H^2-1)^(0.5))*cos(xi(N));
        q_dot_alb(N) = S*rho*F(N);
    elseif xi(N) > pi/2-x_m && xi(N) <= pi/2
        A(N) = (2/3)*cos(xi(N))*(((1+1/H^2)*(-2*H^2+1)+(2*H-1/H)*sin(xi(N))+sin(xi(N)).^2)./sqrt(H^2+1-2*H*sin(xi(N)))+1/H^2+2*H);
        B(N) = (2/pi)*integral(@(x) f_b(x, xi(N)), pi/2-xi(N), x_m);
        C(N) = (2/pi)*integral(@(x) f_c(x, xi(N)), pi/2-xi(N), x_m);
        q_dot_alb(N) = S*rho*(A(N)+B(N)+C(N));
    elseif xi(N) > pi/2 && xi(N) <= pi/2+x_m
        D(N) = (2/pi)*integral(@(x) f_d(x, xi(N)), xi(N)-pi/2, x_m);
        E(N) = (2/pi)*integral(@(x) f_e(x, xi(N)), xi(N)-pi/2, x_m);
        q_dot_alb(N) = S*rho*(D(N)+E(N));
    else
        q_dot_alb(N) = 0;
    end
end

Q_dot_alb = q_dot_alb*A_cap;

% compute planet emission
Q_dot_pla = 0.5*pi*r_sat^2*S*(1-rho)*(1-cos(delta/2))*(1-sqrt(2*Re*h*1000+(h*1000)^2)/(Re+h*1000));
q_dot_pla = Q_dot_pla/A_cap;

% apply Stefan-Boltzmann law
Temp = ((((Q_dot_sol+Q_dot_alb)*alpha+Q_dot_dis)/epsilon+Q_dot_pla)/(sigma*A_tot)).^0.25;

% output
figure;
plot(time, Temp, 'LineWidth', 1.5, 'Color', [0/255, 43/255, 138/255]);
xlabel('');
ylabel('');
title('')
datetick('x', 'mmm yyyy', 'keepticks');
grid on;