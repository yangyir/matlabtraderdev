function [] = refresh(mdefx,varargin)
%cmdefx
    rt_cash_new = mdefx.w_.ds_.wsq(mdefx.codes_cash_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    rt_govtbondfut_new = mdefx.w_.ds_.wsq(mdefx.codes_govtbondfut_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    rt_govtbond_new = mdefx.w_.ds_.wsq(mdefx.codes_govtbond_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    rt_fx_new = mdefx.w_.ds_.wsq(mdefx.codes_fx_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    rt_eqindex_new = mdefx.w_.ds_.wsq(mdefx.codes_eqindex_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    %
    rt_cash_new(1) = datenum(num2str(rt_cash_new(1)),'yyyymmdd');
    rt_govtbondfut_new(:,1) = rt_cash_new(1);
    rt_govtbond_new(:,1) = rt_cash_new(1);
    rt_fx_new(:,1) = rt_cash_new(1);
    rt_eqindex_new(:,1) = rt_cash_new(1);

    lastd = mdefx.dailybar_dr007_(end,1);
    if lastd == rt_cash_new(1)
        mdefx.dailybar_dr007_(end,:) = rt_cash_new;
    else
        mdefx.dailybar_dr007_ = [mdefx.dailybar_dr007_;rt_cash_new];
    end
    
    nfut = size(mdefx.codes_govtbondfut_,1);
    for i = 1:nfut
        lastd = mdefx.dailybar_govtbondfut_{i}(end,1);
        if lastd == rt_govtbond_new(i,1)
            mdefx.dailybar_govtbondfut_{i}(end,:) = rt_govtbondfut_new(i,:);
        else
            mdefx.dailybar_govtbondfut_{i} = [mdefx.dailybar_govtbondfut_{i};rt_govtbondfut_new(i,:)];
        end
        [mdefx.mat_govtbondfut_{i},mdefx.struct_govtbondfut_{i}] = tools_technicalplot1(mdefx.dailybar_govtbondfut_{i},2,false);
        mdefx.mat_govtbondfut_{i}(:,1) = x2mdate(mdefx.mat_govtbondfut_{i}(:,1));
    end
    
    nbond = size(mdefx.codes_govtbond_,1);
    for i = 1:nbond
        lastd = mdefx.dailybar_govtbondyields_{i}(end,1);
        if lastd == rt_govtbond_new(i,1)
            mdefx.dailybar_govtbondyields_{i}(end,:) = rt_govtbond_new(i,:);
        else
            mdefx.dailybar_govtbondyields_{i} = [mdefx.dailybar_govtbondyields_{i};rt_govtbond_new(i,:)];
        end
        [mdefx.mat_govtbondyields_{i},mdefx.struct_govtbondyields_{i}] = tools_technicalplot1(mdefx.dailybar_govtbondyields_{i},2,false);
        mdefx.mat_govtbondyields_{i}(:,1) = x2mdate(mdefx.mat_govtbondyields_{i}(:,1));
    end
    
    lastd = mdefx.dailybar_fx_(end,1);
    if lastd == rt_fx_new(1)
        mdefx.dailybar_fx_(end,:) = rt_fx_new;
    else
        mdefx.dailybar_fx_ = [mdefx.dailybar_fx_;rt_fx_new];
    end
    [mdefx.mat_fx_,mdefx.struct_fx_] = tools_technicalplot1(mdefx.dailybar_fx_,2,false);
    mdefx.mat_fx_(:,1) = x2mdate(mdefx.mat_fx_(:,1));
    
    lastd = mdefx.dailybar_eqindex_(end,1);
    if lastd == rt_eqindex_new(1)
        mdefx.dailybar_eqindex_(end,:) = rt_eqindex_new;
    else
        mdefx.dailybar_eqindex_ = [mdefx.dailybar_eqindex_;rt_eqindex_new];
    end
    [mdefx.mat_eqindex_,mdefx.struct_eqindex_] = tools_technicalplot1(mdefx.dailybar_eqindex_,2,false);
    mdefx.mat_eqindex_(:,1) = x2mdate(mdefx.mat_eqindex_(:,1));
    

end

