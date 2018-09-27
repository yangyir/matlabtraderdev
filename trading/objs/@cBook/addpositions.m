function [] = addpositions(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('price',[],@isnumeric);
    p.addParameter('volume',[],@isnumeric);
    p.addParameter('time',now,@(x) validateattributes(x,{'char','numeric'},{},'','time'));
    p.addParameter('closetodayflag',0,@isnumeric);
    p.addParameter('offset',[],@isnumeric);
    p.parse(varargin{:});
    code_ctp = p.Results.code;
    px = p.Results.price;
    
    volume = p.Results.volume;
    if volume == 0, return; end
    
    time = p.Results.time;
    if ischar(time), time = datenum(time);end
    closetoday = p.Results.closetodayflag;
    offsetflag = p.Results.offset;
    %note:20180927
    %offsetflag indicates whether it is a open position(1) or a close
    %position(-1). this guarantee that positions on the same instrument but
    %with different directions can exist at the same time
    if closetoday ~= 0 && ~isempty(offsetflag) && offsetflag == 1
        error('cBook:addpositions:invalid inputs of closetoday and offsetflag')
    end
    
    if isempty(offsetflag)
        [bool,idx] = obj.hasposition(code_ctp);
        if ~bool
            if closetoday ~= 0
                error('cBook:addpositions:position not found to close in the portfolio')
            end
            n = size(obj.positions_,1);
            positions = cell(n+1,1);
            pos = cPos;
            pos.override('code',code_ctp,'price',px,'volume',volume,'time',time);
            positions{n+1,1} = pos;
            for i = 1:n, positions{i,1} = obj.positions_{i,1}; end
            obj.positions_ = positions;
        else
            obj.positions_{idx,1}.add('code',code_ctp,'price',px,'volume',volume,'time',time,'closetodayflag',closetoday);
        end
    else
        if offsetflag == 1
            if volume > 0
                [bool,idx] = obj.haslongposition(code_ctp);
            else
                [bool,idx] = obj.hasshortposition(code_ctp);
            end
            if ~bool
                n = size(obj.positions_,1);
                positions = cell(n+1,1);
                pos = cPos;
                pos.override('code',code_ctp,'price',px,'volume',volume,'time',time);
                positions{n+1,1} = pos;
                for i = 1:n, positions{i,1} = obj.positions_{i,1}; end
                obj.positions_ = positions;
            else
                obj.positions_{idx,1}.add('code',code_ctp,'price',px,'volume',volume,'time',time);
            end
        elseif offsetflag == -1
            if volume > 0
                %longclose
                [bool,idx] = obj.hasshortposition(code_ctp);
            else
                %shortclose
                [bool,idx] = obj.haslongposition(code_ctp);
            end
            if ~bool
                error('cBook:addpositions:position not found to close in the portfolio')
            end
            obj.positions_{idx,1}.add('code',code_ctp,'price',px,'volume',volume,'time',time,'closetodayflag',closetoday);
        else
            error('cBook:addpositions:invalid input of offsetflag')
        end
    end
    

end