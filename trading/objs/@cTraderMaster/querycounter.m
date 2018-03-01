function ret = querycounter(obj,querystr)
    isfut = strcmpi(querystr,'fut');
    isopt1 = strcmpi(querystr,'opt1');
    isopt2 = strcmpi(querystr,'opt2');
    if ~isfut && ~isopt1 && ~isopt2
        error('cTraderMaster:querycounter:input querystr shall be either fut,opt1 or opt2');
    end
    
    if isfut
        c = obj.counterfut_;
    end
    
    if isopt1
        c = obj.counteropt1_;
    end
    
    if isopt2
        c = obj.counteropt2_;
    end
    
    qms = obj.qms_;
    
    pos = c.queryPositions;
    n = size(pos,2);
    count = 0;
    for i = 1:n
        if pos(1,i).total_position ~= 0, count = count + 1;end
    end
    
    open_cost = zeros(count,1);
    pnl = zeros(count,1);
    multiplier = zeros(count,1);
    last_trade = zeros(count,1);
    direction = zeros(count,1);
    volume = zeros(count,1);
    codes = cell(count,1);
    
    count = 0;
    for i = 1:n
        if pos(1,i).total_position == 0
            continue;
        else
            count = count + 1;
        end
        codes{count,1} = pos(1,i).asset_code;
        direction(count,1) = pos(1,i).direction;
        volume(count,1) = pos(1,i).total_position;
        isopt = isoptchar(codes{count,1});
        if isopt
            sec = cOption(codes{count,1});
        else
            sec = cFutures(codes{count,1});
        end
        sec.loadinfo([codes{count,1},'_info.txt']);
        qms.registerinstrument(sec);
        open_cost(count) = pos(1,i).avg_price;
        open_cost(count) = open_cost(i)/sec.contract_size;
        if ~isempty(strfind(sec.code_bbg,'TFT')) || ~isempty(strfind(sec.code_bbg,'TFC'))
            open_cost(count) = open_cost(count)*100;
        end
        
        if ~isempty(strfind(sec.code_bbg,'TFT')) || ~isempty(strfind(sec.code_bbg,'TFC'))
            multiplier(count) = sec.contract_size/100;
        else
            multiplier(count) = sec.contract_size;
        end
    end
    
    qms.refresh;
    for i = 1:count
        q = qms.getquote(codes{i});
        last_trade(i) = q.last_trade;
        pnl(i) = (last_trade(i)-open_cost(i))*direction(i)*volume(i)*multiplier(i);
    end
    
    fprintf('\n');
    fprintf('%s pos:\n',c.char);
    for i = 1:count
        fprintf('code: %12s;',codes{i});
        fprintf(' direction: %2d;',direction(i));
        fprintf(' volume: %3d;',volume(i));
        fprintf(' cost: %9.2f;',open_cost(i));
        fprintf(' last: %9.2f;',last_trade(i));
        fprintf(' pnl: %9.2f',pnl(i));
        fprintf('\n');
    end
    ret = 1;
    
end