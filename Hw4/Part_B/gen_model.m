clear

%% variable declarations
%
syms x y theta phi real
syms x_d y_d theta_d phi_d real
syms x_dd y_dd theta_dd phi_dd real
syms omega_0 v_0 theta_0 gamma beta real
syms m_1 m_2 l h J_1 J_2 R real
syms g real

%% generalized coordinates
%
q = [x; y; theta; phi];
dq = [x_d; y_d; theta_d; phi_d];
ddq = [x_dd; y_dd; theta_dd; phi_dd];

N=max(size(q));

%% position, velocity of the center of mass
%
p_cm_horse = [x + h*sin(theta); y - h*cos(theta)];
p_cm_pendulum = [x + l*sin(phi); y - l*cos(phi)];
m = m_1 + m_2;
p_cm_sys = (m_1*p_cm_horse + m_2*p_cm_pendulum)/m;
v_cm_sys = jacobian(p_cm_sys, q)*dq;

%% kinetic energy and ﻿potiential energy 
%
KE = simplify(m/2)*(v_cm_sys'*v_cm_sys + (1/2)*J_1*theta_d^2 + (1/2)*J_2*phi_d^2);
PE = m*g*p_cm_sys(2);

%% Constraints 
%
p_contact_point = [p_cm_sys(1); p_cm_sys(2) - R];  % Contact point
h = p_contact_point(1);
f = p_contact_point(2);

W = jacobian(h, q);

num_constraints = 2;
num_dof = 4;

W_d = sym(zeros(num_constraints, num_dof));
for i = 1:num_constraints
    for j = 1:num_dof
            W_d(i, j) = jacobian(W(i, j), q)*dq;
    end
end

%% M*ddq + C*dq + G = F + W^T*lambda
% M

M=simplify(jacobian(jacobian(KE,dq).',dq));

%%
syms C
for k=1:N
    for j=1:N
        C(k,j)=0;
        for i=1:N
	        C(k,j)=C(k,j)+1/2*(diff(M(k,j),q(i)) + diff(M(k,i),q(j)) - diff(M(i,j),q(k)))*dq(i);
        end
    end
end
B = C*dq;

%%
%
G = simplify(jacobian(PE, q))';

%%

lambda_th_d = simplify(inv(W*inv(M)*W.')*(W*inv(M)*(B + G) - W_d*dq));
% eq = subs(KE, {x_d, y_d}, {v_0, -l*sin(theta)*theta_d}) + subs(PE, {y}, {l*cos(theta)}) - subs(KE, {theta_d, x_d, y_d}, {omega_0, v_0, 0}) - m*g*l*cos(theta_0);
% theta_d_sol = solve(eq, theta_d);
% lambda_th = simplify(subs(lambda_th_d, theta_d, theta_d_sol(1)));
% subs(lambda_th, {omega_0, I_c}, {gamma*g/l, beta*m*l^2})