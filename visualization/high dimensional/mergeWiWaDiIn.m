function [allStruct] = mergeWiWaDiIn(struct1,struct2,struct3, ... 
    struct4)

% inputs ( wind, wave, dies, inso )
% output allStruct( location, use case, power modules)

np = 4; %number of power modules

% 1. add generation-specific fields to each structure:

%wind
for i = 1:size(struct1,1)
    for j = 1:size(struct1,2)
        struct1(i,j).inso = [];
        struct1(i,j).wave = [];
        struct1(i,j).dies = [];
    end
end

%wave
for i = 1:size(struct2,1)
    for j = 1:size(struct2,2)
        struct2(i,j).turb = [];
        struct2(i,j).inso = [];
        struct2(i,j).dies = [];
    end
end

%dies
for i = 1:size(struct3,1)
    for j = 1:size(struct3,2)
        struct3(i,j).inso = [];
        struct3(i,j).turb = [];
        struct3(i,j).wave = [];
    end
end

%inso
for i = 1:size(struct4,1)
    for j = 1:size(struct4,2)
        struct4(i,j).dies = [];
        struct4(i,j).turb = [];
        struct4(i,j).wave = [];
    end
end

% 2. preallocate: 
allStruct(size(struct1,1),np,size(struct1,2)) = struct();

% 3. merge structures:

%merge wind
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
%merge wave
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
%merge dies
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
%merge inso
for i = 1:size(allStruct,1)
    for j = 1:size(allStruct,3)
        allStruct(i,4,j).output = struct4(i,j).output;
        allStruct(i,4,j).opt = struct4(i,j).opt;
        allStruct(i,4,j).data = struct4(i,j).data;
        allStruct(i,4,j).atmo = struct4(i,j).atmo;
        allStruct(i,4,j).batt = struct4(i,j).batt;
        allStruct(i,4,j).econ = struct4(i,j).econ;
        allStruct(i,4,j).uc = struct4(i,j).uc;
        allStruct(i,4,j).pm = struct4(i,j).pm;
        allStruct(i,4,j).c = struct4(i,j).c;
        allStruct(i,4,j).loc = struct4(i,j).loc;
        allStruct(i,4,j).turb = struct4(i,j).turb;
        allStruct(i,4,j).inso = struct4(i,j).inso;
        allStruct(i,4,j).wave = struct4(i,j).wave;
    end
end

end
