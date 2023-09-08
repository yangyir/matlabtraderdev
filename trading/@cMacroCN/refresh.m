function [] = refresh(macrocn,varargin)
%cMacroCN
    rt_cash_new = macrocn.w_.ds_.wsq(macrocn.codes_cash_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    rt_govtbondfut_new = macrocn.w_.ds_.wsq(macrocn.codes_govtbondfut_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    rt_govtbond_new = macrocn.w_.ds_.wsq(macrocn.codes_govtbond_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    rt_fx_new = macrocn.w_.ds_.wsq(macrocn.codes_fx_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    rt_eqindex_new = macrocn.w_.ds_.wsq(macrocn.codes_eqindex_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
    %
    rt_cash_new(1) = datenum(num2str(rt_cash_new(1)),'yyyymmdd');
    rt_govtbondfut_new(:,1) = rt_cash_new(1);
    rt_govtbond_new(:,1) = rt_cash_new(1);
    rt_fx_new(:,1) = rt_cash_new(1);
    rt_eqindex_new(:,1) = rt_cash_new(1);

    lastd = macrocn.dailybar_dr007_(end,1);
    if lastd == rt_cash_new(1)
        macrocn.dailybar_dr007_(end,:) = rt_cash_new;
    else
        macrocn.dailybar_dr007_ = [macrocn.dailybar_dr007_;rt_cash_new];
    end
    
    nfut = size(macrocn.codes_govtbondfut_,1);
    for i = 1:nfut
        lastd = macrocn.dailybar_govtbondfut_{i}(end,1);
        if lastd == rt_govtbond_new(i,1)
            macrocn.dailybar_govtbondfut_{i}(end,:) = rt_govtbondfut_new(i,:);
        else
            macrocn.dailybar_govtbondfut_{i} = [macrocn.dailybar_govtbondfut_{i};rt_govtbondfut_new(i,:)];
        end
        [macrocn.mat_govtbondfut_{i},macrocn.struct_govtbondfut_{i}] = tools_technicalplot1(macrocn.dailybar_govtbondfut_{i},2,false);
        macrocn.mat_govtbondfut_{i}(:,1) = x2mdate(macrocn.mat_govtbondfut_{i}(:,1));
    end
    
    nbond = size(macrocn.codes_govtbond_,1);
    for i = 1:nbond
        lastd = macrocn.dailybar_govtbondyields_{i}(end,1);
        if lastd == rt_govtbond_new(i,1)
            macrocn.dailybar_govtbondyields_{i}(end,:) = rt_govtbond_new(i,:);
        else
            macrocn.dailybar_govtbondyields_{i} = [macrocn.dailybar_govtbondyields_{i};rt_govtbond_new(i,:)];
        end
        [macrocn.mat_govtbondyields_{i},macrocn.struct_govtbondyields_{i}] = tools_technicalplot1(macrocn.dailybar_govtbondyields_{i},2,false);
        macrocn.mat_govtbondyields_{i}(:,1) = x2mdate(macrocn.mat_govtbondyields_{i}(:,1));
    end
    
    lastd = macrocn.dailybar_fx_(end,1);
    if lastd == rt_fx_new(1)
        macrocn.dailybar_fx_(end,:) = rt_fx_new;
    else
        macrocn.dailybar_fx_ = [macrocn.dailybar_fx_;rt_fx_new];
    end
    [macrocn.mat_fx_,macrocn.struct_fx_] = tools_technicalplot1(macrocn.dailybar_fx_,2,false);
    macrocn.mat_fx_(:,1) = x2mdate(macrocn.mat_fx_(:,1));
    
    lastd = macrocn.dailybar_eqindex_(end,1);
    if lastd == rt_eqindex_new(1)
        macrocn.dailybar_eqindex_(end,:) = rt_eqindex_new;
    else
        macrocn.dailybar_eqindex_ = [macrocn.dailybar_eqindex_;rt_eqindex_new];
    end
    [macrocn.mat_eqindex_,macrocn.struct_eqindex_] = tools_technicalplot1(macrocn.dailybar_eqindex_,2,false);
    macrocn.mat_eqindex_(:,1) = x2mdate(macrocn.mat_eqindex_(:,1));
    

end

