function [] = tools_technicalplot2(inputmat,figureidx,titlestr,usedatelabel)

p = inputmat(:,1:5);
%idx = inputmat(:,6);
HH = inputmat(:,8);LL = inputmat(:,9);
jaw = inputmat(:,10);teeth = inputmat(:,11);lips = inputmat(:,12);
bs = inputmat(:,13);ss = inputmat(:,14);
lvlup = inputmat(:,15);lvldn = inputmat(:,16);
bc = inputmat(:,17);sc = inputmat(:,18);

if nargin < 2, figureidx = 1;end

figure(figureidx);
candle(p(:,3),p(:,4),p(:,5),p(:,2),[0.75,0.75,0.75]);hold on;
plot(jaw,'b');
plot(teeth,'r');
plot(lips,'g');
%
stairs(HH,'r--');
stairs(LL,'g--');
stairs(lvlup,'color',[0.75 0 0],'linewidth',1.5);
stairs(lvldn,'color',[0 0.75 0],'linewidth',1.5);

shift = 0.005;
for i = 1:length(p)
    if bs(i) == 9
        for k = 1:9
            if i-1+2-k < 1, continue;end
            text(i-1+2-k,p(i+1-k,4)-shift,num2str(bs(i+1-k) ),'color','r','fontweight','bold','fontsize',7);
        end
        %add more points beyond bs = 9
        if i < length(p)
            k = i+1;
            bs_k = bs(k,1);
            while bs_k ~= 0 && k < length(p)
                text(-1+1+k,p(k,4)-shift,num2str(bs_k),'color','r','fontweight','bold','fontsize',7);
                k = k+1;
                bs_k = bs(k,1);
            end
        end
    end
    if ss(i) == 9
        for k = 1:9
            if i-1+2-k < 1, continue;end
            text(i-1+2-k,p(i+1-k,3)+shift,num2str(ss(i+1-k) ),'color','g','fontweight','bold','fontsize',7);
        end
        if i < length(p)
            k = i+1;
            ss_k = ss(k,1);
            while ss_k ~= 0 && k < length(p)
                text(-1+1+k,p(k,3)+shift,num2str(ss_k),'color','g','fontweight','bold','fontsize',7);
                k = k+1;
                ss_k = ss(k,1);
            end               
        end
    end
    %
    if bc(i) == 13
        text(i,p(i,4)-2*shift,num2str(bc(i) ),'color','k','fontweight','bold','fontsize',7);
    end
    %
    if sc(i) == 13
        text(i,p(i,3)+2*shift,num2str(sc(i) ),'color','k','fontweight','bold','fontsize',7);
    end
end

if bs(length(p)) ~= 0
    i = length(p);
    for k = 1:9
        if bs(i-k+1) ~= 0
            text(i-1+2-k,p(i+1-k,4)-shift,num2str(bs(i+1-k) ),'color','r','fontweight','bold','fontsize',7);
        else
            break
        end
    end
end

if ss(length(p)) ~= 0
    i = length(p);
    for k = 1:9
        if ss(i-k+1) ~= 0
            text(i-1+2-k,p(i+1-k,3)+shift,num2str(ss(i+1-k) ),'color','g','fontweight','bold','fontsize',7);
        else
            break
        end
    end
end

hold off;

if nargin >= 3, title(titlestr);end

if nargin == 4 && usedatelabel
    xtick = get(gca,'XTick');
    nxtick = length(xtick);
    xticklabel = cell(nxtick,1);
    for i = 1:nxtick
        if xtick(i) > size(p,1), continue;end
        if xtick(i) == 0
            xticklabel{i} = datestr(p(1,1),'dd-mmm');
        else
            xticklabel{i}= datestr(p(xtick(i),1),'dd-mmm');
        end
    end
    set(gca,'XTickLabel',xticklabel,'fontsize',8);
end


end

