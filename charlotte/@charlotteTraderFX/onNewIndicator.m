function [] = onNewIndicator(obj,~,eventData)
% a charlotteTraderFX function
    data = eventData.MarketData;
    
    obj.updatePendingBook(data);
    obj.manageRisk(data);
    
    fprintf('\n');
    if obj.book_.latest_ + obj.pendingbook_.latest_ == 0
        fprintf('empty book...\n');
        return;
    end
    
    for i = 1:obj.book_.latest_
        trade_i = obj.book_.node_(i);
        if ~strcmpi(trade_i.status_,'closed')
            if strcmpi(trade_i.code_,'xauusd')
                printformat = '%6s\t%4s\t%2d\t%s\t%8.2f\t%8.2f\t%s\n';
            elseif strcmpi(trade_i.code_,'usdjpy')
                printformat = '%6s\t%4s\t%2d\t%s\t%8.3f\t%8.2f\t%s\n';
            else
                printformat = '%6s\t%4s\t%2d\t%s\t%8.5f\t%8.2f\t%s\n';
            end
            fprintf(printformat,...
                trade_i.code_,...
                trade_i.opensignal_.frequency_,...
                trade_i.opendirection_,...
                trade_i.opendatetime2_,...
                trade_i.openprice_,...
                trade_i.runningpnl_,...
                trade_i.closestr_);
        end    
    end
    
    for i = 1:obj.pendingbook_.latest_
        trade_i = obj.pendingbook_.node_(i);
        if ~strcmpi(trade_i.status_,'closed')
            if strcmpi(trade_i.code_,'xauusd')
                printformat = '%6s\t%4s\t%2d\t%s\t%8.2f\t%8.2f\t%s\n';
            elseif strcmpi(trade_i.code_,'usdjpy')
                printformat = '%6s\t%4s\t%2d\t%s\t%8.3f\t%8.2f\t%s\n';
            else
                printformat = '%6s\t%4s\t%2d\t%s\t%8.5f\t%8.2f\t%s\n';
            end
            
            fprintf(printformat,...
                trade_i.code_,...
                trade_i.opensignal_.frequency_,...
                trade_i.opendirection_,...
                trade_i.opendatetime2_,...
                trade_i.openprice_,...
                0.0,...
                trade_i.closestr_);
        end    
    end
    fprintf('\n');
    
end