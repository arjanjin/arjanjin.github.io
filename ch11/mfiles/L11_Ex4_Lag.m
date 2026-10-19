%% Chapter 11 - Example 4 : Lag Compensator (Bode)
%  G(s) = 100/(s(s+5)(s+10))
%  Spec : Kv = 10 s^-1 , PM >= 50 deg , GM >= 10 dB
clear; clc; close all;
s = tf('s');
G = 100/(s*(s+5)*(s+10));

%% Step 1 : Kc จาก Kv = 2*Kc = 10
Kc = 10 / dcgain(minreal(s*G));
fprintf('Example 4 : Kc = %.2f\n', Kc);
L0 = Kc*G;
[GM0,PM0,Wp0,Wg0] = margin(L0);
fprintf('  Uncompensated : PM = %.2f deg @ %.3f , GM = %.2f dB @ %.3f rad/s\n', ...
        PM0, Wg0, 20*log10(GM0), Wp0);

%% Step 2 : เลือก wg = 1 rad/s (|KcG| = 19.8 dB -> beta = 9.77)
wg = 1;
[Glag, info] = L11_lag_design(L0, wg);

%% Step 3 : ตรวจสอบผล
L = Glag*L0;
zpk(L)
L11_compare(L0, L, 'Ex4 Lag', 1);
