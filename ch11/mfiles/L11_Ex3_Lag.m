%% Chapter 11 - Example 3 : Lag Compensator (Bode)
%  G(s) = 20/(s(s+2))
%  Spec : Kv = 20 s^-1 , PM >= 50 deg , GM >= 10 dB
clear; clc; close all;
s = tf('s');
G = 20/(s*(s+2));

%% Step 1 : Kc จาก Kv = 10*Kc = 20
Kc = 20 / dcgain(minreal(s*G));
fprintf('Example 3 : Kc = %.2f\n', Kc);
L0 = Kc*G;
[~,PM0,~,Wg0] = margin(L0);
fprintf('  Uncompensated : PM = %.2f deg @ wg = %.3f rad/s\n', PM0, Wg0);

%% Step 2 : PM ที่ต้องการ = 50 + 6 = 56 deg -> หา w ที่เฟส = -180+56
PM_target = 50 + 6;
w = logspace(-3,2,20000);
ph = squeeze(angle(freqresp(L0,w)))*180/pi;
w_ideal = interp1(ph, w, -180+PM_target);
fprintf('  w ที่เฟส = %.0f deg : %.3f rad/s  (ตัวอย่างนี้เลือก wg = 1 rad/s)\n', -180+PM_target, w_ideal);

%% Step 3 : ออกแบบ lag ที่ wg = 1 rad/s  (|KcG| = 25 dB -> beta = 17.78)
wg = 1;
[Glag, info] = L11_lag_design(L0, wg);

%% Step 4 : ตรวจสอบผล
L = Glag*L0;
zpk(L)
L11_compare(L0, L, 'Ex3 Lag', 1);
