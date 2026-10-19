function L11_compare(Lu, Lc, ttl, plantType)
% L11_COMPARE  เปรียบเทียบระบบก่อน/หลังชดเชย
%   Lu        : open loop ก่อนชดเชย (Kc*G)
%   Lc        : open loop หลังชดเชย (Gc*Kc*G)
%   ttl       : ชื่อตัวอย่าง
%   plantType : 1 = Type-1 (Kv, ramp) , 2 = Type-2 (Ka, parabolic)

if nargin < 4, plantType = 1; end
s = tf('s');

% ---------- Margins ----------
[GMu,PMu,Wpu,Wgu] = margin(Lu);
[GMc,PMc,Wpc,Wgc] = margin(Lc);
fprintf('\n  %-16s %10s %10s %10s %10s\n','', 'PM(deg)','wgc','GM(dB)','wpc');
fprintf('  %-16s %10.2f %10.3f %10.2f %10.3f\n','Uncompensated',PMu,Wgu,20*log10(GMu),Wpu);
fprintf('  %-16s %10.2f %10.3f %10.2f %10.3f\n','Compensated',  PMc,Wgc,20*log10(GMc),Wpc);

% ---------- Static error constant ----------
if plantType == 1
    Kv = dcgain(minreal(s*Lc));
    fprintf('  Kv = %.3f  -> e_ss(ramp) = 1/Kv = %.4f\n', Kv, 1/Kv);
else
    Ka = dcgain(minreal(s^2*Lc));
    fprintf('  Ka = %.3f  -> e_ss(parabola) = 1/Ka = %.4f\n', Ka, 1/Ka);
end

Tu = feedback(Lu,1);  Tc = feedback(Lc,1);
if isstable(Tc)
    S = stepinfo(Tc);
    fprintf('  Step (compensated): Mp = %.1f %% , ts = %.2f s , tr = %.3f s\n', ...
            S.Overshoot, S.SettlingTime, S.RiseTime);
end

% ---------- Bode ----------
figure('Name',[ttl ' : Bode'],'Color','w');
opt = bodeoptions; opt.Grid = 'on'; opt.PhaseMatching = 'on';
bodeplot(Lu,'b--',Lc,'r-',opt);
legend(sprintf('Uncomp: PM=%.1f^o, GM=%.1f dB',PMu,20*log10(GMu)), ...
       sprintf('Comp: PM=%.1f^o, GM=%.1f dB',PMc,20*log10(GMc)), 'Location','southwest');
title([ttl ' : Bode Diagram']);

% ---------- Time responses ----------
tEnd = max(10, ceil(8/max(Wgc,0.1)) * 2);
t = linspace(0, tEnd, 4000)';

figure('Name',[ttl ' : Time response'],'Color','w');
nP = 2 + (plantType==2);
subplot(nP,1,1);
if isstable(Tu), step(Tu,'b--',t); hold on; end
step(Tc,'r-',t); grid on; title('Step Response');
legend_entries(isstable(Tu));

subplot(nP,1,2);
r = t;
yc = lsim(Tc, r, t);
plot(t, r, 'k:', 'LineWidth',1); hold on;
if isstable(Tu), plot(t, lsim(Tu,r,t), 'b--'); end
plot(t, yc, 'r-', 'LineWidth',1.2); grid on;
title('Ramp Response'); xlabel('Time (s)'); ylabel('y(t)');
if isstable(Tu), legend('r(t)=t','Uncomp','Comp','Location','northwest');
else,            legend('r(t)=t','Comp','Location','northwest'); end

if plantType == 2
    subplot(nP,1,3);
    r2 = 0.5*t.^2;
    plot(t, r2, 'k:', 'LineWidth',1); hold on;
    plot(t, lsim(Tc, r2, t), 'r-', 'LineWidth',1.2); grid on;
    title('Parabolic Response'); xlabel('Time (s)'); ylabel('y(t)');
    legend('r(t)=t^2/2','Comp','Location','northwest');
end
end

function legend_entries(uStable)
if uStable, legend('Uncomp','Comp','Location','southeast');
else,       legend('Comp','Location','southeast'); end
end
