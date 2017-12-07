function [] = demo(~)
    port = cPortfolio;
    fut = cFutures('m1805');
    fut.loadinfo('m1805_info.txt');
    px = 2916;
    volume = -10;
    port.addposition(fut,px,volume);
    port.print;
    %
    px = 2920;
    volume = -5;
    port.addposition(fut,px,volume);
    port.print;
    %
    px_settle = 2910;
    volume = -15;
    port.overrideposition(fut,px_settle,volume);
    port.print;
    %
    t = cTransaction;
    t.instrument_ = fut;
    t.price_ = 2905;
    t.volume_ = 15;
    t.direction_ = 1;
    t.offset_ = 1;
    t.datetime1_ = now;
    %pnl = -15*(2905-2910)*10=750
    pnl = port.updateportfolio(t);
    fprintf('pnl:%4.2f\n',pnl);
    
    port.removeposition(fut);
    port.print;
end