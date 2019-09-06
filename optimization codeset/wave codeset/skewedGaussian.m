function [y] = skewedGaussian(x,alpha,width)

y = 2*(1/sqrt((2*pi))*exp(-x^2/width))*normcdf(alpha*x);

end

