function [codectp] = getactivefutures(c,assetcode,varargin)
if ~isa(c,'blp')
    error('getactivefutures:invalid bloomberg instance input')
end

p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('Date',getlastbusinessdate,@isnumeric);
p.parse(varargin{:});
ldb = p.Results.Date;
checkdt = businessdate(ldb,-1);

cl = listcontracts(assetcode,'connection','bloomberg');
open_int = c.history(cl,'open_int',checkdt,checkdt);

max_open_int = 0;
max_open_int_idx = 0;
for i = 1:size(cl,1)
    if isempty(open_int{i}), continue; end
    open_int_i = open_int{i}(2);
    if open_int_i > max_open_int
        max_open_int = open_int_i;
        max_open_int_idx = i;
    end
end

sec = cl{max_open_int_idx};
codectp = bbg2ctp(sec);


end