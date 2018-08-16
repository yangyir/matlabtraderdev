function [] = printrunningpnl(obj,varargin)
    %note:yangyiran 20180815
    %instead of using obj.book_.positions_, we use obj.trades_ to pop-up
    %the latest positions
    closepnl = 0;
    for i = 1:obj.trades_.latest_
        if strcmpi(obj.trades_.node_(i).status_,'closed')
            closepnl = closepnl + obj.trades_.node_(i).closepnl_;
        end
    end
    
    positions = obj.trades_.convert2positions;
    
    if isempty(positions)
        fprintf('\n本子-%s:close pnl:%s\n',obj.book_.bookname_,num2str(closepnl));
        fprintf('empty book......\n');
        return
    end
    
    holding = 0;
    for i = 1:size(positions,1)
        holding = holding + positions{i}.position_total_;
    end
    if holding == 0
        fprintf('\n本子-%s:close pnl:%s\n',obj.book_.bookname_,num2str(closepnl));
        fprintf('empty book......\n');
        return
    end
    
    pnl = zeros(size(positions,1),1);
    fprintf('\n本子-%s:close pnl:%s\n',obj.book_.bookname_,num2str(closepnl));
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
        pnl(i) = p.calc_pnl(varargin{:});
        fprintf(dataformat,p.code_ctp_,num2str(p.direction_),...
            num2str(p.position_total_),...
            num2str(p.position_today_),...
            num2str(p.cost_open_),...
            num2str(pnl(i)));
    end
    
end