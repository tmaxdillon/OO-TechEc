function loadmd
% function loadmd.m
% load an existing mooring design or movie mat file
clear U V W z rho time Xts Yts Zts Tits psits iobjts M figs H B Cd ME moorele
global U V W z rho time 
global Xts Yts Zts Tits psits iobjts M figs   % these are time series variables
global H B Cd ME moorele
global Ht Bt Cdt MEt moorelet Usp Vsp

[ifile,ipath]=uigetfile('*.mat','Load MD&D Mooring, Towed Body or Movie');

if ifile~=0,
if exist([ipath ifile],'file');
   load([ipath ifile]);
end
if isempty(time), clear time; end
if ~isempty(moorele),dismoor; end
if ~isempty(moorelet),dismoor; end
end
%
clear ifile ipath
% fini