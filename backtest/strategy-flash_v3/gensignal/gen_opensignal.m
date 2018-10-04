clear
clc
%%
% initalise all paras
load('b_RBTK8_1d.mat');
% date| open |high |low |close |volume |oi
candles = f.data;
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
outside_candle = zeros(noutside,6);
n_high =0;
n_low = 0; 
for i =1:noutside
    outside_candle(i,1) = outsidecandle{i}.date;
    outside_candle(i,2) = outsidecandle{i}.open;
    outside_candle(i,3) = outsidecandle{i}.high;
    outside_candle(i,4) = outsidecandle{i}.low;
    outside_candle(i,5) = outsidecandle{i}.close;
    outside_candle(i,6) = outsidecandle{i}.highorlow;
    if outside_candle(i,6) ==1
        n_high = n_high+1;
        outside_high(n_high,:) =outside_candle(i,:);
    elseif outside_candle(i,6) ==-1
        n_low = n_low+1;
        outside_low(n_low,:) =outside_candle(i,:);
    end     
end 
%%
% gen signal to short position
[n_highest,l]= size(highest); 
for i =3:n_highest
    if highest(i-1,3) >highest(i-2,3)
        outside_high_num1 = find(outside_high(:,1) > highest(i,1));
        outside_high_num2 = find(outside_high(:,1) < highest(i,7));
    end
end
    
    

        

    
    
            






        


    
            
        
        

    
    
            





