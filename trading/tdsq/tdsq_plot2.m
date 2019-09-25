function [output] = tdsq_plot2(p,idxstart,idxend,instr2)
%tdsq_plot's enhancement:
%with first graph as tdsq, i.e. TD Sequential and TD Countdown(going
%forward)
if isa(instr2,'cInstrument')
    shift = 2*instr2.tick_size;
else
    shift = instr2;
end
figure(4);
% h1 = gca;

pxopen = p(:,2);pxhigh = p(:,3);pxlow = p(:,4);pxclose = p(:,5);
[tdBuySetup,tdSellSetup,tdSTResistence,tdSTSupport,tdBuyCountDown,tdSellCountDown] = tdsq(p);
[lead,lag] = movavg(pxclose,12,26,'e');
macdvec = lead - lag;
[~,nineperma] = movavg(macdvec,1,9,'e');

output = struct('tdbuysetup',tdBuySetup,...
    'tdsellsetup',tdSellSetup,...
    'tdstresistence',tdSTResistence,...
    'tdstsupport',tdSTSupport,...
    'tdbuycountdown',tdBuyCountDown,...
    'tdsellcountdown',tdSellCountDown,...
    'macd',macdvec,...
    'sig',nineperma);

datevec2plot = p(idxstart:idxend,1);
pxhigh2plot = pxhigh(idxstart:idxend);
pxlow2plot = pxlow(idxstart:idxend);
pxclose2plot = pxclose(idxstart:idxend);
pxopen2plot = pxopen(idxstart:idxend);
macdvec2plot = macdvec(idxstart:idxend);
nineperma2plot = nineperma(idxstart:idxend);

index = 1:1:size(p,1);
index2plot = index(idxstart:idxend);

ax(1) = subplot(2,1,1);
plot(tdSTResistence(idxstart:idxend),'r:','LineWidth',2);hold on;
plot(tdSTSupport(idxstart:idxend),'g:','LineWidth',2);
legend('tdst-resistence','tdst-support');
candle(pxhigh2plot,pxlow2plot,pxclose2plot,pxopen2plot);
xtick = get(ax(1),'XTick');
nxtick = length(xtick);
xticklabel = cell(nxtick,1);
for i = 1:nxtick
    if xtick(i) > length(datevec2plot), continue;end
    if xtick(i) == 0
        xticklabel{i} = index2plot(1);
    else
        xticklabel{i}= index2plot(xtick(i));
    end
end
set(ax(1),'XTickLabel',xticklabel,'fontsize',8);grid on;
hold off;

for i = idxstart:idxend
    if tdBuySetup(i,1) == 9
        for k = 1:9
            if i-idxstart+2-k < 1, continue;end
            text(i-idxstart+2-k,p(i+1-k,4)-shift,num2str(tdBuySetup(i+1-k,1) ),'color','r','fontweight','bold','fontsize',7);
        end
        %add more points beyond tdBuySetup = 9
        if i < idxend
            k = i+1;
            bs = tdBuySetup(k,1);
            while bs ~= 0 && k < idxend
                text(-idxstart+1+k,p(k,4)-shift,num2str(bs),'color','r','fontweight','bold','fontsize',7);
                k = k+1;
                bs = tdBuySetup(k,1);
            end
        end
    end
    if tdSellSetup(i,1) == 9
        for k = 1:9
            if i-idxstart+2-k < 1, continue;end
            text(i-idxstart+2-k,p(i+1-k,3)+shift,num2str(tdSellSetup(i+1-k,1) ),'color','g','fontweight','bold','fontsize',7);
        end
        if i < idxend
            k = i+1;
            ss = tdSellSetup(k,1);
            while ss ~= 0 && k < idxend
                text(-idxstart+1+k,p(k,3)+shift,num2str(ss),'color','g','fontweight','bold','fontsize',7);
                k = k+1;
                ss = tdSellSetup(k,1);
            end               
        end
    end
    %
    if tdBuyCountDown(i,1) == 11 || tdBuyCountDown(i,1) == 12 || tdBuyCountDown(i,1) == 13
        text(i-idxstart+1,p(i,4)-2*shift,num2str(tdBuyCountDown(i,1) ),'color','k','fontweight','bold','fontsize',7);
    end
    %
    if tdSellCountDown(i,1) == 11 || tdSellCountDown(i,1) == 12 || tdSellCountDown(i,1) == 13
        text(i-idxstart+1,p(i,3)+2*shift,num2str(tdSellCountDown(i,1) ),'color','k','fontweight','bold','fontsize',7);
    end
end
%

if tdBuySetup(idxend,1) ~= 0
    i = idxend;
    for k = 1:9
        if tdBuySetup(i-k+1) ~= 0
            text(i-idxstart+2-k,p(i+1-k,4)-shift,num2str(tdBuySetup(i+1-k,1) ),'color','r','fontweight','bold','fontsize',7);
        else
            break
        end
    end
end

if tdSellSetup(idxend,1) ~= 0
    i = idxend;
    for k = 1:9
        if tdSellSetup(i-k+1) ~= 0
            text(i-idxstart+2-k,p(i+1-k,3)+shift,num2str(tdSellSetup(i+1-k,1) ),'color','g','fontweight','bold','fontsize',7);
        else
            break
        end
    end
end

ylabel('price');
xlabel('serial time number')
hold off;

ax(2) = subplot(2,1,2);
plot(macdvec2plot,'b');hold on;
plot(nineperma2plot,'r');
xtick = get(ax(2),'XTick');
nxtick = length(xtick);
xticklabel = cell(nxtick,1);
for i = 1:nxtick
    if xtick(i) > length(datevec2plot), continue;end
    if xtick(i) == 0
        xticklabel{i} = index2plot(1);
    else
        xticklabel{i}= index2plot(xtick(i));
    end
end
set(ax(2),'XTickLabel',xticklabel,'fontsize',8);grid on;
hold off;
legend('macd','nineperma');
xlabel('serial time number')
linkaxes(ax,'x')


end