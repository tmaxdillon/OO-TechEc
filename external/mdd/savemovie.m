function savemovie
% savemovie.m save a movie and the associated time series variables
%

global U V W z rho time 
global Xts Yts Zts Tits psits iobjts M figs ts iEle
global Zcots Xcots Ycots psicots Iobjts Jobjts Pobjts IEle


if ~isempty(M) | ~isempty(Zts),
[ofile,opath]=uiputfile('*.mat','Save A Mooring Movie');
if ofile~=0,
   if isempty(Zcots),
      save([opath ofile],'Xts','Yts','Zts','Tits','psits','iobjts','time','figs','M','ts','iEle');
   else
      save([opath ofile],'Xts','Yts','Zts','Tits','psits','iobjts','time','figs','M','ts','iEle'...
                        ,'Xcots','Ycots','Zcots','psicots','Iobjts','Jobjts','Pobjts','IEle');
   end
end
clear ofile opath
else
   disp(' Must make a movie before it can be saved. ');
end
moordesign(0);
% fini