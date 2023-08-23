function savedailybarfromths(ths,code_ctp,override)
%utility function to save data from THS
%for options and futures traded in SHFE,DCE,CZC and CFE only
if ~isa(ths,'cTHS')
    error('savedailybarfromths:invalid THS instance input')
end

if ~ischar(code_ctp)
    error('savedailybarfromths:invalid CTP code input')
end

if nargin < 3
    override = false;
end

if override
    error('savedailybarfromths:override true is not supported now as THS access is limited...')
end

f = code2instrument(code_ctp);


end