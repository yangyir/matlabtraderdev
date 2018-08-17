function [ret] = placeEntrust(obj, entrust)
% function [ret] = placeEntrust(obj, entrust)
ret = false;
if ~isa(entrust, 'Entrust')
    return;
end

switch entrust.assetType
    case 'Option'
        % ��һ����������ɹ�����¼
        % ���⴦��һ��direction��kp�� HSO32���� '1' , '2'
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
            fprintf('[%d]ί�гɹ�{%s, %s, %d, %0.4f}\n', entrustNo, d, kp, entrust.volume, entrust.price);
            ret = true;
            entrust.entrustNo = entrustNo;
            entrust.entrustStatus = 2;
            entrust.date    = today;
            entrust.time    = now;
            entrust.is_entrust_closed;
        else
            disp(['�µ�ʧ�ܡ�������ϢΪ:',errorMsg]);
            return;
        end
        
        
    case 'ETF'
        d = entrust.get_CounterHSO32_direction;
        % ��һ������
        [errorCode,errorMsg,entrustNo] = obj.entrust( ...
            entrust.marketNo, ...
            entrust.instrumentCode, ...
            d, ...
            entrust.price, ...
            entrust.volume);
        
        if errorCode == 0
            fprintf('[%d]ί�гɹ�{%s, %d, %0.4f}\n', entrustNo, d, entrust.volume, entrust.price);
            ret = true;
            entrust.entrustNo = entrustNo;
            entrust.entrustStatus = 2;
            entrust.is_entrust_closed;
        else
            disp(['�µ�ʧ�ܡ�������ϢΪ:',errorMsg]);
            return;
        end
        
    case 'Future'
        % ���⴦��һ��direction��kp�� HSO32���� '1' , '2'
        d   = entrust.get_CounterHSO32_direction;
        kp  = entrust.get_CounterHSO32_offset;
        
        % ��һ����������ɹ�����¼
        [errorCode,errorMsg,entrustNo] = obj.futPlaceEntrust( ...
            entrust.marketNo, ...
            entrust.instrumentCode, ...
            d, ...
            kp, ...
            entrust.price, ...
            entrust.volume);
        
        if errorCode == 0
            fprintf('[%d]ί�гɹ�{%s, %s, %d, %0.4f}\n', entrustNo, d, kp, entrust.volume, entrust.price);
            ret = true;
            entrust.entrustNo = entrustNo;
            entrust.entrustStatus = 2;
            entrust.date    = today;
            entrust.time    = now;
            entrust.is_entrust_closed;
        else
            disp(['�µ�ʧ�ܡ�������ϢΪ:',errorMsg]);
            return;
        end
end
end