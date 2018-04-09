function [] = demo(obj)
    variablenotused(obj);
    
    opt = cOption('m1805-C-3000');
    opt.dispinfo;
    
    try
        ds = cBloomberg;
        opt.init(ds);
        opt.dispinfo;
    catch e
        fprintf(e.message);
    end
    
    opt = cOption('m1805-P-3000');
    opt.dispinfo;
    opt.loadinfo('m1805-P-3000_info.txt');
    opt.dispinfo;
    
end

