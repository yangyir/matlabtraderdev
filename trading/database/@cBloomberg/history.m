function data = history(obj,instrument,fields,fromdate,todate)
    if ~iscell(fields) && ischar(fields), fields = {fields}; end
    if isa(instrument,'cInstrument')
        data = obj.ds_.history(instrument.code_bbg,fields,fromdate,todate);
    else
        data = obj.ds_.history(instrument,fields,fromdate,todate);
    end
end
%end of history

