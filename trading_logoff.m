if exist('c_kim','var')
    try
        c_kim.logout;
    catch e
        fprintf([e.message,'\n']);
    end
end

if exist('c_ly','var')
    try
        c_ly.logout;
    catch e
        fprintf([e.message,'\n']);
    end
end

if exist('md_ctp','var')
    try
        md_ctp.logoff;
    catch e
        fprintf([e.message,'\n']);
    end 
end

fprintf('trading logoff finished\n');
        
        