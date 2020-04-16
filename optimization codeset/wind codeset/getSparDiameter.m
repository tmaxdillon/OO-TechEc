function [dp] = getSparDiameter(kW,atmo,turb)

dp = 2*(turb.spar_bm*turb.wf*kW/(2*pi*atmo.rho_w*turb.spar_ar))^(1/3);

end

