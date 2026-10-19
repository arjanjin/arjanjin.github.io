function [Gc, info] = L11_lag_design(L0, wg)
% L11_LAG_DESIGN  ออกแบบ Lag compensator ด้วย Bode diagram (Chapter 11)
%
%   [Gc, info] = L11_lag_design(L0, wg)
%
%   L0 : open-loop TF ก่อนใส่ lag (Kc*G หรือ Gc_lead*Kc*G)
%   wg : gain crossover ใหม่ที่เลือก ณ จุดที่เฟส ~ -180 + PM_req + (5..6 deg)
%        (ในสไลด์เลือก wg = 1 rad/s)
%
%   ขั้นตอน (ตามสไลด์):
%     1) อ่าน |L0(jwg)| = 20log(beta) dB  -> beta
%     2) z = wg/10 ,  p = z/beta
%     3) Gc(s) = (1/beta) * (s+z)/(s+p)       (DC gain = 1)

if nargin < 2 || isempty(wg)
    error('ต้องระบุ wg ของ lag compensator');
end
mag   = abs(freqresp(L0, wg));
beta  = mag;
magdB = 20*log10(beta);
z     = wg/10;
p     = z/beta;
Gc    = (1/beta) * tf([1 z], [1 p]);
ph    = angle(freqresp(L0, wg))*180/pi;

info = struct('beta',beta,'magdB',magdB,'wg',wg,'z',z,'p',p,'K',1/beta, ...
              'PMnew_est', 180 + ph);

fprintf('  [Lag ] wg = %.3f rad/s : |L0(jwg)| = %.2f dB -> beta = %.4f\n', wg, magdB, beta);
fprintf('         phase(L0) = %.1f deg -> PM_new(est) ~ %.1f deg (ก่อนหักเฟสของ lag ~5 deg)\n', ph, 180+ph);
fprintf('         z = %.4f , p = %.4f\n', z, p);
fprintf('         Gc_lag(s) = %.4f (s + %.4f)/(s + %.4f)\n', 1/beta, z, p);
end
