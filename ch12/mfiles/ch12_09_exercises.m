%% ch12_09_exercises.m -- numeric answers of Exercises 12.2-12.11
clear; clc;
P = ch12_params();
% 12.2 series -> ideal
Kc = 2; Tis = 10; Tds = 2;
fprintf('12.2  Kp = %.4f, Ti = %.4f, Td = %.4f\n', Kc*(Tis+Tds)/Tis, Tis+Tds, Tis*Tds/(Tis+Tds));
% 12.3 ideal -> parallel / series
Kp = 3; Ti = 20; Td = 5; q = sqrt(max(0,1-4*Td/Ti));
fprintf('12.3  Ki = %.4f, Kd = %.4f; series Kc'' = %.4f, Ti'' = %.4f, Td'' = %.4f\n', ...
        Kp/Ti, Kp*Td, Kp/2*(1+q), Ti/2*(1+q), Ti/2*(1-q));
% 12.4 derivative filter
fprintf('12.4  Tf = %.3f s, HF gain = %.1f\n', 5/10, 2*(1+10));
% 12.6 IE_d
fprintf('12.6  IE_d = %.1f\n', -2/0.05);
% 12.7 IE_r
fprintf('12.7  IE_r = %.1f\n', 1/(0.02*2) + 50*(1-0.4));
% 12.8 bounds from Ms = 1.6
M = 1.6; fprintf('12.8  GM >= %.3f (%.2f dB), PM >= %.2f deg\n', M/(M-1), 20*log10(M/(M-1)), rad2deg(2*asin(1/(2*M))));
% 12.9 SIMC on 0.8e^{-20s}/(100s+1) and its Ms
K = 0.8; tau = 100; th = 20; Kp9 = tau/(K*2*th); Ti9 = min(tau,8*th);
w = logspace(-5,1,40000); s = 1i*w;
L = K*exp(-th*s)./(tau*s+1).*Kp9.*(1+1./(Ti9*s));
fprintf('12.9  Kp = %.4f, Ti = %.1f s, Ms = %.4f (case study Ms = 1.5905)\n', Kp9, Ti9, max(abs(1./(1+L))));
% 12.11 velocity form
e = [0 1 0.8 0.5]; u = 0; uu = zeros(1,3);
for k = 2:4, u = u + 2*((e(k)-e(k-1)) + 1/20*e(k)); uu(k-1) = u; end
fprintf('12.11 u1 = %.2f, u2 = %.2f, u3 = %.2f\n', uu);
