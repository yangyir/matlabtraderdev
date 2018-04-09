function data = realtime(obj,instruments,fields)
    if isempty(obj.ds_)
        data = [];
        return
    end

    if ~iscell(fields) && ischar(fields), fields = {fields}; end

    if isa(instruments,'cInstrument')
        list_bbg = instruments.code_bbg;
    elseif iscell(instruments)
        n = length(instruments);
        list_bbg = cell(n,1);
        for i = 1:n
            if ischar(instruments{i})
                list_bbg{i} = instruments{i};
            elseif isa(instruments{i},'cInstrument')
                list_bbg{i} = instruments{i}.code_bbg;
            else
                error('cBloomberg:realtime:invalid input')
            end
        end
    else
        list_bbg = instruments;
    end

    data = obj.ds_.getdata(list_bbg,fields);
end
%end of realtime

