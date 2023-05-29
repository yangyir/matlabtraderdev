function [use,winprob,kellycriterion] = fractal_getkellywithsignal(longshort,signalmode,freq)
%FRACTAL_GETKELLYWITHSIGNAL Summary of this function goes here
%   get useflag and kelly criterion based on emprical study
    
    if strcmpi(freq,'intraday')
        fn_l = [getenv('onedrive'),'\fractal backtest\tbl_l_intraday.mat'];
        data = load(fn_l);
        vlookuptbl_l = data.tbl_l_intraday;
        fn_s = [getenv('onedrive'),'\fractal backtest\tbl_s_intraday.mat'];
        data = load(fn_s);
        vlookuptbl_s = data.tbl_s_intraday;    
    elseif strcmpi(freq,'daily')
    
    end
    
    if longshort == 1
        idx = strcmpi(vlookuptbl_l.opensignal_l_unique,signalmode);
        winprob = vlookuptbl_l.winprob_unique_l(idx);
        kellycriterion = vlookuptbl_l.kelly_unique_l(idx);
        if strcmpi(signalmode,'volblowup') || ...
                strcmpi(signalmode,'breachup-lvlup') || ...
                strcmpi(signalmode,'breachup-sshighvalue') || ...
                strcmpi(signalmode,'breachup-highsc13') || ...
                strcmpi(signalmode,'strongbreach-trendconfirmed') || ...
                strcmpi(signalmode,'mediumbreach-trendconfirmed') || ...
                strcmpi(signalmode,'volblowup2')
            use = 1;
        else
            if kellycriterion <= 0
                use = 0;
            else
                if kellycriterion > 0.15
                    use = 1;
                else
                    use = 0;
                end
            end
        end
    elseif longshort == -1
        idx = strcmpi(vlookuptbl_s.opensignal_s_unique,signalmode);
        winprob = vlookuptbl_s.winprob_unique_s(idx);
        kellycriterion = vlookuptbl_s.kelly_unique_s(idx);
        if strcmpi(signalmode,'volblowup') || ...
                strcmpi(signalmode,'breachdn-lvldn') || ...
                strcmpi(signalmode,'breachdn-bshighvalue') || ...
                strcmpi(signalmode,'breachdn-lowsc13') || ...
                strcmpi(signalmode,'strongbreach-trendconfirmed') || ...
                strcmpi(signalmode,'mediumbreach-trendconfirmed') || ...
                strcmpi(signalmode,'volblowup2')
            use = 1;
        else
            if kellycriterion <= 0
                use = 0;
            else
                if kellycriterion > 0.15
                    use = 1;
                else
                    use = 0;
                end
            end
        end
    end
    


end

