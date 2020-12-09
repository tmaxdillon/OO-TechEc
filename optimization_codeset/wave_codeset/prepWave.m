function [opt] = prepWave(data,opt,wave,atmo,uc)

opt.wave.wavepower_ra = (1/(16*4*pi))*atmo.rho_w*atmo.g^2* ...
    (wave.Hs_ra)^2*(wave.Tp_ra); %[W], wave power at rated
%extract data
Hs = data.wave.significant_wave_height; %[m]
Tp = data.wave.peak_wave_period; %[s]
opt.wave.wavepower_ts = (1/(16*4*pi))*atmo.rho_w*atmo.g^2* ...
    Hs.^2.*Tp./1000; %[kW/m] %timeseries of wavepower
opt.wave.L = atmo.g.*Tp.^2/(2*pi); %wavelength timeseries

%extend wavepower, time, hs, tp and wavelength timeseries
[opt.wave.wavepower_ts,opt.wave.time] =  ...
    extendToLifetime(opt.wave.wavepower_ts,data.wave.time,uc.lifetime);
[opt.wave.Hs] = extendToLifetime(Hs,data.wave.time,uc.lifetime);
[opt.wave.Tp] = extendToLifetime(Tp,data.wave.time,uc.lifetime);
[opt.wave.L] = extendToLifetime(opt.wave.L,data.wave.time,uc.lifetime);

if wave.method == 1 %divide by B methodology
    
    wsr = load(wave.wsr);
    wsr = wsr.(wave.wsr);
    opt.wave.Tp_ws = unique(wsr.T); %Tp wec sim array
    Hs = unique(wsr.H); %all Hs
    [~,Hs_ind] = min(abs(Hs - wave.wsHs)); %Hs closest to target Hs
    opt.wave.Hs_ws = Hs(Hs_ind); %Hs wec sim
    %preallocate
    opt.wave.cwr_b_ws = zeros(length(opt.wave.Tp_ws),1);
    %caculate capture width ratio for wec sim values
    for i = 1:length(opt.wave.Tp_ws) %across all tp
        J = (1/(64*pi))*atmo.rho_w*atmo.g^2* ...
            opt.wave.Hs_ws^2*opt.wave.Tp_ws(i); %wavepower
        opt.wave.cwr_b_ws(i) = wsr.mat(Hs_ind,i)/(J*wsr.B^2); %cwr/b
    end
    %find rated cwr/b
    opt.wave.cwr_b_ra = interp1(opt.wave.Tp_ws, ...
        opt.wave.cwr_b_ws,wave.Tp_ra,'spline'); 
    %compute timeseries
    opt.wave.cwr_b_ts = interp1(opt.wave.Tp_ws, ...
        opt.wave.cwr_b_ws,Tp,'spline'); %timeseries of cwr/b
    
elseif wave.method == 2 %3d interpolation methodology
    
    %load wec sim results into structure
    wsr_1 = load('struct1m_opt');
    wsr_1 = wsr_1.('struct1m_opt');
    wsr_2 = load('struct2m_opt');
    wsr_2 = wsr_2.('struct2m_opt');
    wsr_3 = load('struct3m_opt');
    wsr_3 = wsr_3.('struct3m_opt');
    wsr_4 = load('struct4m_opt');
    wsr_4 = wsr_4.('struct4m_opt');
    wsr_5 = load('struct5m_opt');
    wsr_5 = wsr_5.('struct5m_opt');
    wsr_6 = load('struct6m_opt');
    wsr_6 = wsr_6.('struct6m_opt');
    s(6) = struct();
    s(1).wsr = wsr_1;
    s(2).wsr = wsr_2;
    s(3).wsr = wsr_3;
    s(4).wsr = wsr_4;
    s(5).wsr = wsr_5;
    s(6).wsr = wsr_6;
    %preallocate scatter arrays
    H_scat = [];
    T_scat = [];
    B_scat = [];
    CWR_scat = [];
    for b = 1:length(s)
        n = length(s(b).wsr.H);
        if ~isequal(n,length(s(b).wsr.T))
            error('Tp and Hs vectors are not equal in length.')
        end
        H = s(b).wsr.H;
        T = s(b).wsr.T;
        B = b*ones(n,1);       
        J = (1/(64*pi))*atmo.rho_w*atmo.g^2.*H.^2.*T; %find wave power
        P = reshape(s(b).wsr.mat',n,1); %find wec power (use mat not P)
        CWR = P./(J.*B); %find cwr
        %populate scatter arrays
        T_scat = [T_scat ; T];
        H_scat = [H_scat ; H];    
        B_scat = [B_scat ; B];
        CWR_scat = [CWR_scat ; CWR];
    end
    %create scattered interpolant
    opt.wave.F =  scatteredInterpolant(T_scat,H_scat,B_scat,CWR_scat);
    %create width-rated power function
    opt.wave.B_func = zeros(2,wave.B_func_n); %preallocation function
    opt.wave.B_func(1,:) = linspace(min(B_scat),max(B_scat), ...
        wave.B_func_n); %B [m]
    for i = 1:wave.B_func_n
        %find Gr for each B value
        opt.wave.B_func(2,i) = (opt.wave.B_func(1,i)*wave.eta_ct* ...
            opt.wave.F(wave.Tp_ra,wave.Hs_ra,opt.wave.B_func(1,i))* ...
            opt.wave.wavepower_ra)/((1+wave.house)*(1000));
    end
    
end

end

