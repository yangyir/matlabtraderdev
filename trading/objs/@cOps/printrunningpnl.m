function [] = printrunningpnl(obj,varargin)
    %note:yangyiran 20180815
    %instead of using obj.book_.positions_, we use obj.trades_ to pop-up
    %the latest positions
    positions = obj.trades_.convert2positions;
    
    if isempty(positions)
        fprintf('\n����-%s:\n',obj.book_.bookname_);
        fprintf('empty book......\n');
        return
    end
    
    holding = 0;
    for i = 1:size(positions,1)
        holding = holding + positions{i}.position_total_;
    end
    if holding == 0
        fprintf('\n����-%s:\n',obj.book_.bookname_);
        fprintf('empty book......\n');
        return
    end
    
    pnl = zeros(size(positions,1),1);
    fprintf('\n����-%s:\n',obj.book_.bookname_);
    fprintf('%s%12s%10s%9s%10s%12s\n','��Լ','����','�ֲ�','���','���־���','ӯ��');
    for i = 1:size(positions,1)
        p = positions{i};
        if p.position_total_ == 0, continue;end
        isopt = isoptchar(p.code_ctp_);
        if ~isopt
            dataformat = '%6s%11s%11s%11s%15s%15s\n';
        else
            dataformat = '%s%5s%11s%11s%15s%15s\n';
        end
        pnl(i) = p.cal_pnl(varargin{:});
        fprintf(dataformat,p.code_ctp_,num2str(p.direction_),...
            num2str(p.position_total_),...
            num2str(p.position_today_),...
            num2str(p.cost_open_),...
            num2str(pnl(i)));
    end
    
%     if isempty(obj.book_.positions_)
%         fprintf('\n����-%s:\n',obj.book_.bookname_);
%         fprintf('empty book......\n');
%         return
%     end
%     
%     holding = 0;
%     for i = 1:size(obj.book_.positions_,1)
%         holding = holding + obj.book_.positions_{i}.position_total_;
%     end
%     if holding == 0
%         fprintf('\n����-%s:\n',obj.book_.bookname_);
%         fprintf('empty book......\n');
%         return
%     end

%     pnl = obj.calcrunningpnl(varargin{:});
%     fprintf('\n����-%s:\n',obj.book_.bookname_);
%     fprintf('%s%12s%10s%9s%10s%12s\n','��Լ','����','�ֲ�','���','���־���','ӯ��');
%     for i = 1:size(obj.book_.positions_,1)
%         p = obj.book_.positions_{i};
%         if p.position_total_ == 0, continue;end
%         isopt = isoptchar(p.code_ctp_);
%         if ~isopt
%             dataformat = '%6s%11s%11s%11s%15s%15s\n';
%         else
%             dataformat = '%s%5s%11s%11s%15s%15s\n';
%         end
%         fprintf(dataformat,p.code_ctp_,num2str(p.direction_),...
%             num2str(p.position_total_),...
%             num2str(p.position_today_),...
%             num2str(p.cost_open_),...
%             num2str(pnl(i)));
%             
%     end
    
end