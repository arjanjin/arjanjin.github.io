function m = ch12_metrics(t, e, u, band)
%CH12_METRICS  Performance indices of Section 12.6.
%   m = ch12_metrics(t, e, u) returns IAE, IE, ISE, ITAE, TV, emax, ts.
%   band is the settling band (default 0.02 = 2 %).
if nargin < 4, band = 0.02; end
dt = t(2) - t(1);
m.IAE  = sum(abs(e))*dt;
m.IE   = sum(e)*dt;
m.ISE  = sum(e.^2)*dt;
m.ITAE = sum(t.*abs(e))*dt;
m.TV   = sum(abs(diff(u)));
m.emax = max(abs(e));
idx = find(abs(e) > band, 1, 'last');
if isempty(idx), m.ts = 0; else, m.ts = t(idx); end
end
