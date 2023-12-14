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
        if ischar(instruments{1})
            instr = code2instrument(instruments{1});
            list_ths = instr.code_wind;
        elseif isa(instruments{1},'cInstrument')
            list_ths = instruments{1}.code_wind;
        end
        n = length(instruments);
        for i = 2:n
            if ischar(instruments{i})
                instr = code2instrument(instruments{i});
                tmp = [list_ths,',',instr.code_wind];
            elseif isa(instruments{i},'cInstrument')
                tmp = [list_ths,',',instruments{i}.code_wind];
            end
            list_ths = tmp;
        end
    elseif ischar(instruments)
        instr = code2instrument(instruments);
        list_ths = instr.code_wind;
    end

    d = THS_RQ(list_ths,'tradeDate;tradeTime;latest','','format:table');
    data = [datenum(d.time,'yyyy-mm-dd HH:MM:SS'),d.latest];
end
%end of realtime