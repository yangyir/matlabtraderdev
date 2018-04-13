function [] = printpositions(obj)
%cBook
    if isempty(obj.positions_)
        fprintf('\n本子-%s:\n',obj.bookname_);
        fprintf('empty book......\n');
        return
    end
    
    fprintf('\n本子-%s:\n',obj.bookname_);
    fprintf('%s%12s%10s%9s%10s\n','合约','买卖','持仓','今仓','开仓均价');
    for i = 1:size(obj.positions_,1)
%         obj.positions_{i}.print;
        p = obj.positions_{i};
        isopt = isoptchar(p.code_ctp_);
        if ~isopt
            dataformat = '%s%11s%11s%11s%15s\n';
        else
            dataformat = '%s%5s%11s%11s%15s\n';
        end
        fprintf(dataformat,p.code_ctp_,num2str(p.direction_),...
            num2str(p.position_total_),...
            num2str(p.position_today_),...
            num2str(p.cost_open_));
        
            
    end
end
