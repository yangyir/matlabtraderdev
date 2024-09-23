function [] = tools_technicalplot2(inputmat,figureidx,titlestr,usedatelabel,shift,extraindicatorname,extraindicatorval)

if isnumeric(inputmat)
    px = inputmat(:,1:5);
    %idx = inputmat(:,6);
    HH = inputmat(:,8);LL = inputmat(:,9);
    jaw = inputmat(:,10);teeth = inputmat(:,11);lips = inputmat(:,12);
    bs = inputmat(:,13);ss = inputmat(:,14);
    lvlup = inputmat(:,15);lvldn = inputmat(:,16);
    bc = inputmat(:,17);sc = inputmat(:,18);
elseif isstruct(inputmat)
    try
        px = inputmat.p;
    catch
        px = inputmat.px;
    end
    HH = inputmat.hh;LL = inputmat.ll;
    jaw = inputmat.jaw;teeth = inputmat.teeth;lips = inputmat.lips;
    bs = inputmat.bs;ss = inputmat.ss;
    lvlup = inputmat.lvlup;lvldn = inputmat.lvldn;
    bc = inputmat.bc;sc = inputmat.sc;
else
    error('not implemented...')
end

if nargin < 2, figureidx = 1;end

if nargin < 5
    shift = 0.005;
end

if nargin < 6
    extraindicatorname = 'none';
else
    if ~(strcmpi(extraindicatorname,'rsi') || strcmpi(extraindicatorname,'macd') || strcmpi(extraindicatorname,'none'))
        error('tools_technicalplot2:invalid extraindicatorname input')
    end
end

figure(figureidx);
if strcmpi(extraindicatorname,'none')
    if strcmpi(version('-release'),'2014a')
        candle(px(:,3),px(:,4),px(:,5),px(:,2),[0.75,0.75,0.75]);hold on;
    else
    %candle(Data) plots a candlestick chart from a series of opening, high, low, and closing prices of a security.
        candle(px(:,2:5),[0.75,0.75,0.75]);hold on;
    end
    plot(jaw,'b');
    plot(teeth,'r');
    plot(lips,'g');
    %
    stairs(HH,'r--');
    stairs(LL,'g--');
    stairs(lvlup,'color',[0.75 0 0],'linewidth',1.5);
    stairs(lvldn,'color',[0 0.75 0],'linewidth',1.5);
    for i = 1:length(px)
        if bs(i) == 9
            for k = 1:9
                if i-1+2-k < 1, continue;end
                text(i-1+2-k,px(i+1-k,4)-shift,num2str(bs(i+1-k) ),'color','r','fontweight','bold','fontsize',7);
            end
            %add more points beyond bs = 9
            if i < length(px)
                k = i+1;
                bs_k = bs(k,1);
                while bs_k ~= 0 && k < length(px)
                    text(-1+1+k,px(k,4)-shift,num2str(bs_k),'color','r','fontweight','bold','fontsize',7);
                    k = k+1;
                    bs_k = bs(k,1);
                end
            end
        end
        if ss(i) == 9
            for k = 1:9
                if i-1+2-k < 1, continue;end
                text(i-1+2-k,px(i+1-k,3)+shift,num2str(ss(i+1-k) ),'color','g','fontweight','bold','fontsize',7);
            end
            if i < length(px)
                k = i+1;
                ss_k = ss(k,1);
                while ss_k ~= 0 && k < length(px)
                    text(-1+1+k,px(k,3)+shift,num2str(ss_k),'color','g','fontweight','bold','fontsize',7);
                    k = k+1;
                    ss_k = ss(k,1);
                end
            end
        end
        %
        if bc(i) == 13
            text(i,px(i,4)-2*shift,num2str(bc(i) ),'color','k','fontweight','bold','fontsize',7);
        end
        %
        if sc(i) == 13
            text(i,px(i,3)+2*shift,num2str(sc(i) ),'color','k','fontweight','bold','fontsize',7);
        end
    end
    
    if bs(length(px)) ~= 0
        i = length(px);
        for k = 1:bs(length(px))
            if i-k+1 <= 0, continue;end
            if bs(i-k+1) ~= 0
                text(i-1+2-k,px(i+1-k,4)-shift,num2str(bs(i+1-k) ),'color','r','fontweight','bold','fontsize',7);
            else
                break
            end
        end
    end
    
    if ss(length(px)) ~= 0
        i = length(px);
        for k = 1:ss(length(px))
            if i-k+1 <= 0, continue;end
            if ss(i-k+1) ~= 0
                text(i-1+2-k,px(i+1-k,3)+shift,num2str(ss(i+1-k) ),'color','g','fontweight','bold','fontsize',7);
            else
                break
            end
        end
    end
    
    hold off;
    
    if nargin >= 3, title(titlestr);end
    
    if nargin >= 4 && usedatelabel
        xtick = get(gca,'XTick');
        nxtick = length(xtick);
        xticklabel = cell(nxtick,1);
        for i = 1:nxtick
            if xtick(i) > size(px,1), continue;end
            if xtick(i) == 0
                xticklabel{i} = datestr(px(1,1),'dd-mmm-yy');
            else
                xticklabel{i}= datestr(px(xtick(i),1),'dd-mmm-yy');
            end
        end
        set(gca,'XTickLabel',xticklabel,'fontsize',8);
    end
else
    subplot(211);
    if strcmpi(version('-release'),'2014a')
        candle(px(:,3),px(:,4),px(:,5),px(:,2),[0.75,0.75,0.75]);hold on;
    else
    %candle(Data) plots a candlestick chart from a series of opening, high, low, and closing prices of a security.
        candle(px(:,2:5),[0.75,0.75,0.75]);hold on;
        grid off;
    end
    plot(jaw,'b');
    plot(teeth,'r');
    plot(lips,'g');
    %
    stairs(HH,'r--');
    stairs(LL,'g--');
    stairs(lvlup,'color',[0.75 0 0],'linewidth',1.5);
    stairs(lvldn,'color',[0 0.75 0],'linewidth',1.5);
    for i = 1:length(px)
        if bs(i) == 9
            for k = 1:9
                if i-1+2-k < 1, continue;end
                text(i-1+2-k,px(i+1-k,4)-shift,num2str(bs(i+1-k) ),'color','r','fontweight','bold','fontsize',7);
            end
            %add more points beyond bs = 9
            if i < length(px)
                k = i+1;
                bs_k = bs(k,1);
                while bs_k ~= 0 && k < length(px)
                    text(-1+1+k,px(k,4)-shift,num2str(bs_k),'color','r','fontweight','bold','fontsize',7);
                    k = k+1;
                    bs_k = bs(k,1);
                end
            end
        end
        if ss(i) == 9
            for k = 1:9
                if i-1+2-k < 1, continue;end
                text(i-1+2-k,px(i+1-k,3)+shift,num2str(ss(i+1-k) ),'color','g','fontweight','bold','fontsize',7);
            end
            if i < length(px)
                k = i+1;
                ss_k = ss(k,1);
                while ss_k ~= 0 && k < length(px)
                    text(-1+1+k,px(k,3)+shift,num2str(ss_k),'color','g','fontweight','bold','fontsize',7);
                    k = k+1;
                    ss_k = ss(k,1);
                end
            end
        end
        %
        if bc(i) == 13
            text(i,px(i,4)-2*shift,num2str(bc(i) ),'color','k','fontweight','bold','fontsize',7);
        end
        %
        if sc(i) == 13
            text(i,px(i,3)+2*shift,num2str(sc(i) ),'color','k','fontweight','bold','fontsize',7);
        end
    end
    
    if bs(length(px)) ~= 0
        i = length(px);
        for k = 1:bs(length(px))
            if i-k+1 <= 0, continue;end
            if bs(i-k+1) ~= 0
                text(i-1+2-k,px(i+1-k,4)-shift,num2str(bs(i+1-k) ),'color','r','fontweight','bold','fontsize',7);
            else
                break
            end
        end
    end
    
    if ss(length(px)) ~= 0
        i = length(px);
        for k = 1:ss(length(px))
            if i-k+1 <= 0, continue;end
            if ss(i-k+1) ~= 0
                text(i-1+2-k,px(i+1-k,3)+shift,num2str(ss(i+1-k) ),'color','g','fontweight','bold','fontsize',7);
            else
                break
            end
        end
    end
    
    hold off;
    
    if nargin >= 3, title(titlestr);end
    
    if nargin >= 4 && usedatelabel
        xtick = get(gca,'XTick');
        nxtick = length(xtick);
        xticklabel = cell(nxtick,1);
        for i = 1:nxtick
            if xtick(i) > size(px,1), continue;end
            if xtick(i) == 0
                xticklabel{i} = datestr(px(1,1),'dd-mmm-yy');
            else
                xticklabel{i}= datestr(px(xtick(i),1),'dd-mmm-yy');
            end
        end
        set(gca,'XTickLabel',xticklabel,'fontsize',8);
    end
    %
    subplot(212);
    idx = find(extraindicatorval(:,1) >= px(1,1),1,'first');
    plot(extraindicatorval(idx:end,2),'b');
    hold on;
    stairs(20*ones(size(px)),'r-*');
    stairs(80*ones(size(px)),'r-*');
    hold off;
    
    if nargin >= 3, title(upper(extraindicatorname));end
    
    if nargin >= 4 && usedatelabel
        xtick = get(gca,'XTick');
        nxtick = length(xtick);
        xticklabel = cell(nxtick,1);
        for i = 1:nxtick
            if xtick(i) > size(px,1), continue;end
            if xtick(i) == 0
                xticklabel{i} = datestr(px(1,1),'dd-mmm-yy');
            else
                xticklabel{i}= datestr(px(xtick(i),1),'dd-mmm-yy');
            end
        end
        set(gca,'XTickLabel',xticklabel,'fontsize',8);
    end
    
    
    
end


    




end

