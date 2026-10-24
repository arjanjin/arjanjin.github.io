%% ch12_04_2dof_sweep.m -- Sections 12.5-12.8: 2-DOF PI, b sweep
%  * Theorem 12.3 (decoupling): load response identical for every b
%  * Theorem 12.4: IE_d = -d0/Ki = -72.00
%  * eq. (12.14):  IE_r = 1/(Ki K) + Ti (1-b)
%  * table of Example 12.2 and the TV / ITAE scan (Fig. 12.7)
clear; clc;
P = ch12_params();
fprintf('SIMC PI: Kp = %.4f, Ti = %.1f s, Ki = %.6f\n\n',P.Kp,P.Ti,P.Ki);

%% Servo side: table (3000 s horizon so integrals converge)
blist = [0 0.25 0.5 0.75 1];
fprintf('  b     u(0+)   IE_r   (12.14)   IAE_r    ITAE_r     TV     Mp%%     ts\n');
figure('Name','Ch12 servo vs b'); hold on;
for b = blist
    R = ch12_sim_pi(P, struct('T',3000,'b',b));
    m = ch12_metrics(R.t, 1-R.y, R.u);
    IEr_th = 1/(P.Ki*P.K) + P.Ti*(1-b);
    fprintf('%5.2f  %6.3f  %6.1f  %7.1f  %7.2f  %8.0f  %6.3f  %5.2f  %6.1f\n', ...
        b, R.u(1), m.IE, IEr_th, m.IAE, m.ITAE, m.TV, 100*max(0,max(R.y)-1), m.ts);
    k = R.t <= 900; plot(R.t(k),R.y(k),'LineWidth',1.3);
end
grid on; xlabel('t (s)'); ylabel('y(t)');
legend(arrayfun(@(b) sprintf('b = %.2f',b),blist,'UniformOutput',false),'Location','southeast');
title('Setpoint response of 2-DOF PI (same C(s) for all b)');

%% Regulatory side: unit input load disturbance, r = 0
R0 = ch12_sim_pi(P, struct('T',3000,'b',0,'r',0,'d',1));
R1 = ch12_sim_pi(P, struct('T',3000,'b',1,'r',0,'d',1));
m0 = ch12_metrics(R0.t,-R0.y,R0.u);
fprintf('\nLoad disturbance d0 = 1:\n');
fprintf('  IE_d = %.4f  (theory -d0/Ki = %.4f)\n', m0.IE, -1/P.Ki);
fprintf('  IAE_d = %.4f, e_max = %.4f at t = %.1f s\n', m0.IAE, m0.emax, R0.t(R0.y==max(R0.y)));
fprintf('  max |y(b=0) - y(b=1)| = %.3e  -> decoupling theorem\n', max(abs(R0.y-R1.y)));
figure('Name','Ch12 load vs b');
k = R0.t <= 900;
plot(R0.t(k),R0.y(k),'LineWidth',3); hold on; plot(R1.t(k),R1.y(k),'--','LineWidth',1.3);
grid on; xlabel('t (s)'); ylabel('y(t)'); legend('b = 0','b = 1');
title('Load-disturbance response is independent of b');

%% Scan of b: TV has an interior minimum, ITAE falls monotonically
bb = 0:0.05:1; TV = zeros(size(bb)); ITAE = TV; Mp = TV;
for i = 1:numel(bb)
    R = ch12_sim_pi(P, struct('T',900,'b',bb(i)));
    m = ch12_metrics(R.t, 1-R.y, R.u);
    TV(i) = m.TV; ITAE(i) = m.ITAE; Mp(i) = 100*max(0,max(R.y)-1);
end
[TVmin,i] = min(TV);
fprintf('\nTV minimum = %.4f at b = %.2f\n', TVmin, bb(i));
% first b where Mp exceeds 0.5 %
bf = 0.90:0.01:1;
for b = bf
    R = ch12_sim_pi(P, struct('T',1500,'b',b));
    if 100*(max(R.y)-1) > 0.5, fprintf('Mp first exceeds 0.5 %% at b = %.2f\n',b); break; end
end
figure('Name','Ch12 b scan');
yyaxis left;  plot(bb,TV,'-o','LineWidth',1.3); ylabel('TV');
yyaxis right; plot(bb,ITAE/1000,'-s','LineWidth',1.3); ylabel('ITAE_r \times 10^{-3}');
grid on; xlabel('b'); title('Control effort vs servo speed');
