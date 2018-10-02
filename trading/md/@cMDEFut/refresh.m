function [] = refresh(mdefut,varargin)
    if ~isempty(mdefut.qms_)
        if strcmpi(mdefut.mode_,'realtime')
            %refresh qms with the latest market quotes
            mdefut.qms_.refresh;
            %save ticks data into memory
            mdefut.saveticks2mem;
            %save candles data into memory
            mdefut.updatecandleinmem;
        %    
        elseif strcmpi(mdefut.mode_,'replay')
            mdefut.refreshreplaymode2;
        end
    end
end
%end of refresh