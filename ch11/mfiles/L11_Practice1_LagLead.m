%% Chapter 11 - แบบฝึกหัดข้อ 1 : Lag-Lead Compensator
%  G(s) = 10/(s(s+1)(s+5))
%  Spec : Kv = 20 s^-1 , PM > 50 deg , GM > 10 dB
%  พร้อมพล็อต Step และ Ramp response
clear; clc; close all;
s = tf('s');
G = 10/(s*(s+1)*(s+5));

%% Step 1 : Kc จาก Kv = 2*Kc = 20 -> Kc = 10
Kc = 20 / dcgain(minreal(s*G));
fprintf('Practice 1 : Kc = %.2f\n', Kc);
L0 = Kc*G;
[GM0,PM0] = margin(L0);
fprintf('  Uncompensated : PM = %.2f deg , GM = %.2f dB  (ระบบไม่เสถียร)\n', PM0, 20*log10(GM0));

%% Step 2 : Lead  phi_max = 55 deg  (alpha = 0.0994)
%  wg ใหม่ = ความถี่ที่ |KcG(jwg)| = -10 dB  (ได้ wg ~ 6.25 rad/s)
[Glead, iLead] = L11_lead_design(L0, 55);
L1 = Glead*L0;
[GM1,PM1] = margin(L1);
fprintf('  After lead : PM = %.2f deg , GM = %.2f dB\n', PM1, 20*log10(GM1));

%% Step 3 : Lag  ที่ wg = 1 rad/s  (|L1| ~ 13.5 dB -> beta ~ 4.73)
[Glag, iLag] = L11_lag_design(L1, 1);

%% Step 4 : ตรวจสอบผล
L = Glag*L1;
Gc = Kc*Glead*Glag;
disp('  Gc(s) = Kc*Glead*Glag :'); zpk(Gc)
L11_compare(L0, L, 'Practice 1 Lag-Lead', 1);
