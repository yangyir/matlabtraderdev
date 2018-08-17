function [ret] = placeEntrust(obj, entrust)
% function [ret] = placeEntrust(obj, entrust)
ret = false;
if ~isa(entrust, 'Entrust')
    return;
end

switch entrust.assetType
    case 'Option'
        % 发一个订单，如成功，记录
        % 特殊处理一下direction和kp， HSO32里用 '1' , '2'
        d   = entrust.get_CounterHSO32_direction;
        kp  = entrust.get_CounterHSO32_offset;
        
        [errorCode,errorMsg,entrustNo] = obj.optPlaceEntrust( ...
            entrust.marketNo, ...
            entrust.instrumentCode, ...
            d, ...
            kp, ...
            entrust.price, ...
            entrust.volume);
        
        if errorCode == 0
            fprintf('[%d]委托成功{%s, %s, %d, %0.4f}\n', entrustNo, d, kp, entrust.volume, entrust.price);
            ret = true;
            entrust.entrustNo = entrustNo;
            entrust.entrustStatus = 2;
            entrust.date    = today;
            entrust.time    = now;
            entrust.is_entrust_closed;
        else
            disp(['下单失败。错误信息为:',errorMsg]);
            return;
        end
        
        
    case 'ETF'
        d = entrust.get_CounterHSO32_direction;
        % 发一个订单
        [errorCode,errorMsg,entrustNo] = obj.entrust( ...
            entrust.marketNo, ...
            entrust.instrumentCode, ...
            d, ...
            entrust.price, ...
            entrust.volume);
        
        if errorCode == 0
            fprintf('[%d]委托成功{%s, %d, %0.4f}\n', entrustNo, d, entrust.volume, entrust.price);
            ret = true;
            entrust.entrustNo = entrustNo;
            entrust.entrustStatus = 2;
            entrust.is_entrust_closed;
        else
            disp(['下单失败。错误信息为:',errorMsg]);
            return;
        end
        
    case 'Future'
        % 特殊处理一下direction和kp， HSO32里用 '1' , '2'
        d   = entrust.get_CounterHSO32_direction;
        kp  = entrust.get_CounterHSO32_offset;
        
        % 发一个订单，如成功，记录
        [errorCode,errorMsg,entrustNo] = obj.futPlaceEntrust( ...
            entrust.marketNo, ...
            entrust.instrumentCode, ...
            d, ...
            kp, ...
            entrust.price, ...
            entrust.volume);
        
        if errorCode == 0
            fprintf('[%d]委托成功{%s, %s, %d, %0.4f}\n', entrustNo, d, kp, entrust.volume, entrust.price);
            ret = true;
            entrust.entrustNo = entrustNo;
            entrust.entrustStatus = 2;
            entrust.date    = today;
            entrust.time    = now;
            entrust.is_entrust_closed;
        else
            disp(['下单失败。错误信息为:',errorMsg]);
            return;
        end
end
end