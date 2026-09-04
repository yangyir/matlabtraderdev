function [] = showMeTheBook(obj)
    if obj.book_.latest_ == 0
        fprintf('\nempty book...\n');
        return;
    end
    
    fprintf('\nBook:\n');
    for i = 1:obj.book_.latest_
        trade_i = obj.book_.node_(i);
        if ~strcmpi(trade_i.status_,'closed')
            pnl_i = trade_i.runningpnl_;
            closestr_i = '';
        else
            pnl_i = trade_i.closepnl_;
            closestr_i = ['closed->',trade_i.closestr_];
        end
 
        if strcmpi(trade_i.code_,'xauusd')
            printformat = '%10s-->%2s from %s at %8.2f with pnl of %8.2f\t%s\n';
        elseif strcmpi(trade_i.code_,'usdjpy')
            printformat = '%10s-->%2s from %s at %8.3f with pnl of %8.2f\t%s\n';
        else
            printformat = '%10s-->%2s from %s at %8.5f with pnl of %8.2f\t%s\n';
        end
        
        if trade_i.opendirection_ > 0
            directionstr_i = 'B';
        else
            directionstr_i = 'S';
        end
        
        fprintf(printformat,...
            [trade_i.code_,'-',upper(trade_i.opensignal_.frequency_)],...
            directionstr_i,...
            datestr(trade_i.opendatetime1_,'yyyy-mm-dd HH:MM'),...
            trade_i.openprice_,...
            pnl_i,...
            closestr_i);
            
    end
end