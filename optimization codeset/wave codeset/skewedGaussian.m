function [y] = skewedGaussian(x,alpha,width)

%dynamic coefficients: x, alpha (tuned to curve fit distribution)
%static coefficient: width (set in optInputs)
y = 2*(1/sqrt((2*pi))*exp(-x^2/width))*normcdf(alpha*x);

end

