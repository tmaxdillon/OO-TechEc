function [allStruct] = mergeWiWiWaWaDiDiInIn(struct1,struct2,struct3, ... 
    struct4,struct5,struct6,struct7,struct8)

% inputs ( wind, wind, wave, wave, dies, dies, inso, inso )
% output allStruct( location, use case, power modules)

np = 8; %number of power modules

% 1. add generation-specific fields to each structure:

%wind
for i = 1:size(struct1,1)
    for j = 1:size(struct1,2)
        struct1(i,j).inso = [];
        struct1(i,j).wave = [];
        struct1(i,j).dies = [];
        struct2(i,j).inso = [];
        struct2(i,j).wave = [];
        struct2(i,j).dies = [];
    end
end

%wave
for i = 1:size(struct3,1)
    for j = 1:size(struct3,2)
        struct3(i,j).turb = [];
        struct3(i,j).inso = [];
        struct3(i,j).dies = [];
        struct4(i,j).turb = [];
        struct4(i,j).inso = [];
        struct4(i,j).dies = [];
    end
end

%dies
for i = 1:size(struct5,1)
    for j = 1:size(struct5,2)
        struct5(i,j).inso = [];
        struct5(i,j).turb = [];
        struct5(i,j).wave = [];
        struct6(i,j).inso = [];
        struct6(i,j).turb = [];
        struct6(i,j).wave = [];
    end
end

%inso
for i = 1:size(struct7,1)
    for j = 1:size(struct7,2)
        struct7(i,j).dies = [];
        struct7(i,j).turb = [];
        struct7(i,j).wave = [];
        struct8(i,j).dies = [];
        struct8(i,j).turb = [];
        struct8(i,j).wave = [];        
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
%merge wave
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
%merge dies
for i = 1:size(allStruct,1)
    for j = 1:size(allStruct,3)
        allStruct(i,5,j).output = struct5(i,j).output;
        allStruct(i,5,j).opt = struct5(i,j).opt;
        allStruct(i,5,j).data = struct5(i,j).data;
        allStruct(i,5,j).atmo = struct5(i,j).atmo;
        allStruct(i,5,j).batt = struct5(i,j).batt;
        allStruct(i,5,j).econ = struct5(i,j).econ;
        allStruct(i,5,j).uc = struct5(i,j).uc;
        allStruct(i,5,j).pm = struct5(i,j).pm;
        allStruct(i,5,j).c = struct5(i,j).c;
        allStruct(i,5,j).loc = struct5(i,j).loc;
        allStruct(i,5,j).turb = struct5(i,j).turb;
        allStruct(i,5,j).inso = struct5(i,j).inso;
        allStruct(i,5,j).wave = struct5(i,j).wave;
        allStruct(i,6,j).output = struct6(i,j).output;
        allStruct(i,6,j).opt = struct6(i,j).opt;
        allStruct(i,6,j).data = struct6(i,j).data;
        allStruct(i,6,j).atmo = struct6(i,j).atmo;
        allStruct(i,6,j).batt = struct6(i,j).batt;
        allStruct(i,6,j).econ = struct6(i,j).econ;
        allStruct(i,6,j).uc = struct6(i,j).uc;
        allStruct(i,6,j).pm = struct6(i,j).pm;
        allStruct(i,6,j).c = struct6(i,j).c;
        allStruct(i,6,j).loc = struct6(i,j).loc;
        allStruct(i,6,j).turb = struct6(i,j).turb;
        allStruct(i,6,j).inso = struct6(i,j).inso;
        allStruct(i,6,j).wave = struct6(i,j).wave;
    end
end
%merge inso
for i = 1:size(allStruct,1)
    for j = 1:size(allStruct,3)
        allStruct(i,7,j).output = struct7(i,j).output;
        allStruct(i,7,j).opt = struct7(i,j).opt;
        allStruct(i,7,j).data = struct7(i,j).data;
        allStruct(i,7,j).atmo = struct7(i,j).atmo;
        allStruct(i,7,j).batt = struct7(i,j).batt;
        allStruct(i,7,j).econ = struct7(i,j).econ;
        allStruct(i,7,j).uc = struct7(i,j).uc;
        allStruct(i,7,j).pm = struct7(i,j).pm;
        allStruct(i,7,j).c = struct7(i,j).c;
        allStruct(i,7,j).loc = struct7(i,j).loc;
        allStruct(i,7,j).turb = struct7(i,j).turb;
        allStruct(i,7,j).inso = struct7(i,j).inso;
        allStruct(i,7,j).wave = struct7(i,j).wave;
        allStruct(i,8,j).output = struct8(i,j).output;
        allStruct(i,8,j).opt = struct8(i,j).opt;
        allStruct(i,8,j).data = struct8(i,j).data;
        allStruct(i,8,j).atmo = struct8(i,j).atmo;
        allStruct(i,8,j).batt = struct8(i,j).batt;
        allStruct(i,8,j).econ = struct8(i,j).econ;
        allStruct(i,8,j).uc = struct8(i,j).uc;
        allStruct(i,8,j).pm = struct8(i,j).pm;
        allStruct(i,8,j).c = struct8(i,j).c;
        allStruct(i,8,j).loc = struct8(i,j).loc;
        allStruct(i,8,j).turb = struct8(i,j).turb;
        allStruct(i,8,j).inso = struct8(i,j).inso;
        allStruct(i,8,j).wave = struct8(i,j).wave;
    end
end
end

