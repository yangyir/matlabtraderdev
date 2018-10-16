function [runingpnl,closedpnl] = calcpnl(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','all',@ischar);
    p.parse(varargin{:});
    codestr = p.Results.Code;
    
    if ~strcmpi(codestr,'all')
        instrumentstrs = regexp(codestr,',','split');
    else
        n = size(obj.book_.positions_,1);
        instrumentstrs = cell(n,1);
        for i = 1:n, instrumentstrs{i} = obj.book_.positions_{i}.code_ctp_; end
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
    
    %compute closed pnl
    for i = 1:n
        trades = obj.trades_.filterby('Code',instrumentstrs{i},'Status','closed');
        nclosed = trades.latest_;
        if nclosed == 0
            closedpnl(i,:) = 0;
        else
            for itrade = 1:nclosed
                trade = trades.node_(itrade);
                if trade.opendirection_ == 1
                    closedpnl(i,1) = closedpnl(i,1) + trade.closepnl_;
                else
                    closedpnl(i,2) = closedpnl(i,2) + trade.closepnl_;
                end
            end
        end
    end
    
    
    
%     
%     if ~strcmpi(codestr,'all')
%         instrumentstrs = regexp(codestr,',','split');
%         n = length(instrumentstrs);
%         runingpnl = zeros(n,2);
%         for i = 1:n
%             [flong,idxlong] = obj.book_.haslongposition(instrumentstrs{i});
%             if flong && idxlong > 0
%                 runingpnl(i,1) = obj.book_.positions_{idxlong}.calc_pnl(varargin{:});
%             end
%             %
%             [fshort,idxshort] = obj.book_.hasshortposition(instrumentstrs{i});
%             if fshort && idxshort > 0
%                 runingpnl(i,2) = obj.book_.positions_{idxshort}.calc_pnl(varargin{:});
%             end
%         end
%         return
%     end
%     
%     n = size(obj.book_.positions_,1);
%     instrumentstrs = cell(n,1);
%     for i = 1:n
%         instrumentstrs{i} = obj.book_.positions_{i}.code_ctp_;
%     end
%     instrumentstrs = unique(instrumentstrs);
%     n = size(instrumentstrs,1);
%     runingpnl = zeros(n,2);
%     for i = 1:n
%         [flong,idxlong] = obj.book_.haslongposition(instrumentstrs{i});
%         if flong && idxlong > 0
%             runingpnl(i,1) = obj.book_.positions_{idxlong}.calc_pnl(varargin{:});
%         end
%         %
%         [fshort,idxshort] = obj.book_.hasshortposition(instrumentstrs{i});
%         if fshort && idxshort > 0
%             runingpnl(i,2) = obj.book_.positions_{idxshort}.calc_pnl(varargin{:});
%         end
%     end
    
end