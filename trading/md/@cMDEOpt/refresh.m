function [] = refresh(obj)
    if ~isempty(obj.qms_)
        if strcmpi(obj.mode_,'realtime')
            obj.qms_.refresh;
        else
            return
%                     error('to be finished')
        end

        obj.savequotes2mem;
        
        fprintf('%s mdeopt runs......\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
        if obj.display_, obj.displaypivottable; end

    end
end
%end of refresh