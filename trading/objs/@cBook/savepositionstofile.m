function [] = savepositionstofile(obj,fn,varargin)
%cBook
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('time',now,@(x) validateattributes(x,{'char','numeric'},{},'','time'));
    p.parse(varargin{:});
    time = p.Results.time;
    if ischar(time)
        timestr = time;
    else
        timestr = datestr(time,'yyyy-mm-dd HH:MM:SS');
    end

    fid = fopen(fn,'w');
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','BookName','TraderName','CounterName',...
                'Code','Direction','Volume','CostOpen','RecordDateTime');
    for i = 1:size(obj.positions_);
        pos_i = obj.positions_{i};
        code_i = pos_i.code_ctp_;
        direction_i = pos_i.direction_;
        v_i = pos_i.position_total_;
        cost_open_i = pos_i.cost_open_;
        if v_i ~= 0
            fprintf(fid,'%s\t%s\t%s\t%s\t%d\t%d\t%f\t%s\n',obj.bookname_,...
                obj.tradername_,...
                obj.countername_,...
                code_i,direction_i,v_i,cost_open_i,timestr);
        end
    end
    fclose(fid);
end