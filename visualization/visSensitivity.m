function [] = visSensitivity(multStruct)

%x axis title
if isequal(multStruct(1).opt.tuned_parameter,'utp')
    xlab = 'Percent Uptime';
    xt = fliplr(multStruct(1).opt.tuning_array);
elseif isequal(multStruct(1).opt.tuned_parameter,'load')
    xlab = 'Load [W]';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'bgd')
    xlab = 'Input Mesh Size: Smax Axis Extent [days of battery storage]';
    xt = min(multStruct(1).opt.tuning_array):3: ...
        max(multStruct(1).opt.tuning_array);
elseif isequal(multStruct(1).opt.tuned_parameter,'mxn')
    xlab = '1D Mesh Resolution';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'zo')
    xlab = 'Surface Roughness';
    xt = multStruct(1).opt.tuning_array;
elseif isequal(multStruct(1).opt.tuned_parameter,'mtbf')
    xlab = 'Mean Time Between Failure';
    xt = multStruct(1).opt.tuning_array;
end

if multStruct(1).pm == 1
    visWindSens(multStruct,xlab,xt)
end
if multStruct(1).pm == 2
    visInsoSens(multStruct,xlab,xt)
end

end

