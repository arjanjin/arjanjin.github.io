%% ch12_01_pid_forms.m -- Section 12.2: PID forms and parameter conversion
%  Ideal (ISA), parallel and series (interacting) forms.  Verifies
%  eq. (12.3), Theorem 12.1 and Exercises 12.2-12.3.
clear; clc;

% --- Series -> ideal, eq. (12.3) ---
ser2ideal = @(Kc,Tis,Tds) deal(Kc*(Tis+Tds)/Tis, Tis+Tds, Tis*Tds/(Tis+Tds));
[Kp,Ti,Td] = ser2ideal(2,10,2);
fprintf('Ex 12.2  series (2,10,2) -> ideal: Kp = %.4f, Ti = %.4f s, Td = %.4f s\n',Kp,Ti,Td);

% --- Ideal -> parallel ---
Kp = 3; Ti = 20; Td = 5;
fprintf('Ex 12.3  ideal (3,20,5) -> parallel: Kp = %.4f, Ki = %.4f, Kd = %.4f\n',Kp,Kp/Ti,Kp*Td);

% --- Ideal -> series, Theorem 12.1 (needs Ti >= 4 Td) ---
r = Td/Ti;
if r <= 0.25 + 1e-12
    q   = sqrt(max(0,1-4*r));
    Kcs = Kp/2*(1+q); Tis = Ti/2*(1+q); Tds = Ti/2*(1-q);
    fprintf('         ideal -> series: Kc'' = %.4f, Ti'' = %.4f s, Td'' = %.4f s (Td/Ti = %.3f)\n',Kcs,Tis,Tds,r);
    [Kb,Tib,Tdb] = ser2ideal(Kcs,Tis,Tds);              % round trip check
    fprintf('         round trip back to ideal: %.4f %.4f %.4f\n',Kb,Tib,Tdb);
else
    fprintf('         ideal -> series impossible: Td/Ti = %.3f > 1/4\n',r);
end

% --- Frequency-response check that the forms are identical ---
w  = logspace(-3,1,400); s = 1i*w;
Cideal  = Kp*(1 + 1./(Ti*s) + Td*s);
Cpar    = Kp + (Kp/Ti)./s + Kp*Td*s;
fprintf('         max |C_ideal - C_parallel| = %.2e\n', max(abs(Cideal-Cpar)));

% --- Proportional band / reset rate (vendor units, Section 12.2.3) ---
fprintf('\nVendor units for Kp = %.3f, Ti = %.1f s:\n',Kp,Ti);
fprintf('  proportional band PB = %.2f %%\n',100/Kp);
fprintf('  reset rate = %.4f repeats/s = %.3f repeats/min\n',1/Ti,60/Ti);
