%% ch12_08_digital.m -- Section 12.10: digital implementation
%  * Exercise 12.11: velocity-form PI by hand
%  * ZOH half-sample delay: PM loss ~ wgc*Ts/2
%  * sampled velocity-form PI on the case study for several Ts
clear; clc;
P = ch12_params();

%% Exercise 12.11
Kp = 2; Ti = 20; Ts = 1; e = [0 1 0.8 0.5]; u = 0;
fprintf('Ex 12.11 velocity form (Kp=2, Ti=20, Ts=1):\n');
for k = 2:numel(e)
    du = Kp*((e(k)-e(k-1)) + Ts/Ti*e(k));  u = u + du;
    fprintf('  k = %d: du = %+.4f, u = %.4f\n', k-1, du, u);
end

%% PM erosion from ZOH, wgc = 1/(lam+theta)
wgc = 1/(P.lam+P.theta); PM0 = 90 - rad2deg(P.theta*wgc);
fprintf('\nZOH estimate (PM0 = %.2f deg, wgc = %.5f rad/s):\n',PM0,wgc);
for Ts = [1 5 10 20]
    fprintf('  Ts = %4.1f s: wgc*Ts = %.3f, PM loss = %.2f deg, PM = %.2f deg\n', ...
        Ts, wgc*Ts, rad2deg(wgc*Ts/2), PM0 - rad2deg(wgc*Ts/2));
end

%% Sampled velocity-form PI, eq. (12.23), with output clamp (built-in anti-windup)
Tlist = [1 5 10 20]; Tend = 900; dt = P.dt;
figure('Name','Ch12 digital PI'); hold on;
for Ts = Tlist
    n = floor(Tend/dt)+1; t = (0:n-1)'*dt; nd = round(P.theta/dt);
    ubuf = zeros(n+nd+1,1); x = 0; uk = 0; ek1 = 0; y = zeros(n,1);
    every = round(Ts/dt);
    for k = 1:n
        y(k) = x;
        if mod(k-1,every) == 0                         % sampling instant
            ek = 1 - x;                                 % b = 1, unit setpoint
            uk = uk + P.Kp*((ek-ek1) + Ts/P.Ti*ek);
            uk = min(max(uk,-10),10);                   % clamp
            ek1 = ek;
        end
        ubuf(k+nd) = uk;                                % ZOH between samples
        x = x + dt*(-x + P.K*ubuf(k))/P.tau;
    end
    fprintf('  sampled PI Ts = %4.1f s: Mp = %.2f %%\n', Ts, 100*max(0,max(y)-1));
    plot(t,y,'LineWidth',1.3);
end
grid on; xlabel('t (s)'); ylabel('y(t)');
legend(arrayfun(@(T) sprintf('T_s = %g s',T),Tlist,'UniformOutput',false),'Location','southeast');
title('Velocity-form PI: effect of sampling period');

%% Discretised controllers (toolbox)
if exist('pidstd','file')
    C  = pidstd(P.Kp,P.Ti);
    Cbe = pidstd(P.Kp,P.Ti,'Ts',5,'IFormula','BackwardEuler');
    disp('Backward Euler, Ts = 5 s:'); Cbe
    Ctu = c2d(C,5,'tustin');    disp('Tustin, Ts = 5 s:');         Ctu
end
