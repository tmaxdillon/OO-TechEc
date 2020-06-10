function [y_norm,y_val] = skewedGaussian_oo(x,alpha,width,ymax)

%dynamic coefficients: x, alpha (tuned to curve fit distribution)
%static coefficient: width (set in optInputs)
y_val = 2*(1/sqrt((2*pi))*exp(-x^2/width))*normcdf(alpha*x);
y_norm = y_val/ymax;

end

