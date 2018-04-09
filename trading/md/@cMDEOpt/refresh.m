function [] = refresh(obj)
    if ~isempty(obj.qms_)
        if strcmpi(obj.mode_,'realtime')
            obj.qms_.refresh;
        else
            return
%                     error('to be finished')
        end

        obj.savequotes2mem;

        if obj.display_, obj.displaypivottable; end

    end
end
%end of refresh