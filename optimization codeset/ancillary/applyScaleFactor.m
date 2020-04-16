function [cost_out] = applyScaleFactor(cost_in,cap_in,cap_out,sf)

cost_out = cost_in*(cap_out/cap_in)^sf;

% % old method: 
% %compute cost (outval) using scale factor
% m = (inval-(inval)*(1/sf))/(inq/2);
% b = inval - (m*inq);
% outval = outq*m + b;
end

