function [outputs] = tdsq_plotopensignal( currenti,p,bs,ss,lvlup,lvldn,bc,sc,diffvec,figureidx )
%
if nargin < 10
    figureidx = 1;
end
[macdbs,macdss] = tdsq_setup(diffvec);
temp = diffvec(2:end).*diffvec(1:end-1);
idxchg = find(temp<0)+1;

idxchgbefore = find(idxchg <= currenti,3,'last');

i1 = idxchg(idxchgbefore(1));
i2 = idxchg(idxchgbefore(2));
i3 = idxchg(idxchgbefore(3));
    
range1max = max(p(i1:i2-1,3));
range1min = min(p(i1:i2-1,4));
range2max = max(p(i2:i3-1,3));
range2min = min(p(i2:i3-1,4));
x1max = find(p(i1:i2-1,3)==range1max,1,'last')+i1-1;
x1min = find(p(i1:i2-1,4)==range1min,1,'last')+i1-1;
x2max = find(p(i2:i3-1,3)==range2max,1,'last')+i2-1;
x2min = find(p(i2:i3-1,4)==range2min,1,'last')+i2-1;
x1max = x1max-i1+1;
x1min = x1min-i1+1;
x2max = x2max-i1+1;
x2min = x2min-i1+1;
k1 = (range2max-range1max)/(x2max-x1max);
y1 = range1max - k1*x1max;

k2 = (range2min-range1min)/(x2min-x1min);
y2 = range1min - k2*x1min;

if i3 < currenti
    i4 = currenti-1;
    range3max = max(p(i3:i4,3));
    range3min = min(p(i3:i4,4));
    x3max = find(p(i3:i4,3)==range3max,1,'last')+i3-1;
    x3min = find(p(i3:i4,4)==range3min,1,'last')+i3-1;
    x3max = x3max-i1+1;
    x3min = x3min-i1+1;
    k3 = (range3max-range2max)/(x3max-x2max);
    y3 = range3max - k3*x3max;

    k4 = (range3min-range2min)/(x3min-x2min);
    y4 = range3min - k4*x3min;
else
    range3max = [];
    range3min = [];
    k3 = [];y3 = [];
    k4 = [];y4 = [];
end

x = i1:currenti;
xreal = x;
x = x-i1+1;

outputs = struct('k1',k1,'y1',y1,...
    'k2',k2,'y2',y2,...
    'k3',k3,'y3',y3,...
    'k4',k4,'y4',y4,...
    'range1max',range1max,'range1min',range1min,...
    'range2max',range2max,'range2min',range2min,...
    'range3max',range3max,'range3min',range3min,...
    'x',x);


figure(figureidx);
pv1 = [0.05 0.3 0.9 0.65];
ax(1) = subplot('position',pv1);
% ax(1) = subplot(211);
if isnan(k1)
    plot(x,range1max*ones(length(x),1),'c--');hold on;
else
    plot(x,x*k1+y1,'k');hold on;
    plot(x1max:x(end),range1max*ones(length(x1max:x(end)),1),'c--');
    plot(x2max:x(end),range2max*ones(length(x2max:x(end)),1),'c--');
end

plot(x1max,x1max*k1+y1,'r*');
plot(x2max,x2max*k1+y1,'r*');

if isnan(k2)
   plot(x,range1min*ones(length(x),1),'b--');
else
   plot(x,x*k2+y2,'k');
   plot(x1min:x(end),range1min*ones(length(x1min:x(end)),1),'b--');
   plot(x2min:x(end),range2min*ones(length(x2min:x(end)),1),'b--');
   
end
plot(x1min,x1min*k2+y2,'g*');
plot(x2min,x2min*k2+y2,'g*');

if i3 < currenti
    if isnan(k3)
        plot(x,range2max*ones(length(x),1),'r--');
    else
        plot(x,x*k3+y3,'r--');
    end
    plot(x3max,x3max*k3+y3,'r*');
    plot(x3max:x(end),range3max*ones(length(x3max:x(end)),1),'c--');
    
    if isnan(k4)
        plot(x,range2min*ones(length(x),1),'r--');
    else
        plot(x,x*k4+y4,'r--');
    end
    plot(x3min,x3min*k4+y4,'g*');
    plot(x3min:x(end),range3min*ones(length(x3min:x(end)),1),'b--');
end


shift = 0.005;

for i = xreal(1):xreal(end)
    if bs(i,1) == 9
        for k = 1:9
            if i-xreal(1)+2-k < 1, continue;end
            text(i-xreal(1)+2-k,p(i+1-k,4)-shift,num2str(bs(i+1-k,1) ),'color','r','fontweight','bold','fontsize',7);
        end
        %add more points beyond tdBuySetup = 9
        if i < xreal(end)
            k = i+1;
            bs_i = bs(k,1);
            while bs_i ~= 0 && k < xreal(end)
                text(-xreal(1)+1+k,p(k,4)-shift,num2str(bs_i),'color','r','fontweight','bold','fontsize',7);
                k = k+1;
                bs_i = bs(k,1);
            end
        end
    end
    if ss(i,1) == 9
        for k = 1:9
            if i-xreal(1)+2-k < 1, continue;end
            text(i-xreal(1)+2-k,p(i+1-k,3)+shift,num2str(ss(i+1-k,1) ),'color','g','fontweight','bold','fontsize',7);
        end
        if i < xreal(end)
            k = i+1;
            ss_i = ss(k,1);
            while ss_i ~= 0 && k < xreal(end)
                text(-xreal(1)+1+k,p(k,3)+shift,num2str(ss_i),'color','g','fontweight','bold','fontsize',7);
                k = k+1;
                ss_i = ss(k,1);
            end               
        end
    end
    %
    if bc(i) == 11 || bc(i) == 12 || bc(i) == 13
        text(i-xreal(1)+1,p(i,4)-2*shift,num2str(bc(i)),'color','k','fontweight','bold','fontsize',7);
    end
    %
    if sc(i) == 11 || sc(i) == 12 || sc(i) == 13
        text(i-xreal(1)+1,p(i,3)+2*shift,num2str(sc(i) ),'color','k','fontweight','bold','fontsize',7);
    end
end


if bs(xreal(end),1) ~= 0
    i = xreal(end);
    for k = 1:9
        if bs(i-k+1) ~= 0
            text(x(end)-k+1,p(i+1-k,4)-shift,num2str(bs(i+1-k,1) ),'color','r','fontweight','bold','fontsize',7);
        else
            break
        end
    end
end

if ss(xreal(end),1) ~= 0
    i = xreal(end);
    for k = 1:9
        if ss(i-k+1) ~= 0
            text(x(end)-k+1,p(i+1-k,3)+shift,num2str(ss(i+1-k,1) ),'color','g','fontweight','bold','fontsize',7);
        else
            break
        end
    end
end


plot(x,lvlup(i1:currenti).*ones(length(x),1),'r--*','LineWidth',2);
plot(x,lvldn(i1:currenti).*ones(length(x),1),'g--*','LineWidth',2);
   
candle(p(xreal,3),p(xreal,4),p(xreal,5),p(xreal,2))
hold off;
xtick = get(ax(1),'XTick');
nxtick = length(xtick);
xticklabel = cell(nxtick,1);
for i = 1:nxtick
    if xtick(i) > length(x), continue;end
    if xtick(i) ~= 0
        try
            xticklabel{i}= xreal(xtick(i));
        catch
        end
    end
end
set(ax(1),'XTickLabel',xticklabel,'fontsize',8);
xlabel('time points');ylabel('price');

%
% ax(2) = subplot(212);
pv2 = [0.05 0.05 0.9 0.2];
ax(2) = subplot('position',pv2);
bar(x,diffvec(xreal),'r');

if macdbs(xreal(end),1) ~= 0
    i = xreal(end);
    for k = 1:9
        if macdbs(i-k+1) ~= 0
            text(x(end)-k+1,diffvec(i+1-k)-0.25*shift,num2str(macdbs(i+1-k,1) ),'color','r','fontweight','bold','fontsize',7);
        else
            break
        end
    end
end

if macdss(xreal(end),1) ~= 0
    i = xreal(end);
    for k = 1:9
        if macdss(i-k+1) ~= 0
            text(x(end)-k+1,diffvec(i+1-k)+0.25*shift,num2str(macdss(i+1-k,1) ),'color','g','fontweight','bold','fontsize',7);
        else
            break
        end
    end
end


xtick = get(ax(2),'XTick');
nxtick = length(xtick);
xticklabel = cell(nxtick,1);
for i = 1:nxtick
    if xtick(i) > length(x), continue;end
    if xtick(i) ~= 0
        try
            xticklabel{i}= xreal(xtick(i));
        catch
        end
    end
end

set(ax(2),'XTickLabel',xticklabel,'fontsize',8);
xlabel('time points');ylabel('macd');
linkaxes(ax,'x')

end

