function md_ctp = ctpmdconnect
    try
        if ~exist('md_ctp','var'), md_ctp = cCTP.citic_kim_fut; end
        if ~md_ctp.isconnect, md_ctp.login; end

    catch e
        fprintf([e.message,'......\n']);
    end
end