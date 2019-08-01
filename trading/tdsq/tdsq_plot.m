function [] = tdsq_plot(p,idxstart,idxend,instr2)
shift = 2*instr2.tick_size;
figure(3);
h1 = gca;
% idxstart = 800;
% idxend = 1080;

pxopen = p(:,2);pxhigh = p(:,3);pxlow = p(:,4);pxclose = p(:,5);
[tdBuySetup,tdSellSetup,tdSTResistence,tdSTSupport] = tdsq(p);

datevec2plot = p(idxstart:idxend,1);
pxhigh2plot = pxhigh(idxstart:idxend);
pxlow2plot = pxlow(idxstart:idxend);
pxclose2plot = pxclose(idxstart:idxend);
pxopen2plot = pxopen(idxstart:idxend);
index = 1:1:size(p,1);
index2plot = index(idxstart:idxend);

plot(tdSTResistence(idxstart:idxend),'r:','LineWidth',2);hold on;
plot(tdSTSupport(idxstart:idxend),'g:','LineWidth',2);
legend('tdst-resistence','tdst-support');
candle(pxhigh2plot,pxlow2plot,pxclose2plot,pxopen2plot);
xtick = get(h1,'XTick');
nxtick = length(xtick);
xticklabel = cell(nxtick,1);
xticklabel{1} = datestr(datevec2plot(1),'mmm-dd HH:MM');
for i = 2:nxtick
    if xtick(i) <= length(datevec2plot)
%         xticklabel{i} = datestr(datevec2plot(xtick(i)),'mmm-dd HH:MM');
        xticklabel{i}= index2plot(xtick(i))+1;
    end
end
set(h1,'XTickLabel',xticklabel,'fontsize',8);grid on;
hold off;

for i = idxstart:idxend
    if tdBuySetup(i,1) == 9
        for k = 1:9
            if i-idxstart+2-k < 1, continue;end
            text(i-idxstart+2-k,p(i+1-k,4)-shift,num2str(tdBuySetup(i+1-k,1) ),'color','r','fontweight','bold','fontsize',8);
        end
    end
    if tdSellSetup(i,1) == 9
        for k = 1:9
            if i-idxstart+2-k < 1, continue;end
            text(i-idxstart+2-k,p(i+1-k,3)+shift,num2str(tdSellSetup(i+1-k,1) ),'color','g','fontweight','bold','fontsize',8);
        end
    end
    %
end
%

if tdBuySetup(idxend,1) ~= 0
    i = idxend;
    for k = 1:9
        if tdBuySetup(i-k+1) ~= 0
            text(i-idxstart+2-k,p(i+1-k,4)-shift,num2str(tdBuySetup(i+1-k,1) ),'color','r','fontweight','bold','fontsize',8);
        else
            break
        end
    end
end

if tdSellSetup(idxend,1) ~= 0
    i = idxend;
    for k = 1:9
        if tdSellSetup(i-k+1) ~= 0
            text(i-idxstart+2-k,p(i+1-k,3)+shift,num2str(tdSellSetup(i+1-k,1) ),'color','r','fontweight','bold','fontsize',8);
        else
            break
        end
    end
end

ylabel('price');
hold off;
end