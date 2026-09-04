function [tradesout] = gettradesempirical(obj,varargin)
% a cFORM utility function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('datefrom','',@ischar);
    p.addParameter('dateto','',@ischar);
    p.parse(varargin{:});

    code = p.Results.code;

    [flag,idx] = obj.hascode(code);

    if ~flag
        tradesout = [];
        return
    end

    dt1str = p.Results.datefrom;
    dt2str = p.Results.dateto;

    if ~isempty(dt1str)
        dt1num = datenum([dt1str,' 00:00:00'],'yyyy-mm-dd HH:MM:SS');
    else
        dt1num = [];
    end

    if ~isempty(dt2str)
        dt2num = datenum([dt2str,' 23:59:59'],'yyyy-mm-dd HH:MM:SS');
    else
        dt2num = [];
    end

    trades_empirical_i = obj.trades_empirical_{idx};

    tradesout = cTradeOpenArray;

    for i = 1:trades_empirical_i.latest_
        trade_i = trades_empirical_i.node_(i);
        use_i = 1;
        if ~isempty(dt1num) && trade_i.opendatetime1_ < dt1num
            use_i = 0;
        end
        if ~isempty(dt2num) && trade_i.opendatetime1_ >= dt2num
            use_i = 0;
        end
        if ~use_i, continue;end
%         tradenew_i = trade_i.copy;
        tradesout.push(trade_i);
    end

end