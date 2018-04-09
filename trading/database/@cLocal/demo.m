function [] = demo(obj)
    
    instrument = cFutures('T1712');
    instrument.loadinfo('T1712_info.txt');

    timestr = '2017-09-11 15:55:00';

    fprintf('calling realtime function......\n');
    data = obj.realtime(instrument,timestr);
    fprintf('time:%s; last:%4.3f\n',datestr(data.time),data.last_trade);
    %
    fprintf('calling history function......\n');
    data = obj.history(instrument,'last_trade','2017-10-01','2017-10-30');
    fprintf('%d observation found\n',size(data,1));
    fprintf('last price on %s:%4.3f\n',datestr(data(end,1)),data(end,end));

end


