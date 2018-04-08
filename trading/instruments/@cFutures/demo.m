function [] = demo(obj)
    variablenotused(obj);
    fut = cFutures('ni1805');
    fut.dispinfo;
    %
    try
        ds = cBloomberg;
        fut.init(ds);
        fut.dispinfo;
    catch e
        fprintf(e.message);
    end
    
    fut = cFutures('ni1809');
    fut.dispinfo;
    fut.loadinfo('ni1809_info.txt');
    fut.dispinfo;

end

