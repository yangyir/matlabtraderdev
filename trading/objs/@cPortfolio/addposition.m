function [] = addposition(port,instrument,px,volume,dtnum,closetoday)
    if nargin < 3
        px = 0;
        volume = 0;
        dtnum = now;
        closetoday = 0;
    end

    if nargin == 3
        error('cPortfolio:addinstrument:missing input of volume')
    end

    if nargin == 4
        dtnum = now;
        closetoday = 0;
    end

    if nargin == 5
        closetoday = 0;
    end

    [bool,idx] = port.hasposition(instrument);
    if ~bool
        if closetoday ~= 0
            error('cPortfolio:addinstrument:position not found to close in the portfolio')
        end
        n = port.count;
        pos_list_ = cell(n+1,1);

        pos = cPos;
        pos.override('code',instrument.code_ctp,'price',px,'volume',volume,'time',dtnum);
        pos_list_{n+1,1} = pos;
        
        for i = 1:n
            pos_list_{i,1} = port.pos_list{i,1};
        end
        port.pos_list = pos_list_;
    else
        port.pos_list{idx,1}.add('code',instrument.code_ctp,'price',px,'volume',volume,'time',dtnum,'closetodayflag',closetoday);

    end
end
%end of addinstrument