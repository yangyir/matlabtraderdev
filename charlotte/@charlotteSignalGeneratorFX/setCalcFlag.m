function [] = setCalcFlag(obj,code,flag)
% a charlotteSignalGeneratorFX function
    ncodes = size(obj.codes_,1);
    foundflag = false;
    for i = 1:ncodes
        if strcmpi(obj.codes_{i},code)
            foundflag = true;
            obj.calcflag_(i) = flag;
            break
        end
    end
    
    if ~foundflag
        error('charlotteSignalGeneratorFX:setCalcFlag:invalid code input %s\n',code)
    end
    
    if ~flag
        try
            close(figure(i+4));
        catch
        end
    end
end