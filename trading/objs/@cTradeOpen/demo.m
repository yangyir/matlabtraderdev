function [] = demo()
    code = 'ni1809';
    opentime = datenum('2018-07-24 09:00:01');
    direction = 1;
    volume = 1;...
    price = 109900;
    stoptime = gettradestoptime(code,opentime,3,72);
    
    tradedemo = cTradeOpen('code',code,...
        'opendatetime',opentime,...
        'opendirection',direction,...
        'openvolume',volume,...
        'openprice',price,...
        'stopdatetime',stoptime);
    
    wrinfo = struct('highesthigh',150000,'lowestlow',108000,'lengthofperiod',144);
    tradedemo.setsignalinfo('name','williamsr','extrainfo',wrinfo);
    %
    batmaninfo = struct('bandwidthmin',1/3,'bandwidthmax',0.5,'bandstoploss',0.01,'bandtarget',0.01);
    tradedemo.setriskmanager('name','batman','extrainfo',batmaninfo);
    
end