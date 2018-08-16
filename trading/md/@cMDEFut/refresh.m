function [] = refresh(mdefut,varargin)
    if ~isempty(mdefut.qms_)
        if strcmpi(mdefut.mode_,'realtime')
            mdefut.qms_.refresh;
            %save ticks data into memory
            mdefut.saveticks2mem;
            %save candles data into memory
            mdefut.updatecandleinmem;
            %
            if mdefut.display_ == 1, mdefut.printmarket;end
        %    
        elseif strcmpi(mdefut.mode_,'replay')
            mdefut.refreshreplaymode;
        end
    end
end
%end of refresh