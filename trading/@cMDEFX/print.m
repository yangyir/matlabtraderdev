function [] = print(mdefx,varargin)
%cmdefx
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    tnum = p.Results.Time;
    tstr = datestr(tnum,'yyyy-mm-dd HH:MM:SS');
    
    fprintf('called cmdefx::print %s\n',tstr);
    
    fprintf('%10s %8s %10s %9s %11s %10s %10s %4s %4s %10s %10s %10s %10s\n',...
        'code','latest','preclose','change','Ktime','hh','ll','bs','ss','levelup','leveldn','teeth','lips');
    dataformat = '%10s %8s %10s %8.2f%% %11s %10s %10s %4s %4s %10s %10s %10.3f %10.3f\n';
    code = mdefx.codes_govtbondfut_{3}(1:end-4);
    latest = mdefx.dailybar_govtbondfut_{3}(end,5);
    lastclose = mdefx.dailybar_govtbondfut_{3}(end-1,5);
    delta = (latest/lastclose-1)*100;
    buysetup = mdefx.struct_govtbondfut_{3}.bs(end);
    sellsetup = mdefx.struct_govtbondfut_{3}.ss(end);
    levelup = mdefx.struct_govtbondfut_{3}.lvlup(end);
    leveldn = mdefx.struct_govtbondfut_{3}.lvldn(end);
    teeth = mdefx.struct_govtbondfut_{3}.teeth(end);
    lips = mdefx.struct_govtbondfut_{3}.lips(end);
    HH = mdefx.struct_govtbondfut_{3}.hh(end);
    LL = mdefx.struct_govtbondfut_{3}.ll(end);
    %
    fprintf(dataformat,code,num2str(latest),num2str(lastclose),...
        delta,datestr(tnum,'HH:MM'),...
        num2str(HH),num2str(LL),...
        num2str(buysetup),num2str(sellsetup),num2str(levelup),num2str(leveldn),...
        teeth,lips);
    %
    code = mdefx.codes_govtbond_{5}(1:end-3);
    latest = mdefx.dailybar_govtbondyields_{5}(end,5);
    lastclose = mdefx.dailybar_govtbondyields_{5}(end-1,5);
    delta = (latest-lastclose)*100;
    buysetup = mdefx.struct_govtbondyields_{5}.bs(end);
    sellsetup = mdefx.struct_govtbondyields_{5}.ss(end);
    levelup = mdefx.struct_govtbondyields_{5}.lvlup(end);
    leveldn = mdefx.struct_govtbondyields_{5}.lvldn(end);
    teeth = mdefx.struct_govtbondyields_{5}.teeth(end);
    lips = mdefx.struct_govtbondyields_{5}.lips(end);
    HH = mdefx.struct_govtbondyields_{5}.hh(end);
    LL = mdefx.struct_govtbondyields_{5}.ll(end);
    dataformat = '%10s %8s %10s %9.2f %11s %10s %10s %4s %4s %10s %10s %10.3f %10.3f\n';
    fprintf(dataformat,code,num2str(latest),num2str(lastclose),...
        delta,datestr(tnum,'HH:MM'),...
        num2str(HH),num2str(LL),...
        num2str(buysetup),num2str(sellsetup),num2str(levelup),num2str(leveldn),...
        teeth,lips);
    %
    code = mdefx.codes_fx_(1:end-3);
    latest = mdefx.dailybar_fx_(end,5);
    lastclose = mdefx.dailybar_fx_(end-1,5);
    delta = (latest/lastclose-1)*100;
    buysetup = mdefx.struct_fx_.bs(end);
    sellsetup = mdefx.struct_fx_.ss(end);
    levelup = mdefx.struct_fx_.lvlup(end);
    leveldn = mdefx.struct_fx_.lvldn(end);
    teeth = mdefx.struct_fx_.teeth(end);
    lips = mdefx.struct_fx_.lips(end);
    HH = mdefx.struct_fx_.hh(end);
    LL = mdefx.struct_fx_.ll(end);
    dataformat = '%10s %8.4f %10.4f %8.2f%% %11s %10s %10s %4s %4s %10.4f %10.4f %10.4f %10.4f\n';
    fprintf(dataformat,code,latest,lastclose,...
        delta,datestr(tnum,'HH:MM'),...
        num2str(HH),num2str(LL),...
        num2str(buysetup),num2str(sellsetup),levelup,leveldn,...
        teeth,lips);
    %
    code = mdefx.codes_eqindex_(1:end-3);
    latest = mdefx.dailybar_eqindex_(end,5);
    lastclose = mdefx.dailybar_eqindex_(end-1,5);
    delta = (latest/lastclose-1)*100;
    buysetup = mdefx.struct_eqindex_.bs(end);
    sellsetup = mdefx.struct_eqindex_.ss(end);
    levelup = mdefx.struct_eqindex_.lvlup(end);
    leveldn = mdefx.struct_eqindex_.lvldn(end);
    teeth = mdefx.struct_eqindex_.teeth(end);
    lips = mdefx.struct_eqindex_.lips(end);
    HH = mdefx.struct_eqindex_.hh(end);
    LL = mdefx.struct_eqindex_.ll(end);
    dataformat = '%10s %8.2f %10.2f %8.2f%% %11s %10.2f %10.2f %4s %4s %10.2f %10.2f %10.2f %10.2f\n';
    fprintf(dataformat,code,latest,lastclose,...
        delta,datestr(tnum,'HH:MM'),...
        HH,LL,...
        num2str(buysetup),num2str(sellsetup),levelup,leveldn,...
        teeth,lips);
    
    fprintf('\n');
    tools_technicalplot2(mdefx.mat_govtbondfut_{3}(end-62:end,:),2,'T.CFE',true);
    tools_technicalplot2(mdefx.mat_govtbondyields_{5}(end-62:end,:),3,'bond yield 10y',true);
    tools_technicalplot2(mdefx.mat_fx_(end-62:end,:),4,'USDCNH',true);
    tools_technicalplot2(mdefx.mat_eqindex_(end-62:end,:),5,'CSI300',true);
end

