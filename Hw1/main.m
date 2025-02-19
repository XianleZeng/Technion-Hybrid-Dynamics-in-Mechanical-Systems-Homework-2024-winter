clear;
close all;

%% Solve DAE
%
options = odeset('RelTol', 1e-8, 'AbsTol', 1e-8);
tspan = 0:0.05:40;  
X0 = [0; 0; 0; 0; 0; 0];             
[t, X] = ode45(@state_eq, tspan, X0, options); 

%% Input angles phi1 ,phi2
%
phi_data = [];
phi_d_data = [];
for i = 1:length(t)
    [phi, phi_d, ~] = angles_input(t(i)); 
    phi_data = [phi_data, phi];
    phi_d_data = [phi_d_data, phi_d];
end
phi1 = phi_data(1,:)';
phi2 = phi_data(2,:)';
phi1_d = phi_d_data(1,:)';
phi2_d = phi_d_data(2,:)';

%% Reassign the variables
%
x = X(:, 1);
y = X(:, 2);
theta = X(:, 3);
x_d = X(:, 4);
y_d = X(:, 5);
theta_d = X(:, 6);
q = [x, y, theta, phi1, phi2];
q_d = [x_d, y_d, theta_d, phi1_d, phi2_d];
qb = [x, y, theta];
qb_d = [x_d, y_d, theta_d];
w = 1; %% Not sure, need to check!
[m, l, g]=model_params;

%% Center of mass
%
p_cm_data = [];
v_cm_data = [];
for i = 1:length(t)
    [p_cm, v_cm] = center_of_mass(q(i,:), q_d(i,:));
    p_cm_data = [p_cm_data, p_cm];
    v_cm_data = [v_cm_data, v_cm];
end
x_cm = p_cm_data(1,:);
y_cm = p_cm_data(2,:);

%% Torque and qb_dd
%
tau_data = [];
qb_dd_data = [];
for i = 1:length(t)
    [qb_dd, tau]=dyn_sol(qb(i,:)',qb_d(i,:)',t(i));
    tau_data = [tau_data, tau];
    qb_dd_data = [qb_dd_data, qb_dd];
end
theta_dd = qb_dd_data(3,:)';

%% Angular Momentum
%
H_total_data = [];
for i = 1:length(t)
    H_total_data = [H_total_data, Total_angular_momentum(q(i,:), q_d(i,:), t(i))];
end

%% Theta_d form angular momentum
%
th_d_H_data = [];
for i = 1:length(t)
    th_d_H_data = [th_d_H_data, theta_d_H(q(i,:), q_d(i,:))];
end

%%  
%
th_dd_H_data = [];
for i = 1:length(t)
    th_dd_H_data = [th_dd_H_data, theta_dd_H(q(i,:), q_d(i,:), t(i))];
end

%% Plot the angle of middle link 
%
figure;
hold on;
plot(t, rad2deg(theta), 'LineWidth', 4);
xlabel('Time (t) [s]', 'Interpreter', 'latex');
ylabel('$\theta(t)$ [deg]', 'Interpreter', 'latex');
grid on;
set(gca, 'FontSize', 14);
% axis tight;
saveas(gcf, 'images/a.png');

%% Figure for horizontal position of the middle link's center x(t)/l 
% With center-of-mass position x_cm(t)/l
%
figure;
hold on;
l = 0.1;
plot(t, x/l, 'LineWidth', 3, 'DisplayName', '$\frac{x(t)}{l}$');
hold on
plot(t, x_cm/l, '--', 'LineWidth', 3, 'DisplayName', '$\frac{x_c(t)}{l}$');
xlabel('Time (t) [s]', 'Interpreter', 'latex');
ylabel('Normalized horizontal position [m/m]', 'Interpreter', 'latex');
lgd = legend;  
lgd.Interpreter = 'latex';  
lgd.FontSize = 25;  
grid on;
set(gca, 'FontSize', 14);
% axis tight;
saveas(gcf, 'images/b.png');

%% Figure for horizontal velocity of the middle link's center x_dot(t)/lw 
% With center-of-mass position x_dot_cm(t)/lw
% Need to plot: H(t)/ml^2w
%
figure;
hold on;
l = 0.1;
plot(t, x_d/(l*w), 'LineWidth', 3, 'DisplayName', '$\frac{\dot{x}(t)}{l \omega}$');
hold on
plot(t, v_cm_data(1,:)'/(l*w), '-', 'LineWidth', 3, 'DisplayName', '$\frac{\dot{x}_c(t)}{l \omega}$');
hold on
plot(t, H_total_data/(m*l^2*w), '--', 'LineWidth', 3, 'DisplayName', '$\frac{H_c(t)}{ml^2 \omega}$');
xlabel('Time (t) [s]', 'Interpreter', 'latex');
ylabel('Normalized horizontal velocity $[\frac{m/s}{m/s}]$', 'Interpreter', 'latex');
lgd = legend;  
lgd.Interpreter = 'latex';  
lgd.FontSize = 25;  
grid on;
set(gca, 'FontSize', 14);
% axis tight;
saveas(gcf, 'images/c.png');

%% Figure for vertical velocity of the middle link's center y_dot(t)/lw 
% With center-of-mass position y_dot_cm(t)/lw
%
figure;
hold on;
l = 0.1;
plot(t, y_d/l, 'LineWidth', 3, 'DisplayName', '$\frac{\dot{y}(t)}{l \omega}$');
hold on
plot(t, v_cm_data(2,:)'/(w*l), '--', 'LineWidth', 3, 'DisplayName', '$\frac{\dot{y}_c(t)}{l \omega}$');
xlabel('Time (t) [s]', 'Interpreter', 'latex');
ylabel('Normalized vertical velocity $[\frac{m/s}{m/s}]$', 'Interpreter', 'latex');
lgd = legend;  
lgd.Interpreter = 'latex';  
lgd.FontSize = 25;  
grid on;
set(gca, 'FontSize', 14);
% axis tight;
saveas(gcf, 'images/d.png');

%% Torques
%
figure;
hold on;
plot(t, tau_data(1,:), 'LineWidth', 3, 'DisplayName', '$\tau_1$')
hold on;
plot(t, tau_data(2,:), 'LineWidth', 3, 'DisplayName', '$\tau_2$')
xlabel('Time (t) [s]', 'Interpreter', 'latex');
ylabel('Torque [Nm]', 'Interpreter', 'latex');
lgd = legend;  
lgd.Interpreter = 'latex';  
lgd.FontSize = 25;  
grid on;
set(gca, 'FontSize', 14);
% axis tight;
saveas(gcf, 'images/f.png');

%%  Normalized angular velocity
% 
figure;
hold on;
plot(t, theta_d/w, 'LineWidth', 3, 'DisplayName', '$\frac{\dot{\theta}(t)}{\omega}$')
hold on;
plot(t, th_d_H_data'/w, '--', 'LineWidth', 3, 'DisplayName', '$\frac{\dot{\theta}(t)}{\omega}\,(H_c(t) = 0)$')
xlabel('Time (t) [s]', 'Interpreter', 'latex');
ylabel('Normalized angular velocity $[\frac{1/s}{1/s}]$', 'Interpreter', 'latex');
lgd = legend;  
lgd.Interpreter = 'latex';  
lgd.FontSize = 20;  
grid on;
set(gca, 'FontSize', 14);
% axis tight;
saveas(gcf, 'images/e.png');

%%  Normalized angular acceleration
%
figure;
hold on;
plot(t, theta_dd/w, 'LineWidth', 3, 'DisplayName', '$\frac{\ddot{\theta}(t)}{\omega^2}$')
hold on;
plot(t, th_dd_H_data/w, '--', 'LineWidth', 3, 'DisplayName', '$\frac{\ddot{\theta}(t)}{\omega^2}$')
xlabel('Time (t) [s]', 'Interpreter', 'latex');
ylabel('Normalized angular acceleration $[\frac{1/s^2}{1/s^2}]$', 'Interpreter', 'latex');
lgd = legend;  
lgd.Interpreter = 'latex';  
lgd.FontSize = 25;  
grid on;
set(gca, 'FontSize', 14);
axis tight;
saveas(gcf, 'images/g.png');

%% Animation
% animation(t,X);