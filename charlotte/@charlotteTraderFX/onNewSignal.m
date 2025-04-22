function [] = onNewSignal(obj,~,eventData)
% a charlotteTraderFX function
    data = eventData.MarketData;
    n = size(data.signals_,1);
    for i = 1:n
        if isempty(data.signals_{i}), continue;end
        code_i = data.codes_{i};
        signal_i = data.signals_{i};
        if isempty(strfind(signal_i.opkellied,'conditional'))
            %unconditional signal
            if signal_i.directionkellied == 1 && ~obj.hasLongPosition(code_i)
                if ~signal_i.status.istrendconfirmed
                    
                else
                    %need to chec
                end
            elseif signal_i.directionkellied == -1 && ~obj.hasShortPosition(code_i)
                if ~signal_i.status.istrendconfirmed
                else
                end
            end
        else
        end
    end
end