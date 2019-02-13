function [] = visOptTime(multStruct)

for i = 1:length(multStruct)
    time(:,i) = [multStruct(i).output.tInitOpt ; ...
        multStruct(i).output.tFminOpt];
end

figure
bar(multStruct(1).opt.tuning_array,time','stacked');
legend('Initial Optimization Runtine','Nelder-Mead Runtime', ... 
    'location','north')
%xlabel('sqrt(m*n)')
ylabel('[s]')
grid on

end

