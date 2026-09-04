function [] = gen_trades_best(obj)
% a cFORM private methods
% it generates the trades with the best open price, i.e. its open price is
% assumed to be the barrier
% in reality the open price would be worsen, and thus leads to a worse
% kelly lookup table

    ncodes = length(obj.codes_);
    nfractal_signal = charlotte_freq2nfractal(obj.signal_freq_);
    use_conditional_open = 1;

    codes_ = obj.codes_;
    ei = obj.ei_signal_;
    instruments_ = obj.instruments_;
    include_tdsqlvl_ = obj.include_tdsqlvl_;
    include_tdsqhv_ = obj.include_tdsqhv_;
    signal_freq_ = obj.signal_freq_;
    trades_best_ = cell(ncodes,1);
%     for i = 1:ncodes
%         trades_best_{i} = cTradeOpenArray;
%     end

    parfor i = 1:ncodes

        ei_i = ei{i};
        ticksizeratio = 1;
        trades_best_i_ = cTradeOpenArray;
        
        %
        [idxb1_i,idxs1_i] = fractal_genindicators1(ei_i.px,...
            ei_i.hh,...
            ei_i.ll,...
            ei_i.jaw,...
            ei_i.teeth,...
            ei_i.lips,...
            'instrument',instruments_{i},...
            'ticksizeratio',ticksizeratio);
        %       
        nb_i = size(idxb1_i,1);
        ns_i = size(idxs1_i,1);

        ticksize = instruments_{i}.tick_size;

        % LONG TRADES
        for j = 1:nb_i
            k = idxb1_i(j,1);
            b1type = idxb1_i(j,2);
            extrainfo = fractal_truncate(ei_i,k);
            try
                [op,status] = fractal_filterb1_singleentry(b1type,nfractal_signal,extrainfo,ticksizeratio*ticksize);
            catch
                fprintf('fractal_filterb1_singleentry error on %s with idx %5d\n',codes_{i},k);
            end
            poptrade = false;
            if status.istrendconfirmed
                poptrade = true;
            else
                if include_tdsqlvl_ && status.islvlupbreach && strcmpi(op.comment,'breachup-lvlup')
                    poptrade = true;
                end
                if include_tdsqhv_ && status.issshighbreach && strcmpi(op.comment,'breachup-sshighvalue')
                    poptrade = true;
                end
            end
            if poptrade
                try
                    trade = fractal_gentrade(ei_i,codes_{i},k,op.comment,1,signal_freq_,nfractal_signal,use_conditional_open);
                catch
                    fprintf('fractal_gentrade error when to create long trade on %s\n',codes_{i});
                end
                trade.riskmanager_.setusefractalupdateflag(0);
                trade.riskmanager_.setusefibonacciflag(1);
                if status.istrendconfirmed
                    trade.countername_ = 'tc';
                else
                    trade.countername_ = 'tb';
                end
                trades_best_i_.push(trade);
            end
        end

        % SHORT TRADES
        for j = 1:ns_i
            k = idxs1_i(j,1);
            s1type = idxs1_i(j,2);
            extrainfo = fractal_genextrainfo(ei_i,k);
            try
                [op,status] = fractal_filters1_singleentry(s1type,nfractal_signal,extrainfo,ticksizeratio*ticksize);
            catch
                fprintf('fractal_filters1_singleentry error on %s with idx %5d\n',codes_{i},k);
            end
            poptrade = false;
            if status.istrendconfirmed
                poptrade = true;
            else
                if include_tdsqlvl_ && status.islvldnbreach && strcmpi(op.comment,'breachdn-lvldn')
                    poptrade = true;
                end
                if include_tdsqhv_ && status.isbslowbreach && strcmpi(op.comment,'breachdn-bshighvalue')
                    poptrade = true;
                end
            end
            if poptrade
                try
                    trade = fractal_gentrade(ei_i,codes_{i},k,op.comment,-1,signal_freq_,nfractal_signal,use_conditional_open);
                catch
                    fprintf('fractal_gentrade error when to create short trade on %s\n',codes_{i});
                end
                trade.riskmanager_.setusefractalupdateflag(0);
                trade.riskmanager_.setusefibonacciflag(1);
                if status.istrendconfirmed
                    trade.countername_ = 'tc';
                else
                    trade.countername_ = 'tb';
                end
                trades_best_i_.push(trade);
            end
        end
        trades_best_{i} = trades_best_i_;
        fprintf('finish generating best trades of %s...\n',codes_{i});
    end
    
    obj.trades_best_ = trades_best_;
    
end