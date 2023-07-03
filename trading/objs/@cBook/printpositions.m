function [] = printpositions(obj)
%cBook
    if isempty(obj.positions_)
        fprintf('\nbook-%s:\n',obj.bookname_);
        fprintf('empty book......\n');
        return
    end
    
    holding = 0;
    for i = 1:size(obj.positions_,1)
        try
            holding = holding + obj.positions_{i}.position_total_;
        catch
            holding = holding + 0;
        end
    end
    if holding == 0
        fprintf('\nbook-%s:\n',obj.bookname_);
        fprintf('empty book......\n');
        return
    end
    
    fprintf('\nbook-%s:\n',obj.bookname_);
    fprintf('%10s%12s%11s%11s%15s\n','contract','b/s','vol','volt','cost');
    for i = 1:size(obj.positions_,1)
        p = obj.positions_{i};
        if p.position_total_ == 0, continue;end
        isopt = isoptchar(p.code_ctp_);
        if ~isopt
            dataformat = '%10s%12s%11s%11s%15s\n';
        else
            dataformat = '%s%5s%11s%11s%15s\n';
        end
        fprintf(dataformat,p.code_ctp_,num2str(p.direction_),...
            num2str(p.position_total_),...
            num2str(p.position_today_),...
            num2str(p.cost_open_));
        
            
    end
end
