%% Chapter 11 - Example 1 : Lead Compensator (Bode)
%  G(s) = 4/(s(s+2))
%  Spec : Kv = 20 s^-1 , PM >= 50 deg , GM >= 10 dB
%  01068007 Control Systems - KMITL
clear; clc; close all;
s = tf('s');
G = 4/(s*(s+2));

%% Step 1 : หา Kc จาก Kv
Kv_req = 20;
Kc = Kv_req / dcgain(minreal(s*G));          % Kv = lim s->0 s*Kc*G(s) = 2Kc
fprintf('Example 1 : Kc = %.2f\n', Kc);
L0 = Kc*G;

%% Step 2 : Bode ของ Kc*G
[GM0,PM0,~,Wg0] = margin(L0);
fprintf('  Uncompensated : PM = %.2f deg @ wg = %.3f rad/s\n', PM0, Wg0);

%% Step 3 : phi_max = PM_req - PM + 6  (50 - 18 + 6 = 38 deg)
PM_req  = 50;
phi_max = PM_req - round(PM0) + 6;
[Glead, info] = L11_lead_design(L0, phi_max);

%% Step 4 : ตรวจสอบผล
L = Glead*L0;
disp('  Open loop compensated (zpk):'); zpk(L)
L11_compare(L0, L, 'Ex1 Lead', 1);
