function [] = init(obj,codestr)
%cQuoteOpt
    [flag,optiontype,strike,underlierstr] = isoptchar(codestr);
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
        opt = code2instrument(codestr);
        obj.opt_expiry_date1 = opt.opt_expiry_date1;
        obj.opt_expiry_date2 = opt.opt_expiry_date2;

        obj.init_flag = true;
        
        if ~isempty(strfind(codestr,'cu')) || ~isempty(strfind(codestr,'IO')) || ~isempty(strfind(codestr,'MO')) || || ~isempty(strfind(codestr,'HO'))
            obj.opt_american = false;
        end
        
    else
        obj.init_flag = false;
    end
end