function ret = queryaccount(obj,querystr)
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
    
    check = c.queryAccount;
    current_margin = check.current_margin;
    frozen_margin = check.frozen_margin;
    available_fund = check.available_fund;
        
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
    secs = cell(count,1);
    
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
            secs{count} = cOption(codes{count,1});
        else
            secs{count} = cFutures(codes{count,1});
        end
        secs{count}.loadinfo([codes{count,1},'_info.txt']);
        qms.registerinstrument(secs{count});
        open_cost(count) = pos(1,i).avg_price;
        open_cost(count) = open_cost(count)/secs{count}.contract_size;
        if ~isempty(strfind(secs{count}.code_bbg,'TFT')) || ~isempty(strfind(secs{count}.code_bbg,'TFC'))
            open_cost(count) = open_cost(count)*100;
        end
        
        if ~isempty(strfind(secs{count}.code_bbg,'TFT')) || ~isempty(strfind(secs{count}.code_bbg,'TFC'))
            multiplier(count) = secs{count}.contract_size/100;
        else
            multiplier(count) = secs{count}.contract_size;
        end
    end
    
    qms.refresh;
    for i = 1:count
        q = qms.getquote(codes{i});
        last_trade(i) = q.last_trade;
        pnl(i) = (last_trade(i)-open_cost(i))*direction(i)*volume(i)*multiplier(i);
    end
    
    fprintf('\n');
    fprintf('%s:\n',c.char);
    fprintf('\tmargin used:%15.0f\n',current_margin);
    fprintf('\tmargin frozen:%13.0f\n',frozen_margin);
    fprintf('\tmargin available:%10.0f\n', available_fund);
    fprintf('\tpositions:\n');
%     tbl = table(direction,volume,open_cost,last_trade,pnl,'rownames',codes);
    %%
    fprintf('\n');
    fprintf('\t\tcode\tdirection\tvolume\topen_cost\tlast_price\tcumulative_pnl\n');
    
    for i = 1:count
        fprintf(' %12s',codes{i});
        fprintf('\t\t%2d',direction(i));
        fprintf('\t%8d',volume(i));
        fprintf('\t%9.2f',open_cost(i));
        if secs{i}.tick_size < 0.01
            fprintf(' %10.3f',last_trade(i));
        elseif secs{i}.tick_size < 0.1
            fprintf(' %10.2f',last_trade(i));
        elseif secs{i}.tick_size < 1
            fprintf(' %10.1f',last_trade(i));
        else
            fprintf(' %10.0f',last_trade(i));
        end
        fprintf(' %13.2f',pnl(i));
        fprintf('\n');
    end
    %%
    ret = 1;
    
end