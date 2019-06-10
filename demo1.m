%%
clear all;
close all;
clc;

%% See Table I from the paper
sigma_0 = 1e5;
sigma_1  = sqrt(1e5);
sigma_2  = 0.4;
Fc = 1;
Fs = 1.5;
vs = 0.001;

%%
ts = 1e-6;
time_span = 0.1;
t = 0 : ts : time_span;

%% Velocity range
v = -0.005:0.0001:0.005;

%%
for i = 1 : length(v)
    z = 0;
    for j = 1 : length(t)
        [F(j), z] = lugref(z, v(i), Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
    end
    Fss(i) = F(end);
end

plot(v, Fss)
grid
xlabel('Velocity (m/s)')
ylabel('Friction force (N)')
title('Friction force at steady state condition')

%% Zoom into certain velocity to see its transient behaviour
clear F v;
v = 0.002;
z = 0;
for j = 1 : length(t)
    [F(j), z] = lugref(z, v, Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
end

figure
plot(t, F);
grid
xlabel('Time (s)')
ylabel('Friction force (N)')
title('Friction force for v = 0.002')

%% Apply sinusoidal velocity and measure the friction force (Fig. 3 of the paper)
figure
hold on
color = ['rgb'];
clear F v;
t = 0 : ts : 10;
omega = [1 10 25];
for i = 1 : length(omega)
    z = 0;
    v = 0.001 * (sin(omega(i)*t)+1.5);
    for j = 1 : length(t)
        [F(j), z] = lugref(z, v(j), Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
    end
    % Start from t = 3 up to the end
    plot(v(3*1/ts:end), F(3*1/ts:end), color(i));
end

grid
xlabel('Velocity (m/s)')
ylabel('Friction force (N)')
title('Hysteresis in friction with varying velocity')
legend('1 rad/s', '10 rad/s', '25 rad/s')

%% Stick Slip motion of a block pulled by a spring (Fig. 6 of the paper)
clear F v;
k = 2.0;
M = 1.0;
tmax = 25;
t = 0 : ts : tmax;
F = zeros(1, length(t));
v = zeros(1, length(t));
x = zeros(1, length(t));
y = 0.1 * t;
z = 0;
for j = 1 : length(t) - 1
    % compute friction force
    [F(j + 1), z] = lugref(z, v(j), Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
    % compute block motion
    v_dot = (k*(y(j) - x(j)) - F(j))/M;
    v(j + 1) = v(j) + v_dot * ts;
    x(j + 1) = x(j) + v(j + 1) * ts;
end

figure
subplot(2, 1, 1)
hold on
plot(t, x)
plot(t, y)
legend('x', 'y', 'Location', 'northwest')
xlabel('Time (s)')
ylabel('Position (m)')
axis([0, tmax, 0, 4])
grid

subplot(2, 1, 2)
hold on
plot(t, F)
plot(t, v)
legend('F', 'dx/dt', 'Location', 'northwest')
xlabel('Time (s)')
ylabel({'Friction Force (N)', 'Velocity (m/s)'})
sgtitle('Simulation of stick-slip motion') % requires 2018b
axis([0, tmax, 0, 2])
grid