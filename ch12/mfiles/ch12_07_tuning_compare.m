%% ch12_07_tuning_compare.m -- Section 12.8.4: Analytical vs pidtune vs systune
%  Requires Control System Toolbox (pidtune) and Robust Control Toolbox
%  or Control System Toolbox R2016a+ (systune).
%  Reference values for C1 (SIMC): Ms = 1.5905, alpha = 0.8832.
clear; clc;
P = ch12_params();
G = tf(P.K,[P.tau 1],'InputDelay',P.theta);

% Example 12.3: IMC = loop shaping.  With Ti = tau, L = e^{-theta s}/((lam+theta)s)
wc = 1/(P.lam+P.theta);
fprintf('Ex 12.3: wc = 1/(lam+theta) = %.5f rad/s, PM = %.2f deg\n', ...
        wc, 90 - rad2deg(P.theta*wc));

% 1) Analytical (SIMC)
C1 = pidstd(P.Kp,P.Ti);

% 2) pidtune: PI, PM 60 deg, disturbance-rejection focus
opt = pidtuneOptions('PhaseMargin',60,'DesignFocus','disturbance-rejection');
[C2,info2] = pidtune(G,'PI',opt);

% 3) systune: tracking + disk-margin goals
% R2026a: systune cannot tune continuous-time delays -> design on pade(G,3),
% then evaluate every controller on the TRUE plant G (exact delay) below
C0 = tunablePID('C','PI');  C0.u = 'e';  C0.y = 'u';
Gs = pade(G,3);  Gs.u = 'u';  Gs.y = 'y';
T0 = connect(Gs,C0,sumblk('e = r - y'),'r','y',{'u'});
R1 = TuningGoal.Tracking('r','y',150);     % ~150 s response time
R2 = TuningGoal.Margins('u',6,45);         % disk margins 6 dB / 45 deg
sopt = systuneOptions('RandomStart',5,'Display','off');
[T,fSoft] = systune(T0,[R1 R2],sopt);
fprintf('systune on pade(G,3): soft goals Tracking = %.3f, Margins = %.3f\n', fSoft(1), fSoft(2));
C3 = pid(getBlockValue(T,'C'));

% Compare on the TRUE plant (exact delay)
names = {'SIMC (analytical)','pidtune','systune'};
Cs = {pid(C1), pid(C2), C3};
fprintf('\n%-18s %8s %8s %8s %8s %8s %8s\n','method','Kp','Ti','Ms','GM(dB)','PM','alpha');
figure('Name','Ch12 tuning compare');
for k = 1:3
    C = Cs{k};  L = G*C;
    [Gm,Pm] = margin(L);  dm = diskmargin(L);
    fprintf('%-18s %8.4f %8.2f %8.4f %8.2f %8.2f %8.4f\n', names{k}, C.Kp, C.Kp/C.Ki, ...
        Msf(feedback(1,L)), 20*log10(Gm), Pm, dm.DiskMargin);
    tt = 0:0.05:900;                                       % fine grid: Mp accurate
    ys = step(feedback(L,1),tt);  si = stepinfo(ys,tt,1);
    fprintf('%-18s Mp = %.2f %%, ts(2%%) = %.0f s\n','',si.Overshoot,si.SettlingTime);
    subplot(1,2,1); plot(tt,ys,'LineWidth',1.3); hold on;            % servo (1-DOF)
    subplot(1,2,2); plot(tt,step(feedback(G,C),tt),'LineWidth',1.3); hold on;  % load
end
subplot(1,2,1); title('Setpoint step'); xlabel('t (s)'); ylabel('y'); legend(names,'Location','southeast'); grid on;
subplot(1,2,2); title('Input load disturbance'); xlabel('t (s)'); ylabel('y'); legend(names); grid on;

%% local function (R2026a): Ms of a system with internal delay
function Ms = Msf(S)
% norm(S,inf) and getPeakGain error on internal delays -> dense freqresp
w  = logspace(-4,1,20000);
Ms = max(abs(squeeze(freqresp(S,w))));
end
