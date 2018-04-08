function data = history(obj,instrument,fields,fromdate,todate)
    if ~iscell(fields) && ischar(fields), fields = {fields}; end

    data = obj.ds_.history(instrument.code_bbg,fields,fromdate,todate);
end
%end of history

