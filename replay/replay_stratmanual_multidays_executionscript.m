%
px_stoploss1_20180620 = 95.35;
px_breach_20180620 = 95.3;
px_stoploss2_20180620 = 95.5;
ncarry_20180620 = 2;
replay_date = combos.mdefut.replay_date1_;

%Note:test logic on replay date 20180620
%As we carry long positions from 20180619, we would stop-loss all positions
%in case the price breaches px_stoploss1
%Also, if the price moves further below px_breach, we would try to open
%short positions with a stoploss at px_stoploss2
while replay_date == datenum('2018-06-20')
    ncarry = combos.ops.book_.getpositions('code',code);
    npendingentrusts = combos.ops.entrustspending_.latest;
    ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    
    %to place stop-loss entrust if the price breaches px_stoploss1
    while ncarry == ncarry_20180619 && npendingentrusts == 0 && ismarketopen
        lasttick = combos.mdefut.getlasttick(code);
        if ~isempty(lasttick)
            if lasttick(2) <= px_stoploss1_20180620
                combos.strategy.shortclosesingleinstrument(code,ncarry_20180619,0,0);
            end
        end
        pause(0.2);
        ncarry = combos.ops.book_.getpositions('code',code);
        npendingentrusts = combos.ops.entrustspending_.latest;
        ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    end
    %
    %once we close out the position, we try to short open at px_breach
    %
    ncarry = combos.ops.book_.getpositions('code',code);
    npendingentrusts = combos.ops.entrustspending_.latest;
    ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    
    while ncarry == 0 && npendingentrusts == 0 && ismarketopen
        lasttick = combos.mdefut.getlasttick(code);
        if ~isempty(lasttick)
            if lasttick(2) < px_breach_20180620
                combos.strategy.shortopensingleinstrument(code,ncarry_20180620,0);
            end
        end
        pause(0.2);
        ncarry = combos.ops.book_.getpositions('code',code);
        npendingentrusts = combos.ops.entrustspending_.latest;
        ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    end
    
    ncarry = combos.ops.book_.getpositions('code',code);
    npendingentrusts = combos.ops.entrustspending_.latest;
    ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    
    %in case the market moves back, we close out our short positions
    while ncarry == ncarry_20180620 && npendingentrusts == 0 && ismarketopen
        lasttick = combos.mdefut.getlasttick(code);
        if ~isempty(lasttick)
            if lasttick(2) > px_stoploss2_20180620
                combos.strategy.longclosesingleinstrument(code,ncarry_20180620,0,0);
            end
        end
        pause(0.2);
        ncarry = combos.ops.book_.getpositions('code',code);
        npendingentrusts = combos.ops.entrustspending_.latest;
        ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    end
    
    replay_date = combos.mdefut.replay_date1_;
end

fprintf('move to another trading date...\n');
%
%
%Note:test logic on 20180621
%As we carry short position around px_breach_20180620, we would unwind all positions at px_stoploss
%and try to open long at px_breach
ncarry_20180621 = 3;
px_stoploss_20180621 = 95.2;
px_breach_20180621 = 95.25;
while replay_date == datenum('2018-06-21')
    ncarry = combos.ops.book_.getpositions('code',code);
    npendingentrusts = combos.ops.entrustspending_.latest;
    ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    
    while ncarry == ncarry_20180620 && npendingentrusts == 0 && ismarketopen
        lasttick = combos.mdefut.getlasttick(code);
        if ~isempty(lasttick)
            if lasttick(2) >= px_stoploss_20180621
                combos.strategy.longclosesingleinstrument(code,ncarry_20180620,0,0,'overrideprice',lasttick(2));
            end
        end
        pause(0.2);
        ncarry = combos.ops.book_.getpositions('code',code);
        npendingentrusts = combos.ops.entrustspending_.latest;
        ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    end
    %
    %once we close out the position, we try to open long at px_breach
    %
    ncarry = combos.ops.book_.getpositions('code',code);
    npendingentrusts = combos.ops.entrustspending_.latest;
    ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    
    while ncarry == 0 && npendingentrusts == 0 && ismarketopen
        lasttick = combos.mdefut.getlasttick(code);
        if ~isempty(lasttick)
            if lasttick(2) > px_breach_20180621
                combos.strategy.longopensingleinstrument(code,ncarry_20180621,0,'overrideprice',lasttick(2));
            end
        end
        pause(0.2);
        ncarry = combos.ops.book_.getpositions('code',code);
        npendingentrusts = combos.ops.entrustspending_.latest;
        ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    end
    replay_date = combos.mdefut.replay_date1_;
end

fprintf('move to another trading date...\n');


