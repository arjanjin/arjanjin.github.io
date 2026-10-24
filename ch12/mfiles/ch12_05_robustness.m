%% ch12_05_robustness.m -- Section 12.7: robustness analysis
%  Gang of Four, Ms/Mt, classical margins and the Ms -> GM/PM bounds.
%  Expected: Ms = 1.5905 at 0.0384 rad/s, Mt = 1.0000,
%            GM = 3.14 (9.94 dB), PM = 61.4 deg at wgc = 0.0167 rad/s.
clear; clc;
P = ch12_params();
w = logspace(-5,1,40000); s = 1i*w;
G = P.K*exp(-P.theta*s)./(P.tau*s+1);
C = P.Kp*(1 + 1./(P.Ti*s));
L = G.*C;
S = 1./(1+L); T = L./(1+L); GS = G.*S; CS = C.*S;

[Ms,iS] = max(abs(S)); Mt = max(abs(T));
fprintf('Ms = %.4f at w = %.4f rad/s,  Mt = %.4f\n', Ms, w(iS), Mt);

% classical margins from the frequency grid (exact delay, no Pade)
mag = abs(L); ph = unwrap(angle(L));
[~,ig] = min(abs(mag-1));  [~,ip] = min(abs(ph+pi));
fprintf('wgc = %.5f rad/s, PM = %.2f deg\n', w(ig), rad2deg(ph(ig)+pi));
fprintf('wpc = %.5f rad/s, GM = %.3f (%.2f dB)\n', w(ip), 1/mag(ip), -20*log10(mag(ip)));
fprintf('bounds from Ms (Theorem 12.7): GM >= %.3f, PM >= %.2f deg\n', ...
        Ms/(Ms-1), rad2deg(2*asin(1/(2*Ms))));

% Toolbox cross-check (MATLAB Control System Toolbox)
if exist('pidstd','file') && exist('margin','file')
    Gt = tf(P.K,[P.tau 1],'InputDelay',P.theta);
    Ct = pidstd(P.Kp,P.Ti);
    [Gm,Pm,Wcg,Wcp] = margin(Gt*Ct);
    fprintf('toolbox margin(): GM = %.3f, PM = %.2f deg, wgc = %.5f\n',Gm,Pm,Wcp);
    % R2026a: norm(.,inf)/getPeakGain do not support internal delays ->
    % evaluate |S(jw)| on a dense grid instead
    wf = logspace(-4,1,20000);
    Sf = squeeze(freqresp(feedback(1,Gt*Ct),wf));
    fprintf('toolbox max|S(jw)| (freqresp) = %.4f\n', max(abs(Sf)));
end

% Ms -> minimum GM/PM table (Section 12.7.4)
fprintf('\n  Ms    GMmin    GMmin(dB)   PMmin(deg)\n');
for M = [1.4 1.6 2.0]
    gm = M/(M-1);
    fprintf('%5.2f  %6.3f   %8.2f    %8.2f\n', M, gm, 20*log10(gm), rad2deg(2*asin(1/(2*M))));
end

figure('Name','Ch12 Gang of Four');
semilogx(w,20*log10(abs(S)),w,20*log10(abs(T)),w,20*log10(abs(GS)),w,20*log10(abs(CS)),'LineWidth',1.3);
hold on; yline(20*log10(Ms),'k--');
grid on; xlim([1e-4 1]); ylim([-40 10]); xlabel('\omega (rad/s)'); ylabel('dB');
legend('|S|','|T|','|GS|','|CS|',sprintf('M_s = %.4f',Ms),'Location','southwest');
title('Gang of Four, SIMC PI on 1.2e^{-30s}/(150s+1)');
