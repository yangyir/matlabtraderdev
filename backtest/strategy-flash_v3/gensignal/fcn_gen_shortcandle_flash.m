function [ short_term_signal,outsidecandle] = fcn_gen_shortcandle_flash(candles)
% initalise all paras
% load('b_RBTK8_1d.mat');
% date| open |high |low |close |volume |oi
% candles = f.data;
[ntradingdays,npara] = size(candles);
start = 1;
high_init = candles(start,3);
low_init = candles(start,4);
open_init = candles(start,2);
close_init = candles(start,5);
checkflag =2;
nsignal =0;
noutside =0;
% start to calculate signals
for i = start+1:ntradingdays
    high_mpv = candles(i,3);
    low_mpv = candles(i,4);
    open_mpv = candles(i,2);
    close_mpv = candles(i,5);
    date_mpv =candles(i,1);
    %module 2
    if checkflag ==2
        if high_mpv>high_init && low_mpv>=low_init
            highest_candle =[date_mpv, high_mpv, low_mpv,close_mpv,open_mpv];
            checkflag =3;
        elseif high_mpv <=high_init && low_mpv<low_init
            lowest_candle = [date_mpv, high_mpv,low_mpv,close_mpv,open_mpv];
            checkflag =4;
        elseif high_mpv <=high_init && low_mpv>=low_init
            checkflag =2;
            %do nothing and wait...
        elseif high_mpv >high_init && low_mpv<low_init
            high_init = high_mpv;
            low_init = low_mpv;
            close_init = close_mpv;
            open_init = open_mpv;
            checkflag =2;
        end
    %module 3  
    elseif checkflag ==3
        if high_mpv>highest_candle(1,2) && low_mpv>=highest_candle(1,3)
            highest_candle =[date_mpv, high_mpv, low_mpv,close_mpv,open_mpv];
            checkflag =3;
        elseif high_mpv>=highest_candle(1,2) && low_mpv<highest_candle(1,3)
            noutside = noutside +1;
            outsidecandle{noutside} = struct('date',date_mpv,...
                                             'high',high_mpv,...
                                             'low',low_mpv,...
                                             'open',open_mpv,...
                                             'close',close_mpv,...
                                             'highorlow',1,...
                                             'targetprice',highest_candle(1,3),...
                                             'stoploss',highest_candle(1,2));
            while (nsignal>0 && high_mpv >= short_term_signal{nsignal}.high && low_mpv <= short_term_signal{nsignal}.low)
                short_term_signal{nsignal} = [];
                nsignal = nsignal -1;
            end
            if nsignal ==0
                high_init = high_mpv;
                low_init = low_mpv;
                close_init = close_mpv;
                open_init = open_mpv;
                highest_candle = zeros(1,6);
                checkflag =2;
            elseif short_term_signal{nsignal}.highorlow ==1
                lowest_candle = [date_mpv, high_mpv, low_mpv,close_mpv,open_mpv];
                checkflag = 4;
            elseif short_term_signal{nsignal}.highorlow ==-1
                highest_candle = [date_mpv, high_mpv, low_mpv,close_mpv,open_mpv];
                checkflag = 3;
            end
        elseif high_mpv<=highest_candle(1,2) && low_mpv>=highest_candle(1,3)
            % do nothing and wait...
            checkflag =3;
        elseif high_mpv<highest_candle(1,2) && low_mpv<highest_candle(1,3)
            % the short-term highest signal has been calulated successed!
            nsignal =nsignal+1;
            short_term_signal{nsignal} = struct('nsignal',nsignal,...
                'highorlow',1,...
                'datenum',highest_candle(1,1),...
                'datestr',datestr(highest_candle(1,1)),...
                'high',highest_candle(1,2),...
                'low',highest_candle(1,3),...
                'close',highest_candle(1,4),...
                'open',highest_candle(1,5),...
                'targetdatenum',date_mpv,...
                'targetdatestr',datestr(date_mpv)); 
%             nsignal_high = nsignal_high +1; 
            lowest_candle = [date_mpv, high_mpv, low_mpv,close_mpv,open_mpv];
            checkflag =4;
        end
    elseif checkflag ==4
        if high_mpv<=lowest_candle(1,2) && low_mpv<lowest_candle(1,3)
            lowest_candle =[date_mpv, high_mpv, low_mpv,close_mpv,open_mpv];
            checkflag =4;
        elseif high_mpv>lowest_candle(1,2) && low_mpv<=lowest_candle(1,3)
            noutside = noutside +1;
            outsidecandle{noutside} = struct('date',date_mpv,...
                                             'high',high_mpv,...
                                             'low',low_mpv,...
                                             'open',open_mpv,...
                                             'close',close_mpv,...
                                             'highorlow',-1,...
                                             'targetprice',lowest_candle(1,2),...
                                             'stoploss',lowest_candle(1,3));
            while (nsignal>0 && high_mpv >= short_term_signal{nsignal}.high && low_mpv <= short_term_signal{nsignal}.low)
                short_term_signal{nsignal} = [];
                nsignal = nsignal -1;
            end
            if nsignal ==0
                high_init = high_mpv;
                low_init = low_mpv;
                close_init = close_mpv;
                open_init = open_mpv;
                lowest_candle = zeros(1,6);
                checkflag =2;
            elseif short_term_signal{nsignal}.highorlow ==1
                lowest_candle = [date_mpv, high_mpv, low_mpv,close_mpv,open_mpv];
                checkflag = 4;
            elseif short_term_signal{nsignal}.highorlow ==-1
                highest_candle = [date_mpv, high_mpv, low_mpv,close_mpv,open_mpv];
                checkflag = 3;
            end
        elseif high_mpv<=lowest_candle(1,2) && low_mpv>=lowest_candle(1,3)
            % do nothing and wait...
            checkflag =4;
        elseif high_mpv>lowest_candle(1,2) && low_mpv>lowest_candle(1,3)
            % the short-term lowest signal has been calulated successed!
            nsignal =nsignal+1;
            short_term_signal{nsignal} = struct('nsignal',nsignal,...
                'highorlow',-1,...
                'datenum',lowest_candle(1,1),...
                'datestr',datestr(lowest_candle(1,1)),...
                'high',lowest_candle(1,2),...
                'low',lowest_candle(1,3),...
                'close',lowest_candle(1,4),...
                'open',lowest_candle(1,5),...
                'targetdatenum',date_mpv,...
                'targetdatestr',datestr(date_mpv));
            highest_candle =[date_mpv, high_mpv, low_mpv,close_mpv,open_mpv];
            checkflag = 3;
        end
    end
end
% short_term_candle = zeros(nsignal, 7);
% for  i = 1: nsignal
%     short_term_candle (i,1) = short_term_signal{i}.datenum;
%     short_term_candle (i,2) = short_term_signal{i}.open;
%     short_term_candle (i,3) = short_term_signal{i}.high;
%     short_term_candle (i,4) = short_term_signal{i}.low;
%     short_term_candle (i,5) = short_term_signal{i}.close;
%     short_term_candle (i,6) = short_term_signal{i}.highorlow;
%     short_term_candle (i,7) = short_term_signal{i}.targetdatenum;
% end
% outside_candle = zeros(noutside,6);
% for i =1:noutside
%     outside_candle(i,1) = outsidecandle{i}.date;
%     outside_candle(i,2) = outsidecandle{i}.open;
%     outside_candle(i,3) = outsidecandle{i}.high;
%     outside_candle(i,4) = outsidecandle{i}.low;
%     outside_candle(i,5) = outsidecandle{i}.close;
%     outside_candle(i,6) = outsidecandle{i}.highorlow;
% end
end
          
        

    
    
            






        


    
            
        
        

    
    
            





