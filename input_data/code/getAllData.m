function [allData] = getAllData()

load('argBasin','argBasin')
load('cosEndurance_or','cosEndurance_or')
load('cosEndurance_wa','cosEndurance_wa')
load('cosPioneer','cosPioneer')
load('irmSea','irmSea')
load('souOcean','souOcean')

allData.argBasin = argBasin;
allData.cosEndurance_or = cosEndurance_or;
allData.cosEndurance_wa = cosEndurance_wa;
allData.cosPioneer = cosPioneer;
allData.irmSea = irmSea;
allData.souOcean = souOcean;

end

