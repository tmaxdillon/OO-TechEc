function [cost,t,d,r] = calcBargeCost(area,mass)

xl = 2; %clearance above surface
rho_w = 1020; %kg/m^3 density of water
rho_s = 7700; %kg/m^3 denisty of steel
g = 9.81; %m/s^2 gravitational constant
fos = 2/3; %factor of safety for yield stress
ys = 75e9; %[Pa] yield stress of steel
rate = 6; %[$/kg] cost of steel
r = sqrt(area/2); %[m] barge radius
bf = 1; %buoyancy factor
d_hyd = 10; %hydrostatic draft, 5 m

t = sqrt(1.24*rho_w*g*d_hyd*r^2/(ys*fos)); %thickness
syms d
eqn = [rho_w*g*pi*r^2*d - bf*g*(mass + rho_s*(pi*r^2*(xl+d) - ... 
     pi*(r-t)^2*(xl+d-2*t))) == 0];
S = solve(eqn,d);
d = double(S);

% %system of equations to find draft and thickness
% syms u v
% eqns = [rho_w*g*pi*r^2*u - bf*g*(mass + rho_s*(pi*r^2*(xl+u) - ... 
%     pi*(r-v)^2*(xl+u-2*v))) == 0, ys*fos - 1.24*rho_w*g*u*r^2/v^2];
% S = solve(eqns,[u v]);
% d = real(double(S.u)); %real draft
% t = real(double(S.v)); %real thickiness
% d(t < 0.001 | d < 0.1) = inf; %remove nonzero solutions
% t(t < 0.001 | d < 0.1) = inf; %remove nonzero solutions
% [t,ind] = min(t); %smallest thickness is typically the correct solution
% d = d(ind); %corresponding draft

%compute cost
cost = rate * rho_s * (pi*r^2*(d+xl) - pi*(r-t)^2*(d+xl-2*t));

end

