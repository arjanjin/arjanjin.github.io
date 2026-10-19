%% Chapter 11 - Example 2 : Lead Compensator for Type-2 plant
%  G(s) = 1/s^2
%  Spec : Ka = 10 s^-2 , PM >= 50 deg , GM >= 10 dB
clear; clc; close all;
s = tf('s');
G = 1/s^2;

%% Step 1 : Kc จาก Ka = lim s->0 s^2*Kc*G(s) = Kc
Ka_req = 10;
Kc = Ka_req;
fprintf('Example 2 : Kc = %.2f\n', Kc);
L0 = Kc*G;

%% Step 2 : Bode ของ Kc*G  -> PM = 0 deg (marginally stable)
[~,PM0,~,Wg0] = margin(L0);
fprintf('  Uncompensated : PM = %.2f deg @ wg = %.3f rad/s\n', PM0, Wg0);

%% Step 3 : phi_max = 50 - 0 + 5 = 55 deg
phi_max = 50 - round(PM0) + 5;
[Glead, info] = L11_lead_design(L0, phi_max);

%% Step 4 : ตรวจสอบผล (Ramp + Parabolic)
L = Glead*L0;
zpk(L)
L11_compare(L0, L, 'Ex2 Lead (Type-2)', 2);
