N = size(output2use,1);
p = output2use(:,1:5);
HH = output2use(:,7);LL = output2use(:,8);
jaw = output2use(:,9);teeth = output2use(:,10);lips = output2use(:,11);
bs = output2use(:,12);ss = output2use(:,13);
lvlup = output2use(:,14);lvldn = output2use(:,15);
bc = output2use(:,16);sc = output2use(:,17);
%%
validBreachupHH = (p(1:end-1,5)<HH(1:end-1)&p(2:end,5)>HH(1:end-1)) &...    %conditon1:price breach up for the 1st time
    HH(1:end-1) > teeth(1:end-1) & ...                                      %the high fractal is above the alligator's teetch
    HH(1:end-1) == HH(2:end) & ...                                          %the high fractal does't jump    
    teeth(1:end-1)>jaw(1:end-1);                                            %alligator's teeth is above alligator's jaw
validBreachupHH = [0;validBreachupHH];
idxBuy1 = find(validBreachupHH==1);
nBuy1 = length(idxBuy1);
% exclude sell countdown = 13
for i = 1:nBuy1
    j = idxBuy1(i);
    if j == 0, continue;end
    if sc(j) == 13,idxBuy1(i) = 0;end
end
%todo:exlude breachups just after TD Sell Setups?is it NECESSARY?
idxBuy1 = idxBuy1(idxBuy1>0);
nBuy1 = length(idxBuy1);
idxBuy1Stop = [min(idxBuy1+1,N),zeros(nBuy1,1)];
%%
% for i = 1:nBuy1
%     j = idxBuy1(i);
%     upper = HH(j);
%     lower = LL(j);
%     distance = 0.382*(upper-lower);
%     stoploss = p(j,5) - distance;
%     maxpnl = 0;
%     tdhigh = NaN;tdlow = NaN;
%     popen = p(j,5);
%     for k = j+1:N
%         if HH(k) ~= upper && LL(k) ~= lower && p(k,5)>HH(k-1) && HH(k-1) == HH(k)
%             %update the stoploss if necessary
%             distance = 0.382*(HH(k)-LL(k));
%             stoploss = p(k,5) - distance;
%         end
%         pnl = p(k,5)-popen;
%         if p(k,3)-p(j,5) > maxpnl, maxpnl = p(k,3)-p(j,5);end
%         %1.stop the trade if price fall below lips
%         if p(k,5) < lips(k),idxBuy1Stop(i,1) = k;idxBuy1Stop(i,2) = 1;break;end
%         %2.stop the trade if price breach stoploss
%         if p(k,5) < stoploss,idxBuy1Stop(i,1)=k;idxBuy1Stop(i,2) = 2;break;end        
%         %3.stop the trade if it fails to breach tdst-lvlup
%         %i.e.the high price fell below lvlup
%         if p(k-1,5)>lvlup(k-1) && p(k,3)<lvlup(k-1),idxBuy1Stop(i,1)=k;idxBuy1Stop(i,2) = 3;break;end
%         %4.if it finishes TD Sell Sequential, then stop the trade onces it
%         %falls below the low of the bar with the true high
%         if ss(k) >= 9 && isnan(tdhigh) && isnan(tdlow)
%             tdhigh = max(p(k-8:k,3));
%             tdidx = find(p(k-8:k,3) == tdhigh,1,'last')+k-9;
%             tdlow = p(tdidx,4);
%         end
%         if ~isnan(tdhigh) && ss(k) > 9
%             if p(k,3) > tdhigh
%                 tdidx = k;
%                 tdhigh = p(tdidx,3);
%                 tdlow = p(tdidx,4);
%             end
%         end
%         if p(k,5) < tdlow && ~isnan(tdlow) && maxpnl>0.2*(upper-lower)    %only do this if the pnl is already big enough
%             idxBuy1Stop(i,1)=k;
%             idxBuy1Stop(i,2) = 4;
%             break
%         end
%         %if the pnl is greater than the range,update the open price
%         if pnl > (upper - lower)
% %             idxBuy1Stop(i,1)=k;
% %             idxBuy1Stop(i,2) = 5;
% %             break
%             popen = popen + distance;
%         end
%     end
% end
% res = [idxBuy1,idxBuy1Stop,p(idxBuy1Stop(:,1),5)-p(idxBuy1,5)];
% open res
% sum(res(:,end))
% figure(2);plot(cumsum(res(:,end)));
tempscript_buy1;
%%
% trade = cTradeOpen('id',1,'code','SSE50 Index','opendatetime',today,...
%     'opendirection',1,'openvolume',1,'openprice',2700)