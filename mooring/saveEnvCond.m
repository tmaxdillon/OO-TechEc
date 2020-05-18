function [] = saveEnvCond(depth,ext,name)

if ext %extreme conditions
    load('sp_ec.mat')
    wc_u = U; %working current
    wc_z = z; %working depth
    clear U V W z
    
    %constants
    min_vel = 0.1;
    Hmax = 18; %[m]
    Tmax = 15; %[s]
    L = 9.81*Tmax^2/(2*pi); %[m]
    upper_floor = 200; %[m]
    lower_ceil = 225; %[m]
    upper_n = 10;
    lower_n = 10;
    
    %preallocate
    z = [linspace(depth,depth-upper_floor,upper_n) ...
        linspace(depth-lower_ceil,0,lower_n)];
    U = zeros(size(z));
    W = zeros(size(z));
    V = zeros(size(z));
    
    %find maximum horizontal velocities at all depths
    for i = 1:length(z)
        U(i) = pi*Hmax/Tmax*exp(2*pi*(z(i)-depth)/L) + ...
            interp1(wc_z,wc_u,z(i));
    end
    
else %not extreme conditions
    load('sp_ec.mat')
    z = linspace(depth,0,11)';
end

save([name '.mat'],'U','V','W','z')
end

