%% Chapter 11 - Example 6 : Lead-Lag Compensator (Bode)
%  G(s) = 25/(s(s+1)(s+10))
%  Spec : Kv = 5 s^-1 , PM >= 50 deg , GM >= 20 dB
clear; clc; close all;
s = tf('s');
G = 25/(s*(s+1)*(s+10));

%% Step 1 : Kc จาก Kv = 2.5*Kc = 5
Kc = 5 / dcgain(minreal(s*G));
fprintf('Example 6 : Kc = %.2f\n', Kc);
L0 = Kc*G;
[GM0,PM0,Wp0,Wg0] = margin(L0);
fprintf('  Uncompensated : PM = %.2f deg @ %.3f , GM = %.2f dB @ %.3f rad/s\n', ...
        PM0, Wg0, 20*log10(GM0), Wp0);

%% Step 2 : Lead  phi_max = 50 - 14 + 5 = 41 deg  (PM ของ Kc*G = 13.6 deg @ 2.10 rad/s)
phi_max = 50 - round(PM0) + 5;
[Glead, iLead] = L11_lead_design(L0, phi_max);
L1 = Glead*L0;
[~,PM1,~,Wg1] = margin(L1);
fprintf('  After lead : PM = %.2f deg @ %.3f rad/s\n', PM1, Wg1);

%% Step 3 : Lag  ที่ wg = 1 rad/s  (|L1| ~ 6.9 dB -> beta ~ 2.21)
[Glag, iLag] = L11_lag_design(L1, 1);

%% Step 4 : ตรวจสอบผล
L = Glag*L1;
zpk(L)
L11_compare(L0, L, 'Ex6 Lead-Lag', 1);
