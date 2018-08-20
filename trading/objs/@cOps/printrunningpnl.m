function [] = printrunningpnl(obj,varargin)
    %note:yangyiran 20180815
    %instead of using obj.book_.positions_, we use obj.trades_ to pop-up
    %the latest positions
    
    %1.compute the close pnl
    closepnl = 0;
    try
        ntrades = obj.trades_.latest_;
    catch
        ntrades = 0;
    end
    for i = 1:ntrades
        if strcmpi(obj.trades_.node_(i).status_,'closed')
            closepnl = closepnl + obj.trades_.node_(i).closepnl_;
        end
    end
    
    try
        positions = obj.trades_.convert2positions;
    catch
        positions = {};
    end
    
    %2.compute the running pnl
    if isempty(positions)
        fprintf('\n%s->empty book;...close pnl:%s......\n',obj.book_.bookname_,num2str(closepnl));
        return
    end
    
    holding = 0;
    for i = 1:size(positions,1)
        holding = holding + positions{i}.position_total_;
    end
    if holding == 0
        fprintf('\n%s->empty book;...close pnl:%s......\n',obj.book_.bookname_,num2str(closepnl));
        return
    end
    
    runningpnl = zeros(size(positions,1),1);
    fprintf('\n%s->close pnl:%s\n',obj.book_.bookname_,num2str(closepnl));
    fprintf('%s%12s%10s%9s%10s%12s\n','合约','买卖','持仓','今仓','开仓均价','盈亏');
    for i = 1:size(positions,1)
        p = positions{i};
        if p.position_total_ == 0, continue;end
        isopt = isoptchar(p.code_ctp_);
        if ~isopt
            dataformat = '%6s%11s%11s%11s%15s%15s\n';
        else
            dataformat = '%s%5s%11s%11s%15s%15s\n';
        end
        runningpnl(i) = p.calc_pnl(varargin{:});
        fprintf(dataformat,p.code_ctp_,num2str(p.direction_),...
            num2str(p.position_total_),...
            num2str(p.position_today_),...
            num2str(p.cost_open_),...
            num2str(runningpnl(i)));
    end
    
end