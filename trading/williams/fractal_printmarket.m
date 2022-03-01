function [] = fractal_printmarket(code,dailybarstruct,intradaybarstruct)
%FRACTAL_PRINTMARKET Summary of this function goes here
%   Detailed explanation goes here

stock = code2instrument(code);

dataformat = '%10s %8s %8s %8.2f%% %11s %10s %10s %4s %4s %10s %10s %10.3f %10.3f %10.3f %10s\n';
if ~isempty(intradaybarstruct)
    %intraday info
    fprintf('\nlatest intraday quotes of %s:\n',code);
    fprintf('%10s %8s %8s %9s %11s %10s %10s %4s %4s %10s %10s %10s %10s %10s %10s\n',...
        'code','latest','close','change','Ktime','hh','ll','bs','ss','levelup','leveldn','jaw','teeth','lips','name');
    latest = intradaybarstruct.px(end,5);
    lastclose = dailybarstruct.px(end-1,5);
    timet = datestr(intradaybarstruct.px(end,1),'HH:MM:SS');
    delta = (latest/lastclose-1)*100;
    buysetup = intradaybarstruct.bs(end);
    sellsetup = intradaybarstruct.ss(end);
    levelup = intradaybarstruct.lvlup(end);
    leveldn = intradaybarstruct.lvldn(end);
    jaw = intradaybarstruct.jaw(end);
    teeth = intradaybarstruct.teeth(end);
    lips = intradaybarstruct.lips(end);
    HH = intradaybarstruct.hh(end);
    LL = intradaybarstruct.ll(end);
    
    fprintf(dataformat,code,num2str(latest),num2str(lastclose),...
        delta,timet,...
        num2str(HH),num2str(LL),...
        num2str(buysetup),num2str(sellsetup),num2str(levelup),num2str(leveldn),...
        jaw,teeth,lips,...
        stock.asset_name);
    
    [ret,direction,breachtime,breachidx] = fractal_hasintradaybreach(intradaybarstruct.px(end,1)+1/48,intradaybarstruct,stock.tick_size);
%     [ret2,signal2,op2] = fractal_hasintradaybreach_conditional(timet,extrainfo_i,ticksize);
    if ret
        ei_breach = fractal_truncate(intradaybarstruct,breachidx);
        [signal,op] = fractal_signal_unconditional(ei_breach,stock.tick_size,4);
        if direction == 1
            fprintf('%s:BreachUP:%s:\t',datestr(breachtime+1/48,'yyyy-mm-dd HH:MM'),code);
            fprintf('%2d\t%s(%s)\n',signal(1),op.comment,stock.asset_name);
        else
            fprintf('%s:BreachDN:%s:\t',datestr(breachtime+1/48,'yyyy-mm-dd HH:MM'),code);
            fprintf('%2d\t%s(%s)\n',signal(1),op.comment,stock.asset_name);
        end
    end
    
end

if ~isempty(dailybarstruct)
    fprintf('\nlatest daily quotes of %s:\n',code);
    fprintf('%10s %8s %8s %9s %11s %10s %10s %4s %4s %10s %10s %10s %10s %10s %10s\n',...
        'code','latest','close','change','Ktime','hh','ll','bs','ss','levelup','leveldn','jaw','teeth','lips','name');
    latest = dailybarstruct.px(end,5);
    lastclose = dailybarstruct.px(end-1,5);
    timet = datestr(dailybarstruct.px(end,1),'yy-mm-dd');
    delta = (latest/lastclose-1)*100;
    buysetup = dailybarstruct.bs(end);
    sellsetup = dailybarstruct.ss(end);
    levelup = dailybarstruct.lvlup(end);
    leveldn = dailybarstruct.lvldn(end);
    jaw = dailybarstruct.jaw(end);
    teeth = dailybarstruct.teeth(end);
    lips = dailybarstruct.lips(end);
    HH = dailybarstruct.hh(end);
    LL = dailybarstruct.ll(end);
    
    fprintf(dataformat,code,num2str(latest),num2str(lastclose),...
        delta,timet,...
        num2str(HH),num2str(LL),...
        num2str(buysetup),num2str(sellsetup),num2str(levelup),num2str(leveldn),...
        jaw,teeth,lips,...
        stock.asset_name);
end

end

