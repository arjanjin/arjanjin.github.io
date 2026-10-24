function out = ch12_sim_pi(P, opt)
%CH12_SIM_PI  Simulate a 2-DOF PI loop on the FOPDT case study.
%   out = ch12_sim_pi(P, opt) integrates the loop with forward Euler and an
%   exact transport-delay buffer, so that saturation and anti-windup can be
%   modelled without Simulink.  Results match gen_ch12_data.py.
%
%   opt fields (all optional):
%     T     simulation time (s)            default 900
%     b     setpoint weight                default 1
%     r     setpoint step size             default 1
%     d     input load-disturbance step    default 0
%     td    time of disturbance step (s)   default 0
%     umin  actuator lower limit           default -Inf
%     umax  actuator upper limit           default +Inf
%     aw    'none' | 'back' | 'cond'       default 'none'
%     Tt    tracking time constant (s)     default Ti/2
%     Kp,Ti controller override            default P.Kp, P.Ti
%     plant [K tau theta] override         default [P.K P.tau P.theta]
%
%   out fields: t, y, u (actuator), v (controller), I (integral state)

if nargin < 2, opt = struct(); end
T    = getf(opt,'T',900);     b    = getf(opt,'b',1);
r    = getf(opt,'r',1);       d    = getf(opt,'d',0);
td   = getf(opt,'td',0);      umin = getf(opt,'umin',-Inf);
umax = getf(opt,'umax',Inf);  aw   = getf(opt,'aw','none');
kp   = getf(opt,'Kp',P.Kp);   ti   = getf(opt,'Ti',P.Ti);
Tt   = getf(opt,'Tt',ti/2);
pl   = getf(opt,'plant',[P.K P.tau P.theta]);
Kpl = pl(1); taup = pl(2); thp = pl(3);
ki = kp/ti; dt = P.dt;

n  = floor(T/dt) + 1;
t  = (0:n-1)'*dt;
nd = round(thp/dt);
ubuf = zeros(n+nd+1,1);              % transport-delay buffer
x = 0; I = 0;
y = zeros(n,1); u = y; v = y; Iv = y;
for k = 1:n
    y(k) = x;
    e  = r - x;
    vk = kp*(b*r - x) + I;
    uk = min(max(vk, umin), umax);
    switch aw
        case 'none'
            I = I + ki*e*dt;
        case 'back'                          % back-calculation, eq. (12.9)
            I = I + (ki*e + (uk - vk)/Tt)*dt;
        case 'cond'                          % conditional integration
            if ~((vk > umax && e > 0) || (vk < umin && e < 0))
                I = I + ki*e*dt;
            end
        otherwise
            error('ch12_sim_pi: unknown aw method "%s"', aw);
    end
    dk = d*(t(k) >= td);
    ubuf(k+nd) = uk + dk;
    x = x + dt*(-x + Kpl*ubuf(k))/taup;
    u(k) = uk; v(k) = vk; Iv(k) = I;
end
out = struct('t',t,'y',y,'u',u,'v',v,'I',Iv);
end

function val = getf(s, f, def)
if isfield(s,f), val = s.(f); else, val = def; end
end
