function [Gc, info] = L11_lead_design(L0, phi_max_deg, wg_user)
% L11_LEAD_DESIGN  ออกแบบ Lead compensator ด้วย Bode diagram (Chapter 11)
%
%   [Gc, info] = L11_lead_design(L0, phi_max_deg)
%
%   L0          : open-loop TF ที่ปรับเกน Kc แล้ว  (Kc*G(s))
%   phi_max_deg : มุมเฟสที่ต้องการเพิ่ม  phi_max = PM_req - PM_now + (5..12 deg)
%
%   ขั้นตอน:
%     1) alpha = (1 - sin phi_max) / (1 + sin phi_max)
%     2) หา wg ใหม่ ที่ |Kc G(jw)| = -20log(1/sqrt(alpha)) dB
%     3) z = wg*sqrt(alpha) ,  p = z/alpha
%     4) Gc(s) = (1/alpha) * (s+z)/(s+p)      (DC gain = 1)
%
%   wg_user (optional) : กำหนด wg เองแทนการคำนวณ (เช่น ค่าที่อ่านจากกราฟ Bode)

alpha  = (1 - sind(phi_max_deg)) / (1 + sind(phi_max_deg));
magdB  = -20*log10(1/sqrt(alpha));          % ขนาดที่ wg ใหม่ (dB)
wg     = getGainCrossover(L0, sqrt(alpha)); % ความถี่ที่ |L0| = sqrt(alpha)
wg     = wg(1);
if nargin >= 3 && ~isempty(wg_user)
    fprintf('  [Lead] wg (คำนวณ) = %.3f rad/s -> ใช้ wg ที่กำหนด = %.3f rad/s\n', wg, wg_user);
    wg = wg_user;
    magdB = 20*log10(abs(freqresp(L0, wg)));
end
z      = wg*sqrt(alpha);
p      = z/alpha;
Gc     = (1/alpha) * tf([1 z], [1 p]);

info = struct('alpha',alpha,'magdB',magdB,'wg',wg,'z',z,'p',p,'K',1/alpha);

fprintf('  [Lead] phi_max = %.1f deg -> alpha = %.4f\n', phi_max_deg, alpha);
fprintf('         |KcG(jwg)| = %.2f dB  @ wg = %.3f rad/s\n', magdB, wg);
fprintf('         z = %.3f , p = %.3f\n', z, p);
fprintf('         Gc_lead(s) = %.3f (s + %.3f)/(s + %.3f)\n', 1/alpha, z, p);
end
