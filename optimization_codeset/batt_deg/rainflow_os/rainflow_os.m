function R = rainflow_os(ext,extt)

% RAINFLOW $ Revision: 1.1 $ */
% by Adam Nieslony, 2009 */

% RAINFLOW cycle counting.
% RAINFLOW counting function allows you to extract
% cycle from random loading.
%
% SYNTAX
% rf = RAINFLOW(ext)
% rf = RAINFLOW(ext, dt)
% rf = RAINFLOW(ext, extt)

% OUTPUT
% rf - rainflow cycles: matrix 3xn or 5xn dependend on input,
% rf(1,:) Cycles amplitude,
% rf(2,:) Cycles mean value,
% rf(3,:) Number of cycles (0.5 or 1.0),
% rf(4,:) Begining time (when input includes dt or extt data),
% rf(5,:) Cycle period (when input includes dt or extt data),
%
% INPUT
% ext - signal points, vector nx1, ONLY TURNING POINTS!,
% dt - sampling time, positive number, when the turning points
% spaced equally,
% extt - signal time, vector nx1, exact time of occurrence of turning points.
%
%
% See also SIG2EXT, RFHIST, RFMATRIX, RFPDF3D.

% RAINFLOW
% Copyright (c) 1999-2002 by Adam Nieslony,
% MEX function.

% ++++++++++ BEGIN RF3 [ampl ampl_mean nr_of_cycle] */
% ++++++++++ Rain flow without time analysis */

j = 0;
pr=1;
kv=1;
tot_num=length(ext);
if nargin==1
R=zeros(3,tot_num);
for index=1:tot_num
j=j+1;
ext(j)=ext(pr);
pr=pr+1;
while ( (j >= 3) && (abs(ext(j-1)-ext(j-2)) <= abs(ext(j)-ext(j-1))) )
ampl=abs( (ext(j-1)-ext(j-2))/2 );
switch(j)

case 1
break;
case 2
break;
case 3
mean=(ext(1)+ext(2))/2;
ext(1)=ext(2);
ext(2)=ext(3);
j=2;
if (ampl > 0)
R(1,kv)=ampl;
R(2,kv)=mean;
R(3,kv)=0.50;
kv=kv+1;
end
break;

otherwise
mean=(ext(j-1)+ext(j-2))/2;
ext(j-2)=ext(j);
j=j-2;
if (ampl > 0)
R(1,kv)=ampl;
R(2,kv)=mean;
R(3,kv)=1.00;
kv=kv+1;
end

end


end
end

for index=1:j
ampl=abs(ext(index)-ext(index+1))/2;
mean=(ext(index)+ext(index+1))/2;
if ampl > 0
R(1,kv)=ampl;
R(2,kv)=mean;
R(3,kv)=0.50;
kv=kv+1;
end
end
% ++++++++++ END RF3 */
else

if length(extt)>1

else
dt=extt;
extt=(0:tot_num-1)*dt;
end

R=zeros(5,tot_num);
for index=1:tot_num
j=j+1;
ext(j)=ext(pr);
pr=pr+1;
while ( (j >= 3) && (abs(ext(j-1)-ext(j-2)) <= abs(ext(j)-ext(j-1))) )
ampl=abs( (ext(j-1)-ext(j-2))/2 );
switch(j)

case 1
break;
case 2
break;
case 3
mean=(ext(1)+ext(2))/2;
period=(extt(2)-extt(1))*2;
exttime=extt(1);
ext(1)=ext(2);
ext(2)=ext(3);
extt(1)=extt(2);
extt(2)=extt(3);
j=2;
if (ampl > 0)
R(1,kv)=ampl;
R(2,kv)=mean;
R(3,kv)=0.50;
R(4,kv)=exttime;
R(5,kv)=period;
kv=kv+1;
end
break;

otherwise
mean=(ext(j-1)+ext(j-2))/2;
period=(extt(j-1)-extt(j-2))*2;
exttime=extt(j-2);
ext(j-2)=ext(j);
extt(j-2)=extt(j);
j=j-2;
if (ampl > 0)
R(1,kv)=ampl;
R(2,kv)=mean;
R(3,kv)=1.00;
R(4,kv)=exttime;
R(5,kv)=period;
kv=kv+1;
end

end
end
end

for index=1:j
ampl=abs(ext(index)-ext(index+1))/2;
mean=(ext(index)+ext(index+1))/2;
period=(extt(index+1)-extt(index))*2;
exttime=extt(index);
if ampl > 0
R(1,kv)=ampl;
R(2,kv)=mean;
R(3,kv)=0.50;
R(4,kv)=exttime;
R(5,kv)=period;
kv=kv+1;
end
end

% ++++++++++ END RF5 */

end

R=R(:,1:kv-1);

end