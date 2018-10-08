function[opensignal_highest,opensignal_outside_highest,opensignal_lowest,opensignal_outside_lowest] = fcn_gen_opensignal(candles)
% initalise all paras
% date| open |high |low |close |volume |oi
opensignal_highest=[];
opensignal_lowest =[];
mid_term_highest=[];
mid_term_lowest =[];
[short_term_signal,outsidecandle] = fcn_gen_shortcandle_flash(candles);
[l,nsignal]=size(short_term_signal);
[l,noutside]=size(outsidecandle);
short_term_candle = zeros(nsignal, 7);
for  i = 1: nsignal
    short_term_candle (i,1) = short_term_signal{i}.datenum;
    short_term_candle (i,2) = short_term_signal{i}.open;
    short_term_candle (i,3) = short_term_signal{i}.high;
    short_term_candle (i,4) = short_term_signal{i}.low;
    short_term_candle (i,5) = short_term_signal{i}.close;
    short_term_candle (i,6) = short_term_signal{i}.highorlow;
    short_term_candle (i,7) = short_term_signal{i}.targetdatenum;
end
if short_term_candle(1,6) ==1
    highest = short_term_candle(1:2:end,:);
    lowest = short_term_candle(2:2:end,:);
else
    highest = short_term_candle(2:2:end,:);
    lowest = short_term_candle(1:2:end,:);  
end
outside_candle = zeros(noutside,8);
n_high =0;
n_low = 0; 
for i =1:noutside
    outside_candle(i,1) = outsidecandle{i}.date;
    outside_candle(i,2) = outsidecandle{i}.open;
    outside_candle(i,3) = outsidecandle{i}.high;
    outside_candle(i,4) = outsidecandle{i}.low;
    outside_candle(i,5) = outsidecandle{i}.close;
    outside_candle(i,6) = outsidecandle{i}.highorlow;
    outside_candle(i,7) = outsidecandle{i}.targetprice;
    outside_candle(i,8) = outsidecandle{i}.stoploss;
    if outside_candle(i,6) ==1
        n_high = n_high+1;
        outside_high(n_high,:) =outside_candle(i,:);
        outside_high_datestr(n_high,:) =  datestr(outside_candle(i,1));
    elseif outside_candle(i,6) ==-1
        n_low = n_low+1;
        outside_low(n_low,:) =outside_candle(i,:);
        outside_low_datestr(n_low,:) =  datestr(outside_candle(i,1));
    end     
end 

% gen signal to short position with the short_term highest candles
% highest candles
% datenum| open |high |low |close |highorlow(1) |targetdatenum
[n_highest,l]= size(highest); 
s_highest_init = highest(1,3);
checkflag =1;
N_mid_highest = 0;
N_opensignal_highest = 0;
N_opensignal_outside_highest =0;
opensignal_outside_highest = [];
opensignal_outside_lowest = [];
for i =2:n_highest
    s_highest_mpv = highest(i,3);
    if checkflag ==1
        if s_highest_mpv <= s_highest_init
            s_highest_init = s_highest_mpv;
            checkflag =1;
        elseif s_highest_mpv > s_highest_init
            mid_highest = highest(i,:);
            checkflag = 2;
        end
    elseif checkflag ==2
        if s_highest_mpv == mid_highest(1,3)
            %do nothig and wait!!!
            checkflag = 2;
        elseif s_highest_mpv > mid_highest(1,3)
            mid_highest = highest(i,:);
            checkflag =2;
        elseif s_highest_mpv < mid_highest(1,3)  
            N_mid_highest =N_mid_highest+1;
            mid_term_highest{N_mid_highest} = struct('datenum',mid_highest(1,1),...
                'datestr',datestr(mid_highest(1,1)),...
                'open',mid_highest(1,2),...
                'high',mid_highest(1,3),...
                'low',mid_highest(1,4),...
                'close', mid_highest(1,5),...
                'highorlow',mid_highest(1,6),...
                'targetdatenum',mid_highest(1,7));
            N_opensignal_highest=N_opensignal_highest+1;
            opensignal_highest{N_opensignal_highest} = struct('opentimenum', highest(i,7),...  
                'opentimestr',datestr(highest(i,7)),...
                'target',highest(i,4),...
                'direction',-1*highest(i,6),...
                'N_position',1,...
                'outsideornot',0,...
                'open',highest(i,2),...
                'stoploss1',highest(i,3),...
                'stoploss2',mid_highest(1,3),...
                'openprice',nan,...
                'closetimenum',nan,...
                'closetimestr',nan,...
                'closeprice',nan,...
                'pnl',nan);
            %calculate the openprice
            if opensignal_highest{N_opensignal_highest}.open <opensignal_highest{N_opensignal_highest}.target
                opensignal_highest{N_opensignal_highest}.openprice = opensignal_highest{N_opensignal_highest}.open;
            elseif opensignal_highest{N_opensignal_highest}.open >= opensignal_highest{N_opensignal_highest}.target && opensignal_highest{N_opensignal_highest}.open <opensignal_highest{N_opensignal_highest}.stoploss1
                opensignal_highest{N_opensignal_highest}.openprice = opensignal_highest{N_opensignal_highest}.target;
            elseif opensignal_highest{N_opensignal_highest}.open>=opensignal_highest{N_opensignal_highest}.stoploss1
                opensignal_highest{N_opensignal_highest}=[];
                N_opensignal_highest=N_opensignal_highest-1;
            end
            out1= find(outside_high(:,1) >mid_term_highest{N_mid_highest}.targetdatenum);
            out2 = find(outside_high(:,1)<opensignal_highest{N_opensignal_highest}.opentimenum);
            out = intersect(out1,out2);
            [N_out,l] = size(out);
            if N_out ==0
                %do nothing
            elseif N_out >0
                for j =1:N_out
                    N_opensignal_outside_highest =N_opensignal_outside_highest+1;
                    opensignal_outside_highest{N_opensignal_outside_highest} = struct('opentimenum',outside_high(out(j,1),1),...
                    'opentimestr',datestr(outside_high(out(j,1),1)),...
                    'target',outside_high(out(j,1),7),...
                    'direction',-1*highest(i,6),...
                    'N_position',1,...
                    'outsideornot',1,...
                    'open',outside_high(out(j,1),2),...
                    'stoploss',outside_high(out(j,1),8),...
                    'openprice',nan,...
                    'closetimenum',nan,...
                    'closetimestr',nan,...
                    'closeprice',nan,...
                    'pnl',nan,...
                    'riskmanagement',nan);
                    %calculate the openprice
                    if opensignal_outside_highest{N_opensignal_outside_highest}.open <opensignal_outside_highest{N_opensignal_outside_highest}.target
                        opensignal_outside_highest{N_opensignal_outside_highest}.openprice = opensignal_outside_highest{N_opensignal_outside_highest}.open;
                    elseif opensignal_outside_highest{N_opensignal_outside_highest}.open >= opensignal_outside_highest{N_opensignal_outside_highest}.target && opensignal_outside_highest{N_opensignal_outside_highest}.open <opensignal_outside_highest{N_opensignal_outside_highest}.stoploss
                        opensignal_outside_highest{N_opensignal_outside_highest}.openprice = opensignal_outside_highest{N_opensignal_outside_highest}.target;
                    elseif opensignal_outside_highest{N_opensignal_outside_highest}.open>=opensignal_outside_highest{N_opensignal_outside_highest}.stoploss
                        opensignal_outside_highest{N_opensignal_outside_highest}=[];
                        N_opensignal_outside_highest=N_opensignal_outside_highest-1;
                    end
                 end
            end
            s_highest_init = highest(i,3);
            checkflag =1;
        end
    end
end


% gen signal to long position with the short_term lowest candles
% lowest candles
% datenum| open |high |low |close |highorlow(-1) |targetdatenum
[n_lowest,l]= size(lowest); 
s_lowest_init = lowest(1,4);
checkflag =3;
N_mid_lowest = 0;
N_opensignal_lowest = 0;
for i =2:n_lowest
    s_lowest_mpv = lowest(i,4);
    if checkflag ==3
        if s_lowest_mpv >= s_lowest_init
            s_lowest_init = s_lowest_mpv;
            checkflag =3;
        elseif s_lowest_mpv < s_lowest_init
            mid_lowest = lowest(i,:);
            checkflag = 4;
        end
    elseif checkflag ==4
        if s_lowest_mpv == mid_lowest(1,4)
            %do nothig and wait!!!
            checkflag = 4;
        elseif s_lowest_mpv < mid_lowest(1,4)
            mid_lowest = lowest(i,:);
            checkflag =4;
        elseif s_lowest_mpv > mid_lowest(1,4)  
            N_mid_lowest =N_mid_lowest+1;
            mid_term_lowest{N_mid_lowest} = struct('datenum',mid_lowest(1,1),...
                'datestr',datestr(mid_lowest(1,1)),...
                'open',mid_lowest(1,2),...
                'high',mid_lowest(1,3),...
                'low',mid_lowest(1,4),...
                'close', mid_lowest(1,5),...
                'highorlow',mid_lowest(1,6),...
                'targetdatenum',mid_lowest(1,7));
            N_opensignal_lowest=N_opensignal_lowest+1;
            opensignal_lowest{N_opensignal_lowest} = struct('opentimenum', lowest(i,7),...  
                'opentimestr',datestr(lowest(i,7)),...
                'target',lowest(i,3),...
                'direction',-1*lowest(i,6),...
                'N_position',1,...
                'outsideornot',0,...
                'open',lowest(i,2),...
                'stoploss1',lowest(i,4),...
                'stoploss2',mid_lowest(1,4),...
                'openprice',nan,...
                'closetimenum',nan,...
                'closetimestr',nan,...
                'closeprice',nan,...
                'pnl',nan);
            %calculate the openprice
            if opensignal_lowest{N_opensignal_lowest}.open >opensignal_lowest{N_opensignal_lowest}.target
                opensignal_lowest{N_opensignal_lowest}.openprice = opensignal_lowest{N_opensignal_lowest}.open;
            elseif opensignal_lowest{N_opensignal_lowest}.open <= opensignal_lowest{N_opensignal_lowest}.target && opensignal_lowest{N_opensignal_lowest}.open >opensignal_lowest{N_opensignal_lowest}.stoploss1
                opensignal_lowest{N_opensignal_lowest}.openprice = opensignal_lowest{N_opensignal_lowest}.target;
            elseif opensignal_lowest{N_opensignal_lowest}.open <= opensignal_lowest{N_opensignal_lowest}.stoploss1
                opensignal_lowest{N_opensignal_lowest}=[];
                N_opensignal_lowest=N_opensignal_lowest-1;
            end
            out3= find(outside_low(:,1) >mid_term_lowest{N_mid_lowest}.targetdatenum);
            out4 = find(outside_low(:,1)<opensignal_lowest{N_opensignal_lowest}.opentimenum);
            outt = intersect(out3,out4);
            [N_outt,l] = size(outt);
            if N_outt ==0
                %do nothing
            elseif N_outt >0
                for j =1:N_outt
                    N_opensignal_outside_lowest =N_opensignal_outside_lowest+1;
                    opensignal_outside_lowest{N_opensignal_outside_lowest} = struct('opentimenum',outside_low(outt(j,1),1),...
                    'opentimestr',datestr(outside_low(outt(j,1),1)),...
                    'target',outside_low(outt(j,1),7),...
                    'direction',-1*lowest(i,6),...
                    'N_position',1,...
                    'outsideornot',1,...
                    'open',outside_low(out(j,1),2),...
                    'stoploss',outside_low(out(j,1),8),...
                    'openprice',nan,...
                    'closetimenum',nan,...
                    'closetimestr',nan,...
                    'closeprice',nan,...
                    'pnl',nan,...
                    'riskmanagement',nan);
                     if opensignal_outside_lowest{N_opensignal_outside_lowest}.open >opensignal_outside_lowest{N_opensignal_outside_lowest}.target
                        opensignal_outside_lowest{N_opensignal_outside_lowest}.openprice = opensignal_outside_lowest{N_opensignal_outside_lowest}.open;
                    elseif opensignal_outside_lowest{N_opensignal_outside_lowest}.open <= opensignal_outside_lowest{N_opensignal_outside_lowest}.target && opensignal_outside_lowest{N_opensignal_outside_lowest}.open >opensignal_outside_lowest{N_opensignal_outside_lowest}.stoploss
                        opensignal_outside_lowest{N_opensignal_outside_lowest}.openprice = opensignal_outside_lowest{N_opensignal_outside_lowest}.target;
                    elseif opensignal_outside_lowest{N_opensignal_outside_lowest}.open<=opensignal_outside_lowest{N_opensignal_outside_lowest}.stoploss
                        opensignal_outside_lowest{N_opensignal_outside_lowest}=[];
                        N_opensignal_outside_lowest=N_opensignal_outside_lowest-1;
                    end
                end
            end
            s_lowest_init = lowest(i,4);
            checkflag =3;
        end
    end
end
end
        
    

    

        

    
    
            






        


    
            
        
        

    
    
            





