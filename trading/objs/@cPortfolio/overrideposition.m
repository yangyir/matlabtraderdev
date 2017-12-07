function [] = overrideposition(obj,instrument,px,volume,dtnum)
    if nargin < 5
        dtnum = today;
    end
    [bool,idx] = obj.hasposition(instrument);
    if ~bool
        obj.addinstrument(instrument,px,volume,dtnum);
    else
%         obj.instrument_avgcost(idx,1) = px;
%         obj.instrument_volume(idx,1) = volume;
        obj.pos_list{idx,1}.override('code',instrument.code_ctp,'price',px,...
            'volume',volume,'time',dtnum);
    end
end