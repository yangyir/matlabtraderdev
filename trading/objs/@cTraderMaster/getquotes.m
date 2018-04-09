function qs = getquotes(obj)
    secs = obj.instruments_.getinstrument;
    n = obj.instruments_.count;
    qs = cell(n,1);
    %%
    fprintf('\t\tcode\t%1sbid\t\task\t\t%1slast\t\ttime\n','','')
    %%
    obj.mdefut_.qms_.refresh;
    obj.mdeopt_.qms_.refresh;
    for i = 1:n
        if isa(secs{i},'cFutures')
            qs{i} = obj.mdefut_.qms_.getquote(secs{i}.code_ctp);
        elseif isa(secs{i},'cOption')
            qs{i} = obj.mdeopt_.qms_.getquote(secs{i}.code_ctp);
        end
        fprintf('%12s',secs{i}.code_ctp);
        tick_size = secs{i}.tick_size;
        
        if tick_size < 0.01
            fprintf(' %9.3f',qs{i}.bid1);
            fprintf(' %9.3f',qs{i}.ask1);
            fprintf(' %9.3f',qs{i}.last_trade);
        elseif tick_size < 0.1
            fprintf(' %9.2f',qs{i}.bid1);
            fprintf(' %9.2f',qs{i}.ask1);
            fprintf(' %9.2f',qs{i}.last_trade);
        elseif tick_size < 1
            fprintf(' %9.1f',qs{i}.bid1);
            fprintf(' %9.1f',qs{i}.ask1);
            fprintf(' %9.1f',qs{i}.last_trade);
        else
            fprintf(' %9.0f',qs{i}.bid1);
            fprintf(' %9.0f',qs{i}.ask1);
            fprintf(' %9.0f',qs{i}.last_trade);
        end
        fprintf(' %12s',datestr(qs{i}.update_time2,'HH:MM:SS'));
                
        fprintf('\n');
    end
    
    
    
    
end