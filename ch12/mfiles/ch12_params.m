function P = ch12_params()
%CH12_PARAMS  Case-study plant and SIMC PI tuning for Chapter 12.
%   G(s) = 1.2 e^{-30 s} / (150 s + 1),  SIMC with lambda = theta.
%   Returns a struct used by every ch12_*.m script.
%
%   01068007 Control Systems -- Chapter 12 PID Control Enhancement
%   Assoc. Prof. Dr. Arjin Numsomran, KMITL

P.K     = 1.2;          % process gain
P.tau   = 150;          % time constant (s)
P.theta = 30;           % dead time (s)
P.lam   = P.theta;      % SIMC closed-loop time constant

% SIMC PI (Skogestad 2003)
P.Kp = P.tau/(P.K*(P.lam + P.theta));          % 2.0833
P.Ti = min(P.tau, 4*(P.lam + P.theta));        % 150 s
P.Ki = P.Kp/P.Ti;                              % 0.013889

% Simulation settings (forward Euler, same as gen_ch12_data.py)
P.dt = 0.02;            % integration step (s)
end
