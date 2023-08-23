function data = history(obj,instrument,fields,fromdate,todate)
    %cTHS not implemented yet
    data = [];
    if ~obj.isconnect,return;end
    
    if isa(instrument,'cInstrument')
        [d,~,~,~,~,~,~,~,~] = THS_HQ(instrument.code_wind,fields,'',fromdate,todate,'format:table');
    else
        if strcmpi(instrument(1),'5') || strcmpi(instrument(1),'6')
            code_ths = [instrument,'.SH'];
        elseif strcmpi(instrument(1),'0') || strcmpi(instrument(1),'1') || strcmpi(instrument(1),'3')
            code_ths = [instrument,'.SZ'];
        elseif strcmpi(instrument(1),'4') || strcmpi(instrument(1),'8') 
            code_ths = [instrument,'.BJ'];
        else
            inst = code2instrument(instrument);
            code_ths = inst.code_wind;
        end
        [d,~,~,~,~,~,~,~,~] = THS_HQ(code_ths,fields,'',fromdate,todate,'format:table');
    end
    
    fieldsval = regexp(fields,';','split');
    
    data = datenum(d.time,'yyyy-mm-dd');
    
    for i = 1:length(fieldsval)
        temp = [data,d.(fieldsval{i})];
        data = temp;
    end
    
    idx = ~isnan(sum(data,2));
    data = data(idx,:);
    
end
%end of history