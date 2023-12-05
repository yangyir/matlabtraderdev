function [] = refresh(mdefx,varargin)
%cmdefx
    nfractal = 2;
    if ~isempty(mdefx.w_)
        rt_fx_new = mdefx.w_.ds_.wsq(mdefx.codes_fx_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    else
        rt_fx_new = THS_RQ(mdefx.codes_fx_,'tradeDate;open;high;low;latest','','format:table');
        rt_fx_new = [datenum(rt_fx_new.tradeDate,'yyyy-mm-dd'),rt_fx_new.open,rt_fx_new.high,rt_fx_new.low,rt_fx_new.latest];
    end
    %
    rt_fx_new(1) = datenum(num2str(rt_fx_new(1)),'yyyymmdd');
    rt_fx_new(:,1) = rt_fx_new(1);

    %refresh market data
    nfx = size(mdefx.codes_fx_,1);
    for i = 1:nfx
        lastd = mdefx.dailybar_fx_{i}(end,1);
        if lastd == rt_fx_new(i,1)
            mdefx.dailybar_fx_{i}(end,:) = rt_fx_new(i,:);
        else
            mdefx.dailybar_fx_{i} = [mdefx.dailybar_fx_{i};rt_fx_new(i,:)];
        end
        [mdefx.mat_fx_{i},mdefx.struct_fx_{i}] = tools_technicalplot1(mdefx.dailybar_fx_{i},nfractal,false);
        mdefx.mat_fx_{i}(:,1) = x2mdate(mdefx.mat_fx_{i}(:,1));
    end
    
%     fprintf('refreshed on %s\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
    % ---------- risk management refresh -------------
    mdefx.riskmanagement_fx;

end

