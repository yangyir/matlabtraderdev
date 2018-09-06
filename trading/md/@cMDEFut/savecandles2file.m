function [] = savecandles2file(mdefut,dtnum)
    if ~mdefut.candlesaveflag_
        fprintf('save candles on %s......\n',datestr(dtnum));
        coldefs = {'datetime','open','high','low','close'};
        dir_ = getenv('DATAPATH');

        instruments = mdefut.qms_.instruments_.getinstrument;
        ns = size(instruments,1);

        for i = 1:ns
            code_ctp = instruments{i}.code_ctp;
            bd = mdefut.candles4save_{i}(1,1);
            dir_data_ = [dir_,'intradaybar\',code_ctp,'\'];
            fn_ = [dir_data_,code_ctp,'_',datestr(bd,'yyyymmdd'),'_1m.txt'];
            cDataFileIO.saveDataToTxtFile(fn_,mdefut.candles4save_{i},coldefs,'w',true);
        end

        mdefut.candlesaveflag_ = true;
        %and clear the ticks and candles from memoery
%         mdefut.ticks_ = {};
        n = 1e5;%note:this size shall be enough for day trading
        d = cell(ns,1);
        for i = 1:ns, d{i} = zeros(n,7);end
        mdefut.ticks_ = d;
        %
        mdefut.ticks_count_ = zeros(ns,1);

        mdefut.candles_ = {};
        mdefut.candles4save_ = {};
        mdefut.candles_count_ = zeros(ns,1);

        if ~isempty(mdefut.hist_candles_), mdefut.hist_candles_ = {};end

        mdefut.status_ = 'sleep';
    end
end