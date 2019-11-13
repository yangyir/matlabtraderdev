function [] = riskmanagement_futmultitdsq2(strategy,varargin)
%cStratFutMultiTDSQ
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','',@ischar);
    p.parse(varargin{:});
    code = p.Results.Code;
    
    trade_perfectbs = strategy.getlivetrade_tdsq(code,'reverse','perfectbs');
    trade_semiperfectbs = strategy.getlivetrade_tdsq(code,'reverse','semiperfectbs');
    trade_imperfectbs = strategy.getlivetrade_tdsq(code,'reverse','imperfectbs');
    trade_perfectss = strategy.getlivetrade_tdsq(code,'reverse','perfectss');
    trade_semiperfectss = strategy.getlivetrade_tdsq(code,'reverse','semiperfectss');
    trade_imperfectss = strategy.getlivetrade_tdsq(code,'reverse','imperfectss');
    trade_singlelvldn = strategy.getlivetrade_tdsq(code,'trend','single-lvldn');
    trade_singlelvlup = strategy.getlivetrade_tdsq(code,'trend','single-lvlup');
    trade_doublerange = strategy.getlivetrade_tdsq(code,'trend','double-range');
    trade_doublebullish = strategy.getlivetrade_tdsq(code,'trend','double-bullish');
    trade_doublebearish = strategy.getlivetrade_tdsq(code,'trend','double-bearish');
    trade_simpletrend = strategy.getlivetrade_tdsq(code,'trend','simpletrend');

    if ~isempty(trade_perfectbs)
        if strcmpi(trade_perfectbs.status_,'unset'), trade_perfectbs.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_perfectbs(trade_perfectbs);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:perfectbs!!!\n',strategy.name_)
        end
    end
        
    if ~isempty(trade_semiperfectbs)
        if strcmpi(trade_semiperfectbs.status_,'unset'), trade_semiperfectbs.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_imperfectbs(trade_semiperfectbs);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:semiperfectbs!!!\n',strategy.name_)
        end
    end

    if ~isempty(trade_imperfectbs)
        if strcmpi(trade_imperfectbs.status_,'unset'), trade_imperfectbs.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_imperfectbs(trade_imperfectbs);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:imperfectbs!!!\n',strategy.name_)
        end
    end

    if ~isempty(trade_perfectss)
        if strcmpi(trade_perfectss.status_,'unset'), trade_perfectss.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_perfectss(trade_perfectss);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:perfectss!!!\n',strategy.name_)
        end
    end

    if ~isempty(trade_semiperfectss)
        if strcmpi(trade_semiperfectss.status_,'unset'), trade_semiperfectss.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_imperfectss(trade_semiperfectss);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:semiperfectss!!!\n',strategy.name_)
        end
    end

    if ~isempty(trade_imperfectss)
        if strcmpi(trade_imperfectss.status_,'unset'), trade_imperfectss.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_imperfectss(trade_imperfectss);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:imperfectss!!!\n',strategy.name_)
        end
    end
    
    if ~isempty(trade_singlelvldn)
        if strcmpi(trade_singlelvldn.status_,'unset'), trade_singlelvldn.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_singlelvldn(trade_singlelvldn);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:singlelvldn!!!\n',strategy.name_)
        end  
    end
    
    if ~isempty(trade_singlelvlup)
        if strcmpi(trade_singlelvlup.status_,'unset'), trade_singlelvlup.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_singlelvlup(trade_singlelvlup);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:singlelvlup!!!\n',strategy.name_)
        end
    end
    
    if ~isempty(trade_doublerange)
        if strcmpi(trade_doublerange.status_,'unset'), trade_doublerange.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_doublerange(trade_doublerange);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:doublerange!!!\n',strategy.name_)
        end
    end
    
    if ~isempty(trade_doublebullish)
        if strcmpi(trade_doublebullish.status_,'unset'), trade_doublebullish.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_doublebullish(trade_doublebullish);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:doublebullish!!!\n',strategy.name_)
        end
    end
    
    if ~isempty(trade_doublebearish)
        if strcmpi(trade_doublebearish.status_,'unset'), trade_doublebearish.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_doublebearish(trade_doublebearish);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:doublebearish!!!\n',strategy.name_)
        end
    end
    
    if ~isempty(trade_simpletrend)
        if strcmpi(trade_simpletrend.status_,'unset'), trade_simpletrend.status_ = 'set';end
        [istrade2close,entrustplaced] = strategy.riskmanagement_simpletrend(trade_simpletrend);
        if istrade2close && ~entrustplaced
            fprintf('%s:trade shall be unwinded but entrust NOT placed:simpletrend!!!\n',strategy.name_)
        end
    end
    
end