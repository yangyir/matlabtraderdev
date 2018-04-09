function [] = loadoptions(obj,code_ctp_underlier,numstrikes)
    if nargin < 3
        [calls,puts] = getlistedoptions(code_ctp_underlier);
    else
        [calls,puts] = getlistedoptions(code_ctp_underlier,numstrikes);
    end
    for i = 1:size(calls,1)
        obj.registerinstrument(calls{i});
        obj.registerinstrument(puts{i});
    end
end
%end of loadoptions