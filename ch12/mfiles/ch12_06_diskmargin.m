%% ch12_06_diskmargin.m -- Section 12.8.4: disk margin, eq. (12.25)
%  alpha = 1/||S - 1/2||_inf = 2/||S - T||_inf  (balanced, SISO)
%  Expected: alpha = 0.8832, disk GM = +/-8.24 dB, disk PM = +/-47.65 deg.
clear; clc;
P = ch12_params();
w = logspace(-5,1,200000); s = 1i*w;
L = P.K*exp(-P.theta*s)./(P.tau*s+1) .* P.Kp.*(1 + 1./(P.Ti*s));
S = 1./(1+L); T = L./(1+L);
[m,i] = max(abs(S-0.5));
alpha = 1/m;
gmax  = (2+alpha)/(2-alpha);
fprintf('alpha = %.4f at w = %.4f rad/s  (2/||S-T|| = %.4f)\n', alpha, w(i), 2/max(abs(S-T)));
fprintf('disk GM range = [%.4f, %.4f] = +/-%.2f dB\n', 1/gmax, gmax, 20*log10(gmax));
fprintf('disk PM = +/-%.2f deg\n', rad2deg(2*atan(alpha/2)));

if exist('diskmargin','file')
    Gt = tf(P.K,[P.tau 1],'InputDelay',P.theta);
    DM = diskmargin(Gt*pidstd(P.Kp,P.Ti));
    fprintf('toolbox diskmargin(): alpha = %.4f, GM = [%.4f %.4f], PM = [%.2f %.2f] deg\n', ...
        DM.DiskMargin, DM.GainMargin, DM.PhaseMargin);
end
