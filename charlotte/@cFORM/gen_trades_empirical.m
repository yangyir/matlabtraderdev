function [] = gen_trades_empirical(obj,varargin)
% a cFORM private function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('override',0,@isnumeric);
    p.addParameter('executionmethod','HFI',@ischar);
    p.parse(varargin{:});
    em = p.Results.executionmethod;
    overrideflag = p.Results.override;

    if isempty(obj.condsignals_empirical_)
        return
    end
    
    genflag = false;
    if overrideflag
        genflag = true;
    else
        if isempty(obj.trades_empirical_)
            genflag = true;
        end
    end

    if ~genflag
        fprintf('gen_trades_empirical:done...\n')
        return
    end

    ncodes = size(obj.codes_,1);

    trades_empirical = cell(ncodes,1);

    

    codes = obj.codes_;
    condsignals = obj.condsignals_empirical_;
    ei_signal = obj.ei_signal_;

    parfor i = 1:ncodes
        
        trades_i = cTradeOpenArray;
        condsignals_i = condsignals{i};
        ei_signal_i = ei_signal{i};
        nbars_i = size(ei_signal_i.px,1);

        for j = 2:nbars_i
            if isempty(condsignals_i{j-1}), continue;end
            if condsignals_i{j-1,1} == 0, continue;end

            trade = gen_trade_empirical(obj,'code',codes{i},...
                'idx',j,....
                'condsignal',condsignals_i{j-1,2},...
                'executionmethod',em);
            if ~isempty(trade)
                trades_i.push(trade);
            end
        end
        trades_empirical{i} = trades_i;
    end
    %
    obj.trades_empirical_ = trades_empirical;

    fprintf('gen_trades_empirical:done...\n')

end