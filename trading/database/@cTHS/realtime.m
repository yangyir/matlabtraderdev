function data = realtime(obj,instruments,fields)
%cTHS function
    data = [];
    if ~obj.isconnect,return;end

    if iscell(fields)
        %wind fields are input as char not cell
        n = length(fields);
        fields_ = fields{1};
        for i = 2:n
            tmp = [fields_,',',fields{i}];
            fields_ = tmp;
        end
    end

    if isa(instruments,'cInstrument')
        list_ths = instruments.code_wind;
    elseif iscell(instruments)
        list_ths = instruments{1};
        n = length(instruments);
        for i = 2:n
            tmp = [list_ths,',',instruments{i}];
            list_ths = tmp;
        end
    elseif ischar(instruments)
        list_ths = instruments;
    end

    d = THS_RQ(list_ths,'tradeDate;tradeTime;latest','','format:table');
    data = [datenum(d.time,'yyyy-mm-dd HH:MM:SS'),d.latest];
end
%end of realtime