% break_interval �����е�cell�� cell{1,1}:���Ͽ���ʱ�䣻 cell{end,end}:ҹ������ʱ�䣨����ҹ�̣�
% �����ԼRB.SHF��Ӧ��break_interval ���£�
% '09:00:00'    '10:15:00'
% '10:30:00'    '11:30:00'
% '13:30:00'    '15:00:00'
% '21:00:00'    '23:00:00'
%  Bloomberg�� ticks data ���� candle �ķ�ʽ�ǣ����ұ�
% ��ͬ�ĺ�Լ���� 1m candle�ķ�ʽ�ǲ�ͬ�ģ���Ҫ������ʱ���tick���д���
% �������tick���ݵĴ���ʽѡ���Ǹ��ݣ� cell{end,end};
% ��cell{end,end}����ȡֵΪ�� 23:00:00�� 15:15:00 ���� 01:00:00
%%%%% �������Ƹֵ�����㴦����Ϊ��
% ���Ƹ� 09��00:00 K��ͼ��Ӧtick�������䣺 ticks��09:00:00�� 09:01:00��
% ���Ƹ� 14��59��00 K��ͼ��Ӧtick�������䣺 ticks��14��59��00 , 15��00��00��
% ���Ƹ� 21��00��00 K��ͼ��Ӧtick�������䣺 ticks ��21��00��00�� 21��01��00��
% ���Ƹ�  K��ͼû�����ݵ�ʱ�䣺break_interval{:,2} 
% ���Ƹ� ticks����û���õ�������ʱ��skip��Ϊ�� 08:59:00�� 10:30:00�� 13:30��00
%%%%% ���������£�
% ������ʱ�䴦�������Ƹ���ͬ������ 00:00:00
% ���� candle_23:59:59 = ticks (23:59:00 , 00:00:00] ���ұ�
% ���� candle_00:00:00 = ticks [00:00:00 , 00:01:00] ����ұ�
% ��ծ���ݴ������£�
%%%%%% ��ծ�������£�
% ��ծ candle_11:29:00 = ticks (11:29:00 , 11:30:00) ���ҿ�
% ��ծ candle_13:00:00 = ticks (13:00:00, 13:00:01 ] ���ұ�
% equalorNot �������str��ͬ������double��ͬ�������ձȽϽ�����������
function [] = updatecandleinmem(mdefut, instrument)

    if datenum(instrument.break_interval{end,end}) == datenum('23:00:00')
        kind =1
    elseif datenum(instrument.break_interval{end,end}) == datenum('15:15:00')
        kind =2;
    elseif datenum(instrument.break_interval{end,end}) == datenum('01:00:00')
        kind =3;
    end

    if isempty(mdefut.ticks_), return; end
    ns = size(mdefut.ticks_,1);
    count = mdefut.ticks_count_;
    
    
    
    for i = 1:ns
        buckets = mdefut.candles_{i}(:,1);
        buckets4save = mdefut.candles4save_{i}(:,1);
        t = mdefut.ticks_{i}(count(i),1);
        px_trade = mdefut.ticks_{i}(count(i),4);
        idx = buckets(1:end-1)<=t & buckets(2:end)>t;
        idx4save = buckets4save(1:end-1)<=t & buckets4save(2:end)>t;
        this_bucket = buckets(idx);
        this_bucket_save = buckets4save(idx4save);
        %
        if ~isempty(this_bucket)
            this_count = find(buckets == this_bucket);
        else
            if t >= buckets(end) && t < buckets(end)+buckets(end)-buckets(end-1)
                this_count = size(buckets,1);
            else
                this_count = [];
            end
        end

        if ~isempty(this_count)
            if this_count ~= mdefut.candles_count_(i)
                mdefut.candles_count_(i) = this_count;
                newset = true;
            else
                newset = false;
            end
            mdefut.candles_{i}(this_count,5) = px_trade;
            if newset
                mdefut.candles_{i}(this_count,2) = px_trade;   %px_open
                mdefut.candles_{i}(this_count,3) = px_trade;   %px_high
                mdefut.candles_{i}(this_count,4) = px_trade;   %px_low
            else
                high = mdefut.candles_{i}(this_count,3);
                low = mdefut.candles_{i}(this_count,4);
                if px_trade > high, mdefut.candles_{i}(this_count,3) = px_trade; end
                if px_trade < low, mdefut.candles_{i}(this_count,4) = px_trade;end
            end
        end
        %
        if ~isempty(this_bucket_save)
            this_count_save = find(buckets4save == this_bucket_save);
        else
            if t >= buckets4save(end) && t < buckets4save(end)+buckets4save(end)-buckets4save(end-1)
                this_count_save = size(buckets4save,1);
            else
                this_count_save = [];
            end
        end

        if ~isempty(this_count_save)
            if this_count_save ~= mdefut.candles4save_count_(i)
                mdefut.candles4save_count_(i) = this_count_save;
                newset = true;
            else
                newset = false;
            end
            mdefut.candles4save_{i}(this_count_save,5) = px_trade;
            if newset
                mdefut.candles4save_{i}(this_count_save,2) = px_trade;   %px_open
                mdefut.candles4save_{i}(this_count_save,3) = px_trade;   %px_high
                mdefut.candles4save_{i}(this_count_save,4) = px_trade;   %px_low
            else
                high = mdefut.candles4save_{i}(this_count_save,3);
                low = mdefut.candles4save_{i}(this_count_save,4);
                if px_trade > high, mdefut.candles4save_{i}(this_count_save,3) = px_trade; end
                if px_trade < low, mdefut.candles4save_{i}(this_count_save,4) = px_trade;end
            end
        end
        %
    end
end
%end of updatecandleinmem