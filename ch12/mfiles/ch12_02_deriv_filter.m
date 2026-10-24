%% ch12_02_deriv_filter.m -- Section 12.3: practical derivative action
%  Magnitude of ideal PID vs PID with derivative filter Td/N, eq. (12.5),
%  and Exercise 12.4.
clear; clc;
Kp = 2; Ti = 20; Td = 5; Nlist = [5 10 20];
w = logspace(-3,3,600); s = 1i*w;

figure('Name','Ch12 derivative filter'); 
Cid = Kp*(1 + 1./(Ti*s) + Td*s);
semilogx(w,20*log10(abs(Cid)),'k--','LineWidth',1.2); hold on;
for N = Nlist
    C = Kp*(1 + 1./(Ti*s) + Td*s./(1 + Td*s/N));
    semilogx(w,20*log10(abs(C)),'LineWidth',1.4);
    fprintf('N = %2d: Tf = Td/N = %.3f s, HF gain Kp(1+N) = %.1f (%.2f dB)\n', ...
            N, Td/N, Kp*(1+N), 20*log10(Kp*(1+N)));
end
grid on; xlabel('\omega (rad/s)'); ylabel('|C(j\omega)| (dB)');
legend(['ideal', arrayfun(@(N) sprintf('N = %d',N),Nlist,'UniformOutput',false)], ...
       'Location','northwest');
title('PID magnitude: ideal vs filtered derivative');
