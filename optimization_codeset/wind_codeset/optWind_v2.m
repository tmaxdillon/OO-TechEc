function [output,opt] = optWind_v2(opt,data,atmo,batt,econ,uc,turb)

%created on Tuesday August 13th by Trent Dillon
%code identifies optimization "cliffs" and minimizes along cliffs

%settings and preallocation
opt.cliff.m = zeros(1,size(opt.cliff.srv_wind,2)); %weight of each line
opt.cliff.s = zeros(size(opt.cliff.m)); %shots to find weight of each line
opt.fmin = false; %not using fmin
over = false; %preallocate over/under
%disp('Finding intersections...')
for l = 1:size(opt.cliff.srv_wind,2)
    dm = opt.cliff.dmult; %reset dm
    m = opt.cliff.mult; %reset m
    for s = 1:opt.cliff.stot-1
%         [~,check_s] = simWind(opt.cliff.srv_wind(1,l)*m, ... 
%             opt.cliff.srv_wind(2,l).*m,opt,data,atmo,batt,econ,uc,turb);
        phi = windPhi(kW,Smax,data,atmo,batt,uc,turb)
        if check_s %over, needs lower multiplier
            m = m-dm;
            if ~over
                dm = dm/2;
                over = true;
            end
        else %under, needs larger multiplier
            m = m+dm;
            if over
                dm = dm/2;
                over = false;
            end
        end
        if dm < opt.cliff.tol
            opt.cliff.m(l) = m;
            opt.cliff.s(l) = s;
            break
        end
        if s == opt.cliff.stot-1
            disp('max shots taken')
        end
        %disp(['Shot ' num2str(s) ' complete...'])
    end
    %disp(['Intersection ' num2str(l) ' complete...'])
end

%disp('Curve fitting...')
%define objective space
opt.cliff.kW = opt.cliff.srv_wind(1,:).*opt.cliff.m; %kW [y] points
opt.cliff.Smax = opt.cliff.srv_wind(2,:).*opt.cliff.m; %Smax [x] points
for i = 1:length(opt.cliff.kW)
    opt.cliff.cost(i) = simWind(opt.cliff.kW(i),opt.cliff.Smax(i), ... 
        opt,data,atmo,batt,econ,uc,turb);
end
%objective function (minimize sum of squares)
x0 = [20,1/2,0];
fun = @(c)sum((opt.cliff.kW - (c(1)./opt.cliff.Smax.^(c(2)) + c(3))).^2);
%cliff optimize options
options = optimset(optimset('MaxFunEvals',10000,'MaxIter',10000));
%find cliff
[opt.cliff.c,opt.cliff.ss] = fminsearch(fun,x0,options);

%disp('Finding miniumum...')
x0 = opt.cliff.Smax(1);
fun = @(x)simWind(opt.cliff.c(1)/x^(opt.cliff.c(2)) + opt.cliff.c(3),x, ...
    opt,data,atmo,batt,econ,uc,turb);
%find minimum
[output.min.Smax] = fminsearch(fun,x0,options);
% %store outputs of minima into output.min
output.min.kW = opt.cliff.c(1)/output.min.Smax^(opt.cliff.c(2)) + opt.cliff.c(3);
[output.min.cost,output.min.surv,output.min.CapEx,output.min.OpEx,...
    output.min.kWcost,output.min.Scost,output.min.Icost,output.min.FScost, ...
    output.min.maint,output.min.vesselcost, ... 
    output.min.turbrepair,output.min.battreplace,output.min.battencl, ...
    output.min.platform, ...
    output.min.battvol,output.min.triptime,output.min.trips, ... 
    output.min.CF,output.min.S,output.min.P,output.min.D,output.min.L] ...
    = simWind(output.min.kW,output.min.Smax,opt,data,atmo,batt,econ,uc,turb);
output.min.rotor_h = turb.clearance + ... 
    sqrt(1000*2*output.min.kW/(atmo.rho*pi*turb.ura^3)); %store rotor height

if opt.cliff.show
    visCliff(opt,output)
end

end

