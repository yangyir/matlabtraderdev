function [] = demo(~)
    mdefut_demo = cMDEFut;
    qms_demo = cQMS;
    qms_demo.setdatasource('local');
    mdefut_demo.qms_ = qms_demo;
    mdefut_demo.initreplayer('code','rb1810','fn','rb1810_20180502_tick.mat');
    %
    mdefut_demo.start;
    
    
%     fprintf('cMDEFut:demo finishes\n');

end