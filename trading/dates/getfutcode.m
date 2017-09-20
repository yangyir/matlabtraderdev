function codes = getfutcode(months)
%convert to futures code with given months number
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('months',@isnumeric);
p.parse(months);
mms = p.Results.months;

codesList = 'FGHJKMNQUVXZ';
if isscalar(mms)
    codes = codesList(mms);
    return
end

codes = cell(length(months),1);
%sanity check that month are beween 1 and 12
for i = 1:length(mms)
    if mms(i)<1 || mms(i)>12
        error('getfutcode:invalid month input!')
    end
    codes{i} = codesList(mms(i));
end

end