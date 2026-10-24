%% ch12_10_export_dat.m -- regenerate data/*.dat for the XeLaTeX figures
%  Same column names and decimation (every 250 samples = 5 s) as
%  gen_ch12_data.py, so the pgfplots code in the chapter needs no change.
clear; clc;
P = ch12_params();
% isfolder(fullfile(pwd,...)): exist('data','dir') also matches any 'data'
% folder on the MATLAB path and then mkdir is skipped
if ~isfolder(fullfile(pwd,'data')), mkdir(fullfile(pwd,'data')); end
dec = 250;

% servo_b.dat
blist = [0 0.25 0.5 0.75 1]; Y = [];
for b = blist
    R = ch12_sim_pi(P, struct('T',900,'b',b)); Y = [Y R.y]; %#ok<AGROW>
end
ch12_write_dat('data/servo_b.dat', {'t','b0','b25','b50','b75','b100'}, [R.t Y], dec);

% load_b.dat
R0 = ch12_sim_pi(P, struct('T',900,'b',0,'r',0,'d',1));
R1 = ch12_sim_pi(P, struct('T',900,'b',1,'r',0,'d',1));
ch12_write_dat('data/load_b.dat', {'t','b0','b100'}, [R0.t R0.y R1.y], dec);

% scan_b.dat
bb = (0:0.05:1)'; TV = zeros(size(bb)); IT = TV; Mp = TV;
for i = 1:numel(bb)
    R = ch12_sim_pi(P, struct('T',900,'b',bb(i)));
    m = ch12_metrics(R.t,1-R.y,R.u); TV(i) = m.TV; IT(i) = m.ITAE/1000; Mp(i) = 100*max(0,max(R.y)-1);
end
ch12_write_dat('data/scan_b.dat', {'b','TV','ITAEk','Mp'}, [bb TV IT Mp], 1);

% sens.dat
w = logspace(-4,0,600)'; s = 1i*w;
L = P.K*exp(-P.theta*s)./(P.tau*s+1).*P.Kp.*(1+1./(P.Ti*s));
ch12_write_dat('data/sens.dat', {'w','S','T'}, [w 20*log10(abs(1./(1+L))) 20*log10(abs(L./(1+L)))], 3);

% windup_y.dat / windup_u.dat
o = struct('T',1500,'b',1,'umin',0,'umax',1.0,'Tt',P.Ti/2);
o.aw = 'none'; A = ch12_sim_pi(P,o);
o.aw = 'back'; B = ch12_sim_pi(P,o);
o.aw = 'cond'; C = ch12_sim_pi(P,o);
Lin = ch12_sim_pi(P, struct('T',1500,'b',1));
ch12_write_dat('data/windup_y.dat', {'t','none','back','cond','lin'}, [A.t A.y B.y C.y Lin.y], dec);
ch12_write_dat('data/windup_u.dat', {'t','none','back','cond'}, [A.t A.u B.u C.u], dec);
fprintf('data/*.dat written.\n');
