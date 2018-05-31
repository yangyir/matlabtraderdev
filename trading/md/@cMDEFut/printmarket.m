function [] = printmarket(obj)
    quotes = obj.qms_.getquote;
    n = size(quotes,1);
    if n == 0, return; end
    
    fprintf('�����г�����:\n');
    fprintf('%9s%9s%9s%9s\n','��Լ','���','����','ʱ��');
    for i = 1:n
        code = quotes{i}.code_ctp;
        bid = quotes{i}.bid1;
        ask = quotes{i}.ask1;
        timet = datestr(quotes{i}.update_time1,'HH:MM:SS');
        dataformat = '%11s%11s%11s%12s\n';
        
        fprintf(dataformat,code,num2str(bid),num2str(ask),timet);
    end

end

