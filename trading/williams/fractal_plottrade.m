function [output] = fractal_plottrade(tradein,usemt5)
% utility function to plot how the trade is behavored over time
    if nargin < 2
        usemt5 = 1;
    end

    if ~isa(tradein,'cTradeOpen')
        error('fractal_plottrade:invalid trade input...')
    end

    tradefreq = tradein.opensignal_.frequency_;

    code = tradein.code_;

    if strcmpi(tradefreq,'h4') || strcmpi(tradefreq,'4h')
        [~,ei1] = charlotte_loaddata('futcode',code,'frequency',tradefreq,'nfractal',2,'usemt5',usemt5);
        freq2 = 'm30';
        [~,ei2] = charlotte_loaddata('futcode',code,'frequency',freq2,'nfractal',4,'usemt5',usemt5);     % use m30 as a secondary check for h4
        leftshift = 4;
        rightshift = 4;
    elseif strcmpi(tradefreq,'h1') || strcmpi(tradefreq,'1h')
        [~,ei1] = charlotte_loaddata('futcode',code,'frequency',tradefreq,'nfractal',4,'usemt5',usemt5);
        freq2 = 'm15';
        [~,ei2] = charlotte_loaddata('futcode',code,'frequency',freq2,'nfractal',4,'usemt5',usemt5);     % use m15 as a secondary check for h1
        leftshift = 8;
        rightshift = 8;
    elseif strcmpi(tradefreq,'m30') || strcmpi(tradefreq,'30m')
        [~,ei1] = charlotte_loaddata('futcode',code,'frequency',tradefreq,'nfractal',4,'usemt5',usemt5);
        freq2 = 'm5';
        [~,ei2] = charlotte_loaddata('futcode',code,'frequency',freq2,'nfractal',6,'usemt5',usemt5);     % use m5 as a secondary check for m30
        leftshift = 8;
        rightshift = 8;
    else
        error('fractal_plottrade:only M30,H1,H4 frequency is supported...')
    end

    tradeopendt = tradein.opendatetime1_;
    tradeclosedt = tradein.closedatetime1_;     % update in case tradeclosedt is available

    idxopen1 = find(ei1.px(:,1) <= tradeopendt,1,'last');
    idxclose1 = [];
    for i = idxopen1+1:size(ei1.px,1)
        if tradein.opendirection_ == 1
            if ei1.px(i,4) < ei1.teeth(i)
                idxclose1 = i;
                break;
            end
        else
            if ei1.px(i,4) > ei1.teeth(i)
                 idxclose1 = i;
                 break;
            end
        end
    end

    if isempty(idxclose1)
        idxclose1 = size(ei1.px,1);
        rightshift = 0;
    end

    atropen = ei1.atr(idxopen1-1);

    ei1_ = fractal_truncate(ei1,idxclose1+rightshift,idxopen1-leftshift);
    px = ei1_.px;
    HH = ei1_.hh;LL = ei1_.ll;
    jaw = ei1_.jaw;teeth = ei1_.teeth;lips = ei1_.lips;
    bs = ei1_.bs;ss = ei1_.ss;
    lvlup = ei1_.lvlup;lvldn = ei1_.lvldn;
    bc = ei1_.bc;sc = ei1_.sc;
    atrvalue = ei1_.atr;
    pnlatr = 0*atrvalue;

    atrmultiplier = 1.8;
    lamda = 0.5;
    atrmultipliermin = 0.8;
    atrmultipliermax = 1.8;
    initialloss = ei1.atr(idxopen1-1);
    atrcloseid = [];
    atrreachid1 = [];   %1.5ATR reached
    atrreachid2 = [];   %2.0ATR reached
    atrreachid3 = [];   %3.0ATR reached
    atrreachid4 = [];   %4.0ATR reached
    atrreachid5 = [];   %5.0ATR reached
    
    if tradein.opendirection_ == 1
        atrstoploss = HH - atrmultiplier*atropen;
        highesthigh = HH(leftshift+1);
        
        atrstoploss(leftshift+1) = max(atrstoploss(leftshift+1),ei1.teeth(idxopen1-1));
        atrstoploss(1:leftshift) = atrstoploss(leftshift+1);
        
        for i = leftshift+1:size(px,1)
            if i == leftshift + 1
                if px(i,5) < tradein.openprice_ - atrmultipliermax*initialloss && isempty(atrcloseid)
                    atrcloseid = i;
                end
            else
                if px(i,5) < atrstoploss(i-1) && isempty(atrcloseid)
                    atrcloseid = i;
                end
            end

            if px(i,3) > highesthigh
                highesthigh = px(i,3);
            end
            profit = highesthigh - tradein.openprice_;

            pnlatr(i) = max(pnlatr(i-1),profit/initialloss);
            if pnlatr(i) > 1.5               
                atrmultiplier = atrmultipliermin + (atrmultipliermax-atrmultipliermin)*exp(-lamda*profit/initialloss);
            end
            if pnlatr(i) > 1.5 && isempty(atrreachid1), atrreachid1 = i; end
            if pnlatr(i) > 2.0 && isempty(atrreachid2), atrreachid2 = i; end
            if pnlatr(i) > 3.0 && isempty(atrreachid3), atrreachid3 = i; end
            if pnlatr(i) > 4.0 && isempty(atrreachid4), atrreachid4 = i; end
            if pnlatr(i) > 5.0 && isempty(atrreachid5), atrreachid5 = i; end

            atrstoploss(i) = max(atrstoploss(i-1),highesthigh - atrmultiplier*atrvalue(i));
            atrstoploss(i) = max(atrstoploss(i),teeth(i));
            
        end
    elseif tradein.opendirection_ == -1
        atrstoploss = LL + atrmultiplier*atropen;
        lowestlow = LL(leftshift+1);

        atrstoploss(leftshift+1) = min(atrstoploss(leftshift+1),ei1.teeth(idxopen1-1));
        atrstoploss(1:leftshift) = atrstoploss(leftshift+1);
        
        for i = leftshift+1:size(px,1)
            if i == leftshift + 1
                if px(i,5) > tradein.openprice_ + atrmultipliermax*initialloss && isempty(atrcloseid)
                    atrcloseid = i;
                end
            else
                if px(i,5) > atrstoploss(i-1) && isempty(atrcloseid)
                    atrcloseid = i;
                end
            end
            
            if px(i,4) < lowestlow
                lowestlow = px(i,4);
            end
            profit = tradein.openprice_ - lowestlow;
            pnlatr(i) = max(pnlatr(i-1),profit/initialloss);
            if pnlatr(i) > 1.5              
                atrmultiplier = atrmultipliermin + (atrmultipliermax-atrmultipliermin)*exp(-lamda*profit/initialloss);
            end
            if pnlatr(i) > 1.5 && isempty(atrreachid1), atrreachid1 = i; end
            if pnlatr(i) > 2.0 && isempty(atrreachid2), atrreachid2 = i; end
            if pnlatr(i) > 3.0 && isempty(atrreachid3), atrreachid3 = i; end
            if pnlatr(i) > 4.0 && isempty(atrreachid4), atrreachid4 = i; end
            if pnlatr(i) > 5.0 && isempty(atrreachid5), atrreachid5 = i; end

            atrstoploss(i) = min(atrstoploss(i-1),lowestlow + atrmultiplier*atrvalue(i));
            atrstoploss(i) = min(atrstoploss(i),teeth(i));
            
        end
    end

    shift = 2*tradein.instrument_.tick_size;
    
    figure(1)
    subplot(211)
    if strcmpi(version('-release'),'2014a')
        candle(px(:,3),px(:,4),px(:,5),px(:,2),[0.75,0.75,0.75]);hold on;
    else
        %candle(Data) plots a candlestick chart from a series of opening, high, low, and closing prices of a security.
        candle(px(:,2:5),[0.75,0.75,0.75]);hold on;
    end
    
    if tradein.opendirection_ == 1
        text(leftshift+1,HH(leftshift+1)+10*shift,'open','color','r','fontweight','bold','fontsize',9);
        text(atrcloseid,px(atrcloseid,3)+10*shift,'atrclose','color','g','fontweight','bold','fontsize',9);
        if ~isempty(atrreachid1)
            text(atrreachid1,px(atrreachid1,3)+10*shift,'atr1.5','color','r','fontweight','bold','fontsize',9);
        end
        if ~isempty(atrreachid2)
            text(atrreachid2,px(atrreachid2,3)+10*shift,'atr2','color','r','fontweight','bold','fontsize',9);
        end
        if ~isempty(atrreachid3)
            text(atrreachid3,px(atrreachid3,3)+10*shift,'atr3','color','r','fontweight','bold','fontsize',9);
        end
        if ~isempty(atrreachid4)
            text(atrreachid4,px(atrreachid4,3)+10*shift,'atr4','color','r','fontweight','bold','fontsize',9);
        end
        if ~isempty(atrreachid5)
            text(atrreachid5,px(atrreachid5,3)+10*shift,'atr5','color','r','fontweight','bold','fontsize',9);
        end

    else
        text(leftshift+1,LL(leftshift+1)-10*shift,'open','color','g','fontweight','bold','fontsize',9);
        text(atrcloseid,px(atrcloseid,4)-10*shift,'atrclose','color','r','fontweight','bold','fontsize',9);
        if ~isempty(atrreachid1)
            text(atrreachid1,px(atrreachid1,4)-10*shift,'atr1.5','color','g','fontweight','bold','fontsize',9);
        end
        if ~isempty(atrreachid2)
            text(atrreachid2,px(atrreachid2,4)-10*shift,'atr2','color','g','fontweight','bold','fontsize',9);
        end
        if ~isempty(atrreachid3)
            text(atrreachid3,px(atrreachid3,4)-10*shift,'atr3','color','g','fontweight','bold','fontsize',9);
        end
        if ~isempty(atrreachid4)
            text(atrreachid4,px(atrreachid4,4)-10*shift,'atr4','color','g','fontweight','bold','fontsize',9);
        end
        if ~isempty(atrreachid5)
            text(atrreachid5,px(atrreachid5,4)-10*shift,'atr5','color','g','fontweight','bold','fontsize',9);
        end
    end

    plot(jaw,'b');
    plot(teeth,'r');
    plot(lips,'g');
    %
    stairs(HH,'r--');
    stairs(LL,'g--');
    stairs(atrstoploss,'color',[0,47/255,0.75],'LineWidth',1.5,'LineStyle',':');
%     stairs(lvlup,'color',[0.75 0 0],'linewidth',1.5);
%     stairs(lvldn,'color',[0 0.75 0],'linewidth',1.5);

    for i = 1:size(px,1)
        if bs(i) == 9
            for k = 1:9
                if i-1+2-k < 1, continue;end
                text(i-1+2-k,px(i+1-k,4)-shift,num2str(bs(i+1-k) ),'color','r','fontweight','bold','fontsize',7);
            end
            %add more points beyond bs = 9
%             if i < size(px,1)
%                 k = i+1;
%                 bs_k = bs(k,1);
%                 while bs_k ~= 0 && k < length(px)
%                     text(-1+1+k,px(k,4)-shift,num2str(bs_k),'color','r','fontweight','bold','fontsize',7);
%                     k = k+1;
%                     bs_k = bs(k,1);
%                 end
%             end
        elseif bs(i) > 9
            text(i,px(i,4)-shift,num2str(bs(i) ),'color','r','fontweight','bold','fontsize',7);
        end
        if ss(i) == 9
            for k = 1:9
                if i-1+2-k < 1, continue;end
                text(i-1+2-k,px(i+1-k,3)+shift,num2str(ss(i+1-k) ),'color','g','fontweight','bold','fontsize',7);
            end
%             if i < size(px,1)
%                 k = i+1;
%                 ss_k = ss(k,1);
%                 while ss_k ~= 0 && k < length(px)
%                     text(-1+1+k,px(k,3)+shift,num2str(ss_k),'color','g','fontweight','bold','fontsize',7);
%                     k = k+1;
%                     ss_k = ss(k,1);
%                 end
%             end
        elseif ss(i) > 9
            text(i,px(i,3)+shift,num2str(ss(i) ),'color','g','fontweight','bold','fontsize',7);
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
    
    if bs(size(px,1)) ~= 0
        i = size(px,1);
        for k = 1:bs(size(px,1))
            if i-k+1 <= 0, continue;end
            if bs(i-k+1) ~= 0
                text(i-1+2-k,px(i+1-k,4)-shift,num2str(bs(i+1-k) ),'color','r','fontweight','bold','fontsize',7);
            else
                break
            end
        end
    end
    
    if ss(size(px,1)) ~= 0
        i = size(px,1);
        for k = 1:ss(size(px,1))
            if i-k+1 <= 0, continue;end
            if ss(i-k+1) ~= 0
                text(i-1+2-k,px(i+1-k,3)+shift,num2str(ss(i+1-k) ),'color','g','fontweight','bold','fontsize',7);
            else
                break
            end
        end
    end
    


    title([code,'-',tradefreq,'-',tradein.opensignal_.mode_,':',datestr(tradein.opendatetime1_,'yy-mm-dd HH:MM')]);
    hold off;
    xtick = get(gca,'XTick');
    nxtick = length(xtick);
    xticklabel = cell(nxtick,1);
    for i = 1:nxtick
        if xtick(i) > size(px,1), continue;end
        if xtick(i) == 0
            continue;
        else
            try
                xticklabel{i}= datestr(ei1.px(xtick(i)+idxopen1-leftshift-1,1),'yy-mm-dd HH:MM');
            catch
                continue;
            end
        end
    end
    set(gca,'XTickLabel',xticklabel,'fontsize',8);
    %
    %
    idxopen2 = find(ei2.px(:,1) >= ei1.px(idxopen1,1),1,'first');
    idxclose2 = find(ei2.px(:,1) < ei1.px(idxopen1+1,1),1,'last');

    ei2_ = fractal_truncate(ei2,idxclose2,idxopen2);
    px2 = ei2_.px;
    jaw2 = ei2_.jaw;teeth2 = ei2_.teeth;lips2 = ei2_.lips;
    

    try
        subplot(212)
        if strcmpi(version('-release'),'2014a')
            candle(px2(:,3),px2(:,4),px2(:,5),px2(:,2),[0.75 0.75 0.75]);hold on;
        else
            %candle(Data) plots a candlestick chart from a series of opening, high, low, and closing prices of a security.
            candle(px2(:,2:5),[0.75 0.75 0.75]);hold on;
        end
        if tradein.opendirection_ == 1
            barrier = tradein.opensignal_.hh_;
            stairs(barrier * ones(idxclose2-idxopen2+1,1),'r--');
        else
            barrier = tradein.opensignal_.ll_;
            stairs(barrier * ones(idxclose2-idxopen2+1,1),'g--');
        end
        plot(jaw2,'b');
        plot(teeth2,'r');
        plot(lips2,'g');
        title([code,'-',freq2]);
        hold off;
        xtick = get(gca,'XTick');
        nxtick = length(xtick);
        xticklabel = cell(nxtick,1);
        for i = 1:nxtick
            if xtick(i) > size(px2,1), continue;end
            if xtick(i) == 0
                continue;
            else
                try
                    xticklabel{i}= datestr(ei2.px(xtick(i)+idxopen2-1,1),'yyyy-mm-dd HH:MM');
                catch
                    continue;
                end
            end
        end
        set(gca,'XTickLabel',xticklabel,'fontsize',8);
    catch
    end

  
    output = struct('pnlatr',pnlatr);
    output.atrstoploss = atrstoploss;
    
end