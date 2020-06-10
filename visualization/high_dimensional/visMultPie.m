function [] = visMultPie(multStruct)

[loc,c] = size(multStruct);

figure
set(gcf, 'Position', [50, 50, 700, 900])
%p = 1;
tiledlayout(loc,c)
for i = 1:loc
    for j = 1:c
        %subplot(loc,c,p)
        ax = nexttile;
        visPieChart(multStruct(i,j),ax)
        %p = p+1;
    end
end

end

