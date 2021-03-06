function [] = printallentrusts(obj)
    try
        n = obj.entrusts_.latest;
    catch
        % obj.entrusts_ is not initialized
        n = 0;
    end
    
    if n == 0
        fprintf(['\n',obj.book_.bookname_,'\n->all entrusts:none!\n'])
        return
    end

    fprintf(['\n',obj.book_.bookname_,'\n->all entrusts:\n'])

    fprintf('\t%18s%18s%12s%12s%12s%12s%12s%12s%20s\n','entrustnumber','instrument','buy/sell',...
        'open/close','status','price','volume','dealvolume','dealtime');

    for i = 1:n
        fprintf('\t');
        fprintf('%18d',obj.entrusts_.node(i).entrustNo);
        fprintf('%18s',obj.entrusts_.node(i).instrumentCode);
        if obj.entrusts_.node(i).direction == 1
            fprintf('%12s','buy');
        else
            fprintf('%12s','sell');
        end
        if obj.entrusts_.node(i).offsetFlag == 1
            fprintf('%12s','open');
        else
            fprintf('%12s','close');
        end

        if obj.entrusts_.node(i).volume == obj.entrusts_.node(i).dealVolume
            fprintf('%12s','settled');
        elseif obj.entrusts_.node(i).cancelVolume > 0
            fprintf('%12s','cancelled');
        else
            fprintf('%12s','pending');
        end

        if obj.entrusts_.node(i).volume == obj.entrusts_.node(i).dealVolume
            fprintf('%12s',num2str(obj.entrusts_.node(i).price));
        else
            fprintf('%12s',num2str(obj.entrusts_.node(i).price));
        end
        fprintf('%12d',obj.entrusts_.node(i).volume);
        fprintf('%12d',obj.entrusts_.node(i).dealVolume);
        fprintf('%20s',datestr(obj.entrusts_.node(i).time,'mm-dd HH:MM:SS'));
        fprintf('\n');
    end


end