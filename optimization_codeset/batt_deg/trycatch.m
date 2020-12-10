C = rand(3,1);
i = 4;

try
   A = C(i);
catch ME
%     disp('Error Message:')
%     disp(ME.message)
% end
   if (strcmp(ME.identifier,'MATLAB:badsubscript'))
      msg = ['Bad subscript occurred: First argument has ', ...
            num2str(size(A,2)),' columns while second has ', ...
            num2str(size(C,2)),' columns.'];
        causeException = MException('MATLAB:myCode:dimensions',msg);
        ME = addCause(ME,causeException);
   end
   rethrow(ME)
end 