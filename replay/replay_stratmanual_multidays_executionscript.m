px_stoploss_20180620 = 95.35;
px_breach_20180620 = 95.3;
ncarry_20180620 = 2;
replay_date = combos.mdefut.replay_date1_;

while replay_date == datenum('2018-06-20')
    %note:test logic on 20180620
    %as we carry long position, we would unwind all positions at px_stoploss
    %and try to open short at px_breach
    try
        ncarry = combos.book.positions_{1}.position_total_;
    catch
        ncarry = 0;
    end
    npendingentrusts = combos.ops.entrustspending_.latest;
    ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    
    while ncarry == ncarry_20180619 && npendingentrusts == 0 && ismarketopen
        lasttick = combos.mdefut.getlasttick(code);
        if ~isempty(lasttick)
            if lasttick(2) <= px_stoploss_20180620
                combos.strategy.shortclosesingleinstrument(code,ncarry_20180619,0,0);
            end
        end
        pause(1);
        try
            ncarry = combos.book.positions_{1}.position_total_;
        catch
            ncarry = 0;
        end
        npendingentrusts = combos.ops.entrustspending_.latest;
        ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    end
    %
    %once we close out the position, we try to short open at px_breach
    %
    try
        ncarry = combos.book.positions_{1}.position_total_;
    catch
        ncarry = 0;
    end
    npendingentrusts = combos.ops.entrustspending_.latest;
    ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    
    while ncarry == 0 && npendingentrusts == 0 && ismarketopen
        lasttick = combos.mdefut.getlasttick(code);
        if ~isempty(lasttick)
            if lasttick(2) < px_breach_20180620
                combos.strategy.shortopensingleinstrument(code,ncarry_20180620,0);
            end
        end
        pause(1);
        try
            ncarry = combos.book.positions_{1}.position_total_;
        catch
            ncarry = 0;
        end
        npendingentrusts = combos.ops.entrustspending_.latest;
        ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    end
    replay_date = combos.mdefut.replay_date1_;
end

fprintf('move to another trading date...\n');
%
%
ncarry_20180621 = 2;
px_stoploss_20180621 = 95.095;
px_breach_20180621 = 95.2;
while replay_date == datenum('2018-06-21')
    %note:test logic on 20180621
    %as we carry short position around px_breach_20180620, we would unwind all positions at px_stoploss
    %and try to open short at px_breach
    try
        ncarry = combos.book.positions_{1}.position_total_;
    catch
        ncarry = 0;
    end
    npendingentrusts = combos.ops.entrustspending_.latest;
    ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    
    while ncarry == ncarry_20180620 && npendingentrusts == 0 && ismarketopen
        lasttick = combos.mdefut.getlasttick(code);
        if ~isempty(lasttick)
            if lasttick(2) <= px_stoploss_20180621
                combos.strategy.longclosesingleinstrument(code,ncarry_20180619,0,0);
            end
        end
        pause(1);
        try
            ncarry = combos.book.positions_{1}.position_total_;
        catch
            ncarry = 0;
        end
        npendingentrusts = combos.ops.entrustspending_.latest;
        ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    end
    %
    %once we close out the position, we try to open long at px_breach
    %
    try
        ncarry = combos.book.positions_{1}.position_total_;
    catch
        ncarry = 0;
    end
    npendingentrusts = combos.ops.entrustspending_.latest;
    ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    
    while ncarry == 0 && npendingentrusts == 0 && ismarketopen
        lasttick = combos.mdefut.getlasttick(code);
        if ~isempty(lasttick)
            if lasttick(2) > px_breach_20180621
                combos.strategy.longopensingleinstrument(code,ncarry_20180621,0);
            end
        end
        pause(1);
        try
            ncarry = combos.book.positions_{1}.position_total_;
        catch
            ncarry = 0;
        end
        npendingentrusts = combos.ops.entrustspending_.latest;
        ismarketopen = sum(combos.mdefut.ismarketopen('time',combos.mdefut.replay_time1_));
    end
    replay_date = combos.mdefut.replay_date1_;
end

fprintf('move to another trading date...\n');


