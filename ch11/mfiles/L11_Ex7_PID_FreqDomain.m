%% Chapter 11 - Example 7 : PID Controller Design in Frequency Domain
%  G(s) = 10/((s+1)(s+2)(s+5))          (Type-0 plant, G(0) = 1)
%  Spec : PM = 50 deg @ wgc = 3 rad/s , Kv = 4 s^-1 (e_ss ramp = 0.25) , GM >= 10 dB
%
%  PID (parallel form) : Gc(s) = Kp + Ki/s + Kd*s
%
%  Method A : Analytical (เงื่อนไขขนาดและเฟสที่ wgc)
%  Method B : Bode reshaping  PID = Kc * PD(lead) * PI(lag)  (แนวเดียวกับ Lead-Lag)
%  Method C : ตรวจสอบด้วย pidtune (Control System Toolbox)
%  01068007 Control Systems - KMITL
clear; clc; close all;
s = tf('s');
G = 10/((s+1)*(s+2)*(s+5));

PM_req = 50;      % deg
wc     = 3;       % rad/s  gain crossover ที่ต้องการ
Kv_req = 4;       % s^-1

%% Bode ของ plant
[GM0,PM0,Wp0,Wg0] = margin(G);
fprintf('Plant G(s): PM = %.2f deg @ %.3f , GM = %.2f dB @ %.3f rad/s\n', ...
        PM0, Wg0, 20*log10(GM0), Wp0);
Gjw   = freqresp(G, wc);
magG  = abs(Gjw);
phG   = angle(Gjw)*180/pi;
fprintf('  ที่ wc = %.1f rad/s : |G| = %.4f (%.2f dB) , phase(G) = %.2f deg\n', ...
        wc, magG, 20*log10(magG), phG);

%% ======================== Method A : Analytical ========================
%  ต้องการ L(jwc) = Gc(jwc)G(jwc) = 1∠(-180 + PM)
%  => |Gc(jwc)| = 1/|G(jwc)| ,  theta = ∠Gc(jwc) = -180 + PM - ∠G(jwc)
%  Gc(jw) = Kp + j(Kd*w - Ki/w)
%  => Kp = cos(theta)/|G| ,  Kd*wc - Ki/wc = sin(theta)/|G|
%  Ki หาจากเงื่อนไข Kv :  Kv = lim s->0 s*Gc*G = Ki*G(0)
fprintf('\n=== Method A : Analytical PID ===\n');
theta = -180 + PM_req - phG;                 % deg
Kp_A  = cosd(theta)/magG;
Ki_A  = Kv_req/dcgain(G);
Kd_A  = (sind(theta)/magG + Ki_A/wc)/wc;
fprintf('  theta = %.2f deg\n', theta);
fprintf('  Kp = %.4f , Ki = %.4f , Kd = %.4f\n', Kp_A, Ki_A, Kd_A);
fprintf('  Ti = Kp/Ki = %.4f s , Td = Kd/Kp = %.4f s\n', Kp_A/Ki_A, Kd_A/Kp_A);
if Kp_A <= 0 || Kd_A < 0
    warning('ได้ Kp หรือ Kd ติดลบ -> ต้องเลือก wc หรือ PM ใหม่');
end
C_A = pid(Kp_A, Ki_A, Kd_A);
L_A = C_A*G;
L11_compare(G, L_A, 'Ex7-A PID (Analytical)', 1);

%% ================== Method B : Bode reshaping (PD x PI) ==================
%  PI : (s + zI)/s ,  zI = wc/10      -> phase lag ~ -5.7 deg ที่ wc
%  PD : (1 + Td s)                    -> phase lead = atan(wc*Td)
%  Kc : ปรับให้ |L(jwc)| = 1  (0 dB)
fprintf('\n=== Method B : Bode reshaping PID = Kc(1+Td s)(s+zI)/s ===\n');
zI    = wc/10;
phPI  = (angle(freqresp((s+zI)/s, wc)))*180/pi;           % ~ -5.71 deg
phiPD = -180 + PM_req - phG - phPI;                       % มุมที่ PD ต้องเติม
Td_B  = tand(phiPD)/wc;
Cn    = (1 + Td_B*s)*(s + zI)/s;                          % ยังไม่รวม Kc
Kc_B  = 1/abs(freqresp(Cn*G, wc));
Kp_B  = Kc_B*(1 + Td_B*zI);
Ki_B  = Kc_B*zI;
Kd_B  = Kc_B*Td_B;
fprintf('  zI = %.3f , phase(PI) = %.2f deg , PD ต้องเติม %.2f deg -> Td = %.4f s\n', ...
        zI, phPI, phiPD, Td_B);
fprintf('  Kc = %.4f -> Kp = %.4f , Ki = %.4f , Kd = %.4f\n', Kc_B, Kp_B, Ki_B, Kd_B);
fprintf('  Kv = Ki*G(0) = %.3f  (สเปก %.1f)\n', Ki_B*dcgain(G), Kv_req);
fprintf('  -> วิธี B ได้ PM ตามสเปก แต่ Kv ไม่ถึง: zI = wc/10 ทำให้ Ki เล็ก\n');
fprintf('     แก้โดยเพิ่ม zI (ยอมเสียเฟสมากขึ้น) หรือใช้วิธี A ที่ล็อก Ki จาก Kv โดยตรง\n');
C_B = pid(Kp_B, Ki_B, Kd_B);
L_B = C_B*G;
L11_compare(G, L_B, 'Ex7-B PID (Bode reshaping)', 1);

%% ===================== Method C : pidtune (check) =====================
fprintf('\n=== Method C : pidtune(G,''PID'',wc) ===\n');
opt  = pidtuneOptions('PhaseMargin', PM_req);
C_C  = pidtune(G, 'PID', wc, opt);
fprintf('  Kp = %.4f , Ki = %.4f , Kd = %.4f\n', C_C.Kp, C_C.Ki, C_C.Kd);
L_C  = C_C*G;
[~,PMc,~,Wgc] = margin(L_C);
fprintf('  PM = %.2f deg @ %.3f rad/s , Kv = %.3f\n', PMc, Wgc, C_C.Ki*dcgain(G));

%% ========= Practical PID : derivative filter  Kd*s/(Tf*s + 1) =========
%  PID จริงต้องมี filter ที่ derivative  Tf = Td/N , N = 10
fprintf('\n=== Practical PID (Method A + derivative filter, N = 10) ===\n');
N    = 10;
Tf   = (Kd_A/Kp_A)/N;
C_Af = pid(Kp_A, Ki_A, Kd_A, Tf);
[GMf,PMf,Wpf,Wgf] = margin(C_Af*G);
fprintf('  Tf = %.4f s -> PM = %.2f deg @ %.3f , GM = %.2f dB @ %.3f rad/s\n', ...
        Tf, PMf, Wgf, 20*log10(GMf), Wpf);
fprintf('  (filter ทำให้ PM ลดลงเล็กน้อย ถ้าลดมากให้เพิ่ม N หรือเผื่อ PM 3-5 deg)\n');

%% ===================== Summary : Bode / Step / u(t) =====================
figure('Name','Ex7 PID : comparison','Color','w');
opt = bodeoptions; opt.Grid = 'on'; opt.PhaseMatching = 'on';
bodeplot(G,'k:', L_A,'r-', L_B,'b--', L_C,'g-.', C_Af*G,'m-', opt);
legend('G(s)','A: Analytical','B: Bode reshape','C: pidtune','A + filter','Location','southwest');
title('Ex7 : Open-loop Bode of PID designs');

t = linspace(0,10,3000)';
figure('Name','Ex7 PID : step & control effort','Color','w');
subplot(2,1,1);
step(feedback(L_A,1),'r-', feedback(L_B,1),'b--', feedback(L_C,1),'g-.', ...
     feedback(C_Af*G,1),'m-', t); grid on;
legend('A','B','C','A + filter','Location','southeast'); title('Closed-loop Step Response');
subplot(2,1,2);
step(feedback(C_Af,G),'m-', t); grid on;
title('Control effort u(t) (A + filter) : ไม่มี filter u(0) -> \infty');

fprintf('\n%-18s %8s %8s %8s %8s %8s %8s\n','Design','Kp','Ki','Kd','PM','GM(dB)','Mp(%)');
D = {'A Analytical',C_A; 'B Bode reshape',C_B; 'C pidtune',C_C; 'A + filter',C_Af};
for k = 1:size(D,1)
    C = D{k,2}; [gm,pm] = margin(C*G); S = stepinfo(feedback(C*G,1));
    fprintf('%-18s %8.3f %8.3f %8.3f %8.2f %8.2f %8.1f\n', D{k,1}, C.Kp, C.Ki, C.Kd, ...
            pm, 20*log10(gm), S.Overshoot);
end
