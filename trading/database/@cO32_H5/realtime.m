function data = realtime(obj,instruments,fields)
    %note fields are not used here
    variablenotused(fields);
    if ~obj.isconnected_
        data = {};
        return
    end

    if isa(instruments,'cInstrument')
        % getCurrentPrice come from H5Quote 见 qtool\option\optionClass\实盘交易类\O32_matlab\H5Quote\H5QUOTE
        [mkt, level] = getCurrentPrice(instruments.code_H5);
        data = cell(1,1);
        data{1} = struct('mkt',mkt,'level',level);
    elseif iscell(instruments)
        n = length(instruments);
        data = cell(n,1);
        for i = 1:n
            if isa(instruments,'cInstrument')
                [mkt, level] = getCurrentPrice(instruments{i}.code_H5);
            else
                [mkt, level] = getCurrentPrice(instruments{i});
            end
            data{i} = struct('mkt',mkt,'level',level);
        end
    else
        [mkt, level] = getCurrentPrice(num2str(instruments));
        data = cell(1,1);
        data{1} = struct('mkt',mkt,'level',level);
    end
end
%end of realtime