function [sse] = sseval(c,x,y)

sse = sum((y - c(1)./x.^(c(2)) + c(3)).^2)
end

