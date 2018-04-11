function [] = init(obj,codestr)
%cQuoteOpt
    [flag,optiontype,strike,underlierstr,expiry] = isoptchar(codestr);
    if flag
        obj.code_ctp = str2ctp(codestr);
        obj.code_wind = ctp2wind(obj.code_ctp);
        obj.code_bbg = ctp2bbg(obj.code_ctp);
        %
        obj.code_ctp_underlier = str2ctp(underlierstr);
        obj.code_wind_underlier = ctp2wind(obj.code_ctp_underlier);
        obj.code_bbg_underlier = ctp2bbg(obj.code_ctp_underlier);

        obj.opt_type = optiontype;
        if ischar(strike)
            obj.opt_strike = str2double(strike);
        else
            obj.opt_strike = strike;
        end
        obj.opt_expiry_date1 = expiry;
        obj.opt_expiry_date2 = datestr(expiry,'yyyy-mm-dd');

        obj.init_flag = true;
    else
        obj.init_flag = false;
    end
end