function open_cost = displaycounterinfo(counter)
    if ~isa(counter,'CounterCTP')
        error('displaycounterinfo:invalid counter input')
    end
    
    pos = counter.queryPositions;
    n = size(pos,2);
    qms = cQMS;
    qms.setdatasource('ctp');
    open_cost = zeros(n,1);
    
    for i = 1:n
        code = pos(1,i).asset_code;
        isopt = isoptchar(code);
        if isopt
            instrument = cOption(code);
        else
            instrument = cFutures(code);
        end
        instrument.loadinfo([code,'_info.txt']);
        qms.registerinstrument(instrument);
        if pos(1,i).total_position == 0
            open_cost(i) = 0;
        else
            open_cost(i) = pos(1,i).avg_price;
            open_cost(i) = open_cost(i)/instrument.contract_size;
            if ~isempty(strfind(instrument.code_bbg,'TFT')) || ~isempty(strfind(instrument.code_bbg,'TFC'))
                open_cost(i) = open_cost(i)*100;
            end
        end
        
    end
    
    fprintf('counter postions and pnl:\n');
    for i = 1:n
        fprintf('code: %13s;',pos(1,i).asset_code);
        fprintf(' direction: %3d;',pos(1,i).direction);
        fprintf(' volume: %5d;',pos(1,i).total_position);
        fprintf(' cost: %8.2f;',open_cost(i));
        fprintf('\n');
    end
        
    
end