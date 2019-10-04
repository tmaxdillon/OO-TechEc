function [allStruct] = mergeStructures(struct1,struct2)

for i = 1:size(struct1,1)
    for j = 1:size(struct1,2)
        for k = 1:size(struct1,3)
            struct1(i,j,k).wave = [];
        end
    end
end
for i = 1:size(struct2,1)
    for j = 1:size(struct2,2)
        for k = 1:size(struct2,3)
            struct2(i,j,k).turb = [];
            struct2(i,j,k).inso = [];
        end
    end
end
allStruct(size(struct1,1),size(struct1,2) +  ...
    size(struct2,2),size(struct1,3)) = struct();
for i = 1:size(struct1,1)
    for j = 1:size(struct1,2)
        for k = 1:size(struct1,3)            
            allStruct(i,j,k).output = struct1(i,j,k).output;
            allStruct(i,j,k).opt = struct1(i,j,k).opt;
            allStruct(i,j,k).data = struct1(i,j,k).data;
            allStruct(i,j,k).atmo = struct1(i,j,k).atmo;
            allStruct(i,j,k).batt = struct1(i,j,k).batt;
            allStruct(i,j,k).econ = struct1(i,j,k).econ;
            allStruct(i,j,k).uc = struct1(i,j,k).uc;
            allStruct(i,j,k).pm = struct1(i,j,k).pm;
            allStruct(i,j,k).c = struct1(i,j,k).c;
            allStruct(i,j,k).loc = struct1(i,j,k).loc;
            allStruct(i,j,k).turb = struct1(i,j,k).turb;
            allStruct(i,j,k).inso = struct1(i,j,k).inso;
            allStruct(i,j,k).wave = struct1(i,j,k).wave;            
        end
    end
end
for i = 1:size(struct2,1)
    for j = 1:size(struct2,2)
        for k = 1:size(struct2,3)
            allStruct(i,j+size(struct2,2),k).output = struct2(i,j,k).output;
            allStruct(i,j+size(struct2,2),k).opt = struct2(i,j,k).opt;
            allStruct(i,j+size(struct2,2),k).data = struct2(i,j,k).data;
            allStruct(i,j+size(struct2,2),k).atmo = struct2(i,j,k).atmo;
            allStruct(i,j+size(struct2,2),k).batt = struct2(i,j,k).batt;
            allStruct(i,j+size(struct2,2),k).econ = struct2(i,j,k).econ;
            allStruct(i,j+size(struct2,2),k).uc = struct2(i,j,k).uc;
            allStruct(i,j+size(struct2,2),k).pm = struct2(i,j,k).pm;
            allStruct(i,j+size(struct2,2),k).c = struct2(i,j,k).c;
            allStruct(i,j+size(struct2,2),k).loc = struct2(i,j,k).loc;
            allStruct(i,j+size(struct2,2),k).turb = struct2(i,j,k).turb;
            allStruct(i,j+size(struct2,2),k).inso = struct2(i,j,k).inso;
            allStruct(i,j+size(struct2,2),k).wave = struct2(i,j,k).wave;
        end
    end
end

%rearrange
allStruct_2 = allStruct;
allStruct(:,1,:) = allStruct_2(:,2,:);
allStruct(:,2,:) = allStruct_2(:,1,:);
allStruct(:,3,:) = allStruct_2(:,4,:);
allStruct(:,4,:) = allStruct_2(:,3,:);

end

