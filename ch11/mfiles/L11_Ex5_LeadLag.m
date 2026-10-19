%% Chapter 11 - Example 5 : Lead-Lag Compensator (Bode)
%  G(s) = 10/(s(s+1)(s+5))
%  Spec : Kv = 5 s^-1 , PM >= 50 deg , GM >= 10 dB
clear; clc; close all;
s = tf('s');
G = 10/(s*(s+1)*(s+5));

%% Step 1 : Kc จาก Kv = 2*Kc = 5
Kc = 5 / dcgain(minreal(s*G));
fprintf('Example 5 : Kc = %.2f\n', Kc);
L0 = Kc*G;
[~,PM0,~,Wg0] = margin(L0);
fprintf('  Uncompensated : PM = %.2f deg @ wg = %.3f rad/s\n', PM0, Wg0);

%% Step 2 : Lead  phi_max = 50 - 4 + 5 = 51 deg
phi_max = 50 - round(PM0) + 5;
[Glead, iLead] = L11_lead_design(L0, phi_max);
L1 = Glead*L0;
[~,PM1,~,Wg1] = margin(L1);
fprintf('  After lead : PM = %.2f deg @ %.3f rad/s  (ยังไม่ถึง 50 deg)\n', PM1, Wg1);

%% Step 3 : Lag  ที่ wg = 1 rad/s  (|L1| ~ 13 dB -> beta ~ 4.47)
[Glag, iLag] = L11_lag_design(L1, 1);

%% Step 4 : ตรวจสอบผล
L = Glag*L1;
zpk(L)
L11_compare(L0, L, 'Ex5 Lead-Lag', 1);
