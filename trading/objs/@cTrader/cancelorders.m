function [ret,entrusts] = cancelorders(obj,codestr,ops,varargin)
%cTrader
    variablenotused(obj);
    if ~ischar(codestr), error('cTrader:cancelorders:invalid code input');end
    if ~isa(ops,'cOps'), error('cTrader:cancelorders:invalid ops input');end
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('time',[],@isnumeric);
    p.addParameter('direction',[],@isnumeric);
    p.addParameter('offset',[],@isnumeric);
    p.addParameter('price',[],@isnumeric);
    p.addParameter('volume',[],@isnumeric);
    p.parse(varargin{:});
    t = p.Results.time;
    direction = p.Results.direction;
    offset = p.Results.offset;
    price = p.Results.price;
    volume = p.Results.volume;
    
    use_direction = false;
    use_offset = false;
    use_price = false;
    use_volume = false;
    
    if ~isempty(direction), use_direction = true;end
    if ~isempty(offset), use_offset = true;end
    if ~isempty(price),use_price = true;end
    if ~isempty(volume),use_volume = true;end
    
    c = ops.book_.counter_;
    pe = ops.entrustspending_;
    ret = 0;
    entrusts = EntrustArray;
    for i = 1:pe.latest
        e = ops.entrustspending_.node(i);
        if strcmpi(e.instrumentCode,codestr)
            flag = true;
            if use_direction
                flag = flag & e.direction == direction;
            end
            if use_offset
                flag = flag & e.offsetFlag == offset;
            end
            if use_price
                flag = flag & e.price == price;
            end
            if use_volume
                flag = flag & e.volume == volume;
            end
            
            if ~flag, continue; end
            
            if strcmpi(ops.mode_,'realtime')
                ret = withdrawentrust(c,e);
                entrusts.push(e);
            elseif strcmpi(ops.mode_,'replay')
                ops.entrustspending_.removeByIndex(i);
                e.cancelTime = t;
                e.cancelVolume = e.volume;
                entrusts.push(e);
            end
        end
    end
    if entrusts.latest > 0, ret = 1;end
    
end