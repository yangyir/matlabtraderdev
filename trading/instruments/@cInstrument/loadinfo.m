function [] = loadinfo(obj,fn_)
    fid = fopen(fn_,'r');
    if fid < 0
        return
    end
    line_ = fgetl(fid);
    while ischar(line_)
        lineinfo = regexp(line_,'\t','split');
        propname = lineinfo{1};
        propvalue = lineinfo{2};
        propvalue_num = str2double(propvalue);
        if isnan(propvalue_num)
            obj.(propname) = propvalue;
        else
            obj.(propname) = propvalue_num;
        end
        line_ = fgetl(fid);
    end

    fclose(fid);
end
%end of loadinfo

