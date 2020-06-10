function [mat,odc] = findOptimalDamping(struct)

%extract Hs and Tp
Hs = unique(struct(1).H);
Tp = unique(struct(1).T);

%preallocate
mat = zeros(length(Hs),length(Tp));
odc = zeros(length(Hs),length(Tp));
comp = zeros(length(Hs),length(Tp),length(struct));

for i = 1:length(Hs)
    for j = 1:length(Tp)
        for d = 1:length(struct)
            comp(i,j,d) = struct(d).mat(i,j);
        end
        [mat(i,j),odc(i,j)] = max(comp(i,j,:)); %find optimal dc
    end
end

end

