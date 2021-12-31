function [] = loadinfo(obj,fn_)
    fid = fopen(fn_,'r');
    if fid < 0
        if isa(obj,'cStock')
            fn_ = [getenv('datapath'),'info_stock\',fn_];
        elseif isa(obj,'cFutures')
            fn_ = [getenv('datapath'),'info_futures\',fn_];
        elseif isa(obj,'cOption')
            fn_ = [getenv('datapath'),'info_option\',fn_];
        else
            return
        end
        fid = fopen(fn_,'r');
        if fid < 0
            return
        end
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
            try
                obj.(propname) = propvalue_num;
            catch
                obj.(propname) = propvalue;
            end
        end
        line_ = fgetl(fid);
    end

    fclose(fid);
end
%end of loadinfo

