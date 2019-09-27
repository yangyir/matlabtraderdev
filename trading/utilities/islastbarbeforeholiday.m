function [flag] = islastbarbeforeholiday(instrument,freq,dtin)
    cobd = floor(dtin);
    nextbd = businessdate(cobd);
    if nextbd - cobd <= 3
        flag = false;
        return
    end
    
    hh = hour(dtin);
    if ~(hh == 14 || hh == 15)
        flag = false;
        return
    end
    
    if ischar(instrument)
        instrument = code2instrument(instrument);
    end
    
    if ~isempty(strfind(instrument.code_bbg,'TFT')) || ~isempty(strfind(instrument.code_bbg,'TFC'))
        isgovtbond = true;
    else
        isgovtbond = false;
    end
    
    mm = minute(dtin);
    
    if ~isgovtbond
        switch freq
            case '1m'
                flag = hh == 14 && mm == 59;
            case '3m'
                flag = hh == 14 && mm == 57;
            case '5m'
                flag = hh == 14 && mm == 55;
            case '15m'
                flag = hh == 14 && mm == 45;
            case '30m'
                flag = hh == 14 && mm == 30;
            otherwise
                flag = false;
        end
    else
        switch freq
            case '1m'
                flag = hh == 15 && mm == 14;
            case '3m'
                flag = hh == 15 && mm == 12;
            case '5m'
                flag = hh == 15 && mm == 10;
            case '15m'
                flag = hh == 15 && mm == 00;
            case '30m'
                flag = hh == 14 && mm == 45;
            otherwise
                flag = false;
        end
    end
    
    
end