function [] = demo(~)
    fprintf('create cReplayer instance myreplayer......\n');
    myreplayer = cReplayer;
    %
    fprintf('register myreplayer with rb1810 and ni1807......\n');
    myreplayer.registerinstrument('rb1810');
    myreplayer.registerinstrument('ni1807');
    %
    fprintf('init tick data for ni1807 from bloomberg......\n');
    myreplayer.inittickdata('code','ni1807','startdate','2018-05-02 09:00:00');
    %
    fprintf('load tick data for rb1810 from file......\n');
    myreplayer.loadtickdata('code','rb1810','fn','rb1810_20180502_tick.mat');
    %
    fprintf('save tick data......\n');
    n = myreplayer.instruments_.count;
    for i = 1:n
        fn = [myreplayer.instruments_.getinstrument{i}.code_ctp,'_20180502_tick.mat'];
        d = myreplayer.tickdata_{i};
        save(fn,'d');
    end
    fprintf('done with cReplayer:demo\n');

end