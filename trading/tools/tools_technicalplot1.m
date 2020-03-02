function outputmat = tools_technicalplot1(p,nfractal,doplot,varargin)
%technical plot with DeMark and Williams' fractal and alligator indicator

if nargin < 2, nfractal = 2;end
if nargin < 3, doplot = 0;end

ip = inputParser;
ip.CaseSensitive = false;ip.KeepUnmatched = true;
ip.addParameter('volatilityperiod',13,@isnumeric);
ip.addParameter('tolerance',0.003,@isnumeric);
ip.parse(varargin{:});
inpbandsperiod = ip.Results.volatilityperiod;
change = ip.Results.tolerance;

jaw = smma(p,13,8);jaw = [nan(8,1);jaw];
teeth = smma(p,8,5);teeth = [nan(5,1);teeth];
lips = smma(p,5,3);lips = [nan(3,1);lips];
[idx,~,~,HH,LL] = fractalenhanced(p,nfractal,'volatilityperiod',inpbandsperiod,'tolerance',change);
[bs,ss,lvlup,lvldn,bc,sc] = tdsq(p(:,1:5));
outputmat = [m2xdate(p(:,1)),p(:,2:5),idx,HH,LL,jaw,teeth,lips,bs,ss,lvlup,lvldn,bc,sc];

if ~doplot;return,end

figure(1);
candle(p(:,3),p(:,4),p(:,5),p(:,2),[0.75,0.75,0.75]);hold on;
plot(jaw,'b');
plot(teeth,'r');
plot(lips,'g');
%
stairs(HH,'r--');
stairs(LL,'g--');
stairs(lvlup,'color',[0.75 0 0],'linewidth',1);
stairs(lvldn,'color',[0 0.75 0],'linewidth',1);

shift = 0.01;
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