function [allStruct] = mergeWaWaWa(struct1,struct2,struct3)

% inputs ( wave_opt_d, wave_opt_c, wave_cons )
% output allStruct( location, use case, power modules)

np = 3; %number of power modules

% 1. add generation-specific fields to each structure:

%wave
for i = 1:size(struct2,1)
    for j = 1:size(struct2,2)
        struct1(i,j).turb = [];
        struct1(i,j).inso = [];
        struct1(i,j).dies = [];
        struct2(i,j).turb = [];
        struct2(i,j).inso = [];
        struct2(i,j).dies = [];
        struct3(i,j).turb = [];
        struct3(i,j).inso = [];
        struct3(i,j).dies = [];
    end
end

% 2. preallocate: 
allStruct(size(struct1,1),np,size(struct1,2)) = struct();

% 3. merge structures:

%merge opt_d
for i = 1:size(allStruct,1)
    for j = 1:size(allStruct,3)
        allStruct(i,1,j).output = struct1(i,j).output;
        allStruct(i,1,j).opt = struct1(i,j).opt;
        allStruct(i,1,j).data = struct1(i,j).data;
        allStruct(i,1,j).atmo = struct1(i,j).atmo;
        allStruct(i,1,j).batt = struct1(i,j).batt;
        allStruct(i,1,j).econ = struct1(i,j).econ;
        allStruct(i,1,j).uc = struct1(i,j).uc;
        allStruct(i,1,j).pm = struct1(i,j).pm;
        allStruct(i,1,j).c = struct1(i,j).c;
        allStruct(i,1,j).loc = struct1(i,j).loc;
        allStruct(i,1,j).turb = struct1(i,j).turb;
        allStruct(i,1,j).inso = struct1(i,j).inso;
        allStruct(i,1,j).wave = struct1(i,j).wave;
    end
end
%merge opt_c
for i = 1:size(allStruct,1)
    for j = 1:size(allStruct,3)
        allStruct(i,2,j).output = struct2(i,j).output;
        allStruct(i,2,j).opt = struct2(i,j).opt;
        allStruct(i,2,j).data = struct2(i,j).data;
        allStruct(i,2,j).atmo = struct2(i,j).atmo;
        allStruct(i,2,j).batt = struct2(i,j).batt;
        allStruct(i,2,j).econ = struct2(i,j).econ;
        allStruct(i,2,j).uc = struct2(i,j).uc;
        allStruct(i,2,j).pm = struct2(i,j).pm;
        allStruct(i,2,j).c = struct2(i,j).c;
        allStruct(i,2,j).loc = struct2(i,j).loc;
        allStruct(i,2,j).turb = struct2(i,j).turb;
        allStruct(i,2,j).inso = struct2(i,j).inso;
        allStruct(i,2,j).wave = struct2(i,j).wave;
    end
end
%merge cons
for i = 1:size(allStruct,1)
    for j = 1:size(allStruct,3)
        allStruct(i,3,j).output = struct3(i,j).output;
        allStruct(i,3,j).opt = struct3(i,j).opt;
        allStruct(i,3,j).data = struct3(i,j).data;
        allStruct(i,3,j).atmo = struct3(i,j).atmo;
        allStruct(i,3,j).batt = struct3(i,j).batt;
        allStruct(i,3,j).econ = struct3(i,j).econ;
        allStruct(i,3,j).uc = struct3(i,j).uc;
        allStruct(i,3,j).pm = struct3(i,j).pm;
        allStruct(i,3,j).c = struct3(i,j).c;
        allStruct(i,3,j).loc = struct3(i,j).loc;
        allStruct(i,3,j).turb = struct3(i,j).turb;
        allStruct(i,3,j).inso = struct3(i,j).inso;
        allStruct(i,3,j).wave = struct3(i,j).wave;
    end
end

end
