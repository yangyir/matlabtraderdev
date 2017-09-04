function c = windconnect(varargin)
%return a wind connection instance in matlab
if nargin < 1
    debug = 0;
else
    debug = 1;
end

answer = who('c');
if isempty(answer)
    if debug
        fprintf('windmatlab instance not fonund!\n');
    end
    c = windmatlab;
end
end