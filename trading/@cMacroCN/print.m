function [] = print(macrocn,varargin)
%cMacroCN
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    tnum = p.Results.Time;
    tstr = datestr(tnum,'yyyy-mm-dd HH:MM:SS');
    
    fprintf('called cMacroCN::print %s\n',tstr);
    
    fprintf('%10s %8s %10s %9s %11s %10s %10s %4s %4s %10s %10s %10s %10s\n',...
        'code','latest','preclose','change','Ktime','hh','ll','bs','ss','levelup','leveldn','teeth','lips');
    dataformat = '%10s %8s %10s %8.2f%% %11s %10s %10s %4s %4s %10s %10s %10.3f %10.3f\n';
    code = macrocn.codes_govtbondfut_{3}(1:end-4);
    latest = macrocn.dailybar_govtbondfut_{3}(end,5);
    lastclose = macrocn.dailybar_govtbondfut_{3}(end-1,5);
    delta = (latest/lastclose-1)*100;
    buysetup = macrocn.struct_govtbondfut_{3}.bs(end);
    sellsetup = macrocn.struct_govtbondfut_{3}.ss(end);
    levelup = macrocn.struct_govtbondfut_{3}.lvlup(end);
    leveldn = macrocn.struct_govtbondfut_{3}.lvldn(end);
    teeth = macrocn.struct_govtbondfut_{3}.teeth(end);
    lips = macrocn.struct_govtbondfut_{3}.lips(end);
    HH = macrocn.struct_govtbondfut_{3}.hh(end);
    LL = macrocn.struct_govtbondfut_{3}.ll(end);
    
    
    fprintf(dataformat,code,num2str(latest),num2str(lastclose),...
        delta,datestr(tnum,'HH:MM'),...
        num2str(HH),num2str(LL),...
        num2str(buysetup),num2str(sellsetup),num2str(levelup),num2str(leveldn),...
        teeth,lips);
    
    tools_technicalplot2(macrocn.mat_govtbondfut_{3}(end-62:end,:),2,code,true);
    tools_technicalplot2(macrocn.mat_govtbondyields_{5}(end-62:end,:),3,'bond yield 10y',true);
    tools_technicalplot2(macrocn.mat_fx_(end-62:end,:),4,'USDCNH',true);
    tools_technicalplot2(macrocn.mat_eqindex_(end-62:end,:),5,'CSI300',true);
end

