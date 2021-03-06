function [runingpnl,closedpnl] = calcpnl(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','all',@ischar);
    p.parse(varargin{:});
    codestr = p.Results.Code;
    
    if ~strcmpi(codestr,'all')
        instrumentstrs = regexp(codestr,',','split');
    else
        n = obj.trades_.latest_;
        instrumentstrs = cell(n,1);
        for i = 1:n, instrumentstrs{i} = obj.trades_.node_(i).code_; end
    end
    instrumentstrs = unique(instrumentstrs);
    n = size(instrumentstrs,1);
    %the 1st column is the running pnl associated with long positions, the
    %2nd column is the running pnl associated with short positions
    runingpnl = zeros(n,2);
    %the 1st column is the closed pnl associated with long positions, the
    %2nd column is the closed pnl associated with short positions
    closedpnl = zeros(n,2);
    
    %compute runnning pnl
    try
        for i = 1:n
            [flong,idxlong] = obj.book_.haslongposition(instrumentstrs{i});
            if flong && idxlong > 0
                runingpnl(i,1) = obj.book_.positions_{idxlong}.calc_pnl(varargin{:});
            end
            %
            [fshort,idxshort] = obj.book_.hasshortposition(instrumentstrs{i});
            if fshort && idxshort > 0
                runingpnl(i,2) = obj.book_.positions_{idxshort}.calc_pnl(varargin{:});
            end
        end
    catch err
        error('cOps:calcpnl:error in compute running pnl:%s',err.message)
    end
    
    %compute closed pnl
    try
        for i = 1:n
            trades = obj.trades_.filterby('Code',instrumentstrs{i},'Status','closed');
            nclosed = trades.latest_;
            if nclosed == 0
                closedpnl(i,:) = 0;
            else
                for itrade = 1:nclosed
                    trade = trades.node_(itrade);
                    %the trade's closepnl maynot be updated yet
                    if trade.opendirection_ == 1
                        try
                            closedpnl(i,1) = closedpnl(i,1) + trade.closepnl_;
                        catch
                            pause(obj.timer_interval_);
                        end
                    else
                        try
                            closedpnl(i,2) = closedpnl(i,2) + trade.closepnl_;
                        catch
                            pause(obj.timer_interval_);
                        end
                    end
                end
            end
        end
    catch err
        error('cOps:calcpnl:error in compute closed pnl:%s',err.message)
    end
    
end