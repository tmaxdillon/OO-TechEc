function [outval] = applyScaleFactor(inval,inq,outq,sf)
%compute cost (outval) using scale factor
m = (inval-(inval)*(1/sf))/(inq/2);
b = inval - (m*inq);
outval = outq*m + b;
end

