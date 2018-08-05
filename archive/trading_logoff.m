if exist('c_kim','var')
    try
        c_kim.logout;
        clear c_kim;
    catch e
        fprintf([e.message,'\n']);
    end
end

if exist('c_ly','var')
    try
        c_ly.logout;
        clear c_ly;
    catch e
        fprintf([e.message,'\n']);
    end
end

if exist('md_ctp','var')
    try
        md_ctp.logoff;
        clear md_ctp;
    catch e
        fprintf([e.message,'\n']);
    end 
end

if exist('qms_bbg','var'), clear qms_bbg; end
if exist('qms_local','var'), clear qms_local; end
if exist('qms_fut','var'), clear qms_fut; end
if exist('qms_fut_govtbond','var'), clear qms_fut_govtbond; end
if exist('qms_opt_m','var'), clear qms_opt_m; end
if exist('qms_opt_sr','var'), clear qms_opt_sr; end

fprintf('trading logoff finished\n');
        
        