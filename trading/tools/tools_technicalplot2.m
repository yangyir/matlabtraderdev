function [] = tools_technicalplot2(inputmat)

p = inputmat(:,1:5);
%idx = inputmat(:,6);
HH = inputmat(:,7);LL = inputmat(:,8);
jaw = inputmat(:,9);teeth = inputmat(:,10);lips = inputmat(:,11);
bs = inputmat(:,12);ss = inputmat(:,13);
lvlup = inputmat(:,14);lvldn = inputmat(:,15);
bc = inputmat(:,16);sc = inputmat(:,17);

figure(1);
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




end

