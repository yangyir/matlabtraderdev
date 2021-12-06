function [signal,op] = fractal_signal_unconditional(extrainfo,ticksize,nfractal,varargin)
%signal in case there is valid breachup or valid breachdn
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('lasttick',[],@isnumeric);
    p.parse(varargin{:});
    tick = p.Results.lasttick;

    signal = [];
    op = [];

    [validbreachhh,validbreachll,b1type,s1type] = fractal_validbreach(extrainfo,ticksize);
    if ~validbreachhh && ~validbreachll
        %no signal if there is either breachhh or breachll
        return
    end
    
    if validbreachhh && ~validbreachll
        [op,status] = fractal_filterb1_singleentry(b1type,nfractal,extrainfo,ticksize);
        useflag = op.use;
        if ~useflag && ~isempty(tick)
            %special treatment when market jumps high above lvlup
            ask = tick(3);
            if ask>extrainfo.lvlup(end) && extrainfo.px(end,5)<extrainfo.lvlup(end)
                useflag = 1;
                op.useflag = 1;
                op.comment = 'breachup-lvlup';
            end
        end
        
        if ~useflag && status.isclose2lvlup
            %special treatment when market moves close to lvlup, i.e. the
            %market breached up HH but still stayed below lvlup closely.we
            %shall, in this case, place a conditional entrust just one tick
            %above lvlup
            signal = zeros(1,6);
            signal(1) = 1;                                                 %direction
            signal(2) = extrainfo.lvlup(end);                              %replace HH with lvlup
            signal(3) = extrainfo.ll(end);                                 %LL
            signal(4) = 3;                                                 %special key for close2lvlup
            signal(5) = extrainfo.px(end,3);                               %candle high
            signal(6) = extrainfo.px(end,4);                               %candle low
            return
        end
        %    
        if useflag
            %double check whether it is a valid long open
            %condition1:candle close is above 0.382 of (candle high minus fractal ll)
            flag1 = extrainfo.px(end,5)>extrainfo.px(end,3)-0.382*(extrainfo.px(end,3)-extrainfo.ll(end));
            %condition2:candle close is below fracal hh plus 1.618 of
            %fracal distance (fracal hh minus fratal ll)
            flag2 = extrainfo.px(end,5)<extrainfo.hh(end)+1.618*(extrainfo.hh(end)-extrainfo.ll(end));
            %condition3:candle close is above alligator's lips
            flag3 = extrainfo.px(end,5)>extrainfo.lips(end);
            validlongopen = flag1&flag2&flag3;
            if validlongopen
                signal = zeros(1,6);
                signal(1) = 1;
                signal(2) = extrainfo.hh(end);
                signal(3) = extrainfo.ll(end);
                signal(4) = 1;
                signal(5) = extrainfo.px(end,3);
                signal(6) = extrainfo.px(end,4);
            else
                signal = zeros(1,6);
                if ~flag1
                    op.comment = [op.comment,'-invalid long as close dumps'];
                end
                if ~flag2
                    op.comment = [op.comment,'-invalid long as close moves too high'];
                end
                if ~flag3
                    op.comment = [op.comment,'-invalid long close below alligator lips'];
                end
            end
        else
            signal = zeros(1,6); 
        end
        return
    end
    %
    if ~validbreachhh && validbreachll
        [op,status] = fractal_filters1_singleentry(s1type,nfractal,extrainfo,ticksize);
        useflag = op.use;
        if ~useflag && ~isempty(tick)
            %special treatment when market jumps low below lvldn
            bid = tick(2);
            if bid<extrainfo.lvldn(end) && extrainfo.px(end,5)>extrainfo.lvldn(end)
                useflag = 1;
                op.useflag = 1;
                op.comment = 'breachdn-lvldn';
            end
        end
        
        if ~useflag && status.isclose2lvldn
            %special treatment when market moves close to lvldn, i.e. the
            %market breached dn LL but still stayed above lvldn closely.we
            %shall, in this case, place a conditional entrust just one tick
            %below lvldn
            signal = zeros(1,6);
            signal(1) = -1;                                                 %direction
            signal(2) = extrainfo.hh(end);                                 %HH
            signal(3) = extrainfo.lvldn(end);                              %replace LL with lvldn
            signal(4) = -3;                                                %special key for close2lvldn
            signal(5) = extrainfo.px(end,3);                               %candle high
            signal(6) = extrainfo.px(end,4);                               %candle low
            return
        end
        %
        if useflag
            %double check whether it is a valid short open
            %condition1:candle close is below 0.382 of (fracal hh minus candle low£©
            flag1 = extrainfo.px(end,5)<extrainfo.px(end,4)+0.382*(extrainfo.hh(end)-extrainfo.px(end,4));
            %condition2:candle close is above fracal hh minus 1.618 of
            %fractal distance (fractal hh minus fracal ll)
            flag2 = extrainfo.px(end,5)>extrainfo.ll(end)-1.618*(extrainfo.hh(end)-extrainfo.ll(end));
            %condition3:candle close below alligator's lips
            flag3 = extrainfo.px(end,5)<extrainfo.lips(end);
            validshortopen = flag1&flag2&flag3;
            if validshortopen
                signal = zeros(1,6);
                signal(1) = -1;
                signal(2) = extrainfo.hh(end);
                signal(3) = extrainfo.ll(end);
                signal(4) = -1;
                signal(5) = extrainfo.px(end,3);
                signal(6) = extrainfo.px(end,4);
            else
                signal = zeros(1,6);
                if ~flag1
                    op.comment = [op.comment,'-invalid short as close rallied'];
                end
                if ~flag2
                    op.comment = [op.comment,'-invalid short as close moves too low'];
                end
                if ~flag3
                    op.comment = [op.comment,'-invalid short as close above alligator lips'];
                end
            end
        else
            signal = zeros(1,6);
        end
        return
        
    
    
end