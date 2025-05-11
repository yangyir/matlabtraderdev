function [] = updatePendingBook(obj,data)
% a charlotteTraderFX method
    n = obj.pendingbook_.latest_;
    if n == 0, return; end
    
    codes = data.codes_;
    ei = data.ei_;
    kellytables = data.kellytables_;
    signals = data.signals_;
    
%     pendingtrades2remove = cTradeOpenArray;
    
    for i = 1:obj.pendingbook_.latest_
        trade_i = obj.pendingbook_.node_(i);
        idxfound = 0;
        for j = 1:size(codes,1)
            if strcmpi(codes{j},trade_i.code_)
                idxfound = j;
                break
            end
        end
        if idxfound <= 0
            notify(obj,'ErrorOccurred',charlotteErrorEventData('internal error'));
        end
        
        frequency = trade_i.opensignal_.frequency_;
        nfractal = charlotte_freq2nfracal(frequency);
        trade = fractal_gentrade2(ei{idxfound},trade_i.code_,size(ei{idxfound}.px,1),frequency,nfractal,kellytables{idxfound});
        
        if ~isempty(trade)
            %remove the pending trade from pending book
            %and add the new trade to book
            obj.book_.push(trade);
            exporttrade2mt4(trade,ei{idxfound});
            obj.pendingbook_.removebyindex(i);
        else
            if isempty(signals{idxfound})
                obj.pendingbook_.removebyindex(i);
            else
                if signals{idxfound}.directionkellied == 0
                    obj.pendingbook_.removebyindex(i);
                end
            end
        end
    end
    
    
    
    
    
end