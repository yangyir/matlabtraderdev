function b = basis2num(basis)
% 0 = actual/actual (default)
% 1 = 30/360 (SIA)
% 2 = actual/360
% 3 = actual/365
% 4 = 30/360 (BMA)
% 5 = 30/360 (ISDA)
% 6 = 30/360 (European)
% 7 = actual/365 (Japanese)
% 8 = actual/actual (ICMA)
% 9 = actual/360 (ICMA)
% 10 = actual/365 (ICMA)
% 11 = 30/360E (ICMA)
% 12 = actual/365 (ISDA)
% 13 = BUS/252
    if strcmpi(basis,'ACT/ACT')
        b = 0;
    elseif strcmpi(basis,'30/360')
        b = 1;
    elseif strcmpi(basis,'ACT/360')
        b = 2;
    elseif strcmpi(basis,'ACT/365')
        b = 3;
    else
        error([basis,' not supported']);
    end
        
end