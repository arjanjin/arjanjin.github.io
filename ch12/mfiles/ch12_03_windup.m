%% ch12_03_windup.m -- Section 12.4: integrator windup and anti-windup
%  Example 12.1: setpoint step 1, actuator 0 <= u <= 1.0 (u_ss = 1/K = 0.833).
%  Expected: no AW Mp = 17.39 %, ts = 957.4 s; back-calc/cond Mp = 0.
clear; clc;
P = ch12_params();
base = struct('T',1500,'b',1,'umin',0,'umax',1.0,'Tt',P.Ti/2);
cases = {'none','back','cond'};
names = {'saturated, no AW','back-calculation (Tt=Ti/2)','conditional integration'};

lin = ch12_sim_pi(P, struct('T',1500,'b',1));
mL  = ch12_metrics(lin.t, 1-lin.y, lin.u);
fprintf('%-30s Mp = %6.2f %%  ts = %7.1f s\n','linear (no limit)',100*max(0,max(lin.y)-1),mL.ts);

figure('Name','Ch12 windup');
subplot(2,1,1); plot(lin.t,lin.y,'k--'); hold on;
subplot(2,1,2); hold on;
for i = 1:numel(cases)
    o = base; o.aw = cases{i};
    R = ch12_sim_pi(P,o);
    m = ch12_metrics(R.t, 1-R.y, R.u);
    fprintf('%-30s Mp = %6.2f %%  ts = %7.1f s  Imax = %.3f  vmax = %.3f\n', ...
        names{i},100*max(0,max(R.y)-1),m.ts,max(R.I),max(R.v));
    subplot(2,1,1); plot(R.t,R.y,'LineWidth',1.3);
    subplot(2,1,2); plot(R.t,R.u,'LineWidth',1.3);
end
subplot(2,1,1); grid on; ylabel('y(t)'); legend(['linear',names],'Location','southeast');
title('Setpoint step with actuator saturation u_{max} = 1.0');
subplot(2,1,2); grid on; ylabel('u(t)'); xlabel('t (s)'); ylim([-0.05 1.1]);
