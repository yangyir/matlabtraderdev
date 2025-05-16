function [] = updatePendingBook(obj,data)
% a charlotteTraderFX method
    n = obj.pendingbook_.latest_;
    if n == 0, return; end
    
    codes = data.codes_;
    ei = data.ei_;
    kellytables = data.kellytables_;
    signals = data.signals_;
    newindicators = data.newindicators_;
    
    pendingtrades2remove = cTradeOpenArray;
    
    for i = 1:obj.pendingbook_.latest_
        try
            trade_i = obj.pendingbook_.node_(i);
        catch
            continue;
        end
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
        
        if ~newindicators(idxfound)
            continue;
        end
        
        if ei{idxfound}.px(end,1) <= trade_i.opendatetime1_
            continue;
        end
        
        frequency = trade_i.opensignal_.frequency_;
        nfractal = charlotte_freq2nfractal(frequency);
        trade = fractal_gentrade2(ei{idxfound},trade_i.code_,size(ei{idxfound}.px,1),frequency,nfractal,kellytables{idxfound});
        
        if ~isempty(trade)
            %remove the pending trade from pending book
            %and add the new trade to book
            obj.book_.push(trade);
            exporttrade2mt4(trade,ei{idxfound});
            pendingtrades2remove.push(trade_i);
%             obj.pendingbook_.removebyindex(i);
            %note:pending trade is activated and no need to export its
            %status anymore
        else
            if isempty(signals{idxfound})
                pendingtrades2remove.push(trade_i);
                trade_i.status_ = 'closed';
%                 obj.pendingbook_.removebyindex(i);
                exporttrade2mt4(trade_i,ei{idxfound});
            else
                if signals{idxfound}.directionkellied == 0
                    trade_i.status_ = 'closed';
                    pendingtrades2remove.push(trade_i);
%                     obj.pendingbook_.removebyindex(i);
                    exporttrade2mt4(trade_i,ei{idxfound});
                end
            end
        end
    end
    
    n2remove = pendingtrades2remove.latest_;
    for i = 1:n2remove
        trade2remove_i = pendingtrades2remove.node_(i);
        for j = 1:obj.pendingbook_.latest_
            if strcmpi(trade2remove_i.code_,obj.pendingbook_.node_(j).code_)
                obj.pendingbook_.removebyindex(j);
%                 idxfound = 0;
%                 for k = 1:size(codes,1)
%                     if strcmpi(codes{k},trade2remove_i.code_)
%                         idxfound = k;
%                         break
%                     end
%                 end
%                 exporttrade2mt4(trade2remove_i,ei{idxfound});
                break;
            end
        end
    end
    %
    for i = 1:obj.pendingbook_.latest_
        trade_i = obj.pendingbook_.node_(i);
        idxfound = 0;
        for j = 1:size(codes,1)
            if strcmpi(codes{j},trade_i.code_)
                idxfound = j;
                break
            end
        end
        exporttrade2mt4(trade_i,ei{idxfound});
    end
    
    
    
    
    
end