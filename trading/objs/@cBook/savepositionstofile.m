function [] = savepositionstofile(obj,fn)
%cBook
    fid = fopen(fn,'w');
    for i = 1:size(obj.positions_);
        pos_i = obj.positions_{i};
        code_i = pos_i.code_ctp_;
        direction_i = pos_i.direction_;
        v_i = pos_i.position_total_;
        cost_open_i = pos_i.cost_open_;
        if v_i ~= 0
            fprintf(fid,'%s\t%d\t%d\t%f\n',code_i,direction_i,v_i,cost_open_i);
        end
    end
    fclose(fid);
end