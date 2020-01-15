function bucketsize = opt_getbucketsize(code_underlier,spot)
    if strcmpi(code_underlier(1:2),'SR')
        %°×ÌÇ
        if spot <= 3000
            bucketsize = 50;
        elseif spot > 3000 && spot <= 10000
            bucketsize = 100;
        else
            bucketsize = 200;
        end
    elseif strcmpi(code_underlier(1:2),'CF')
        %ÃÞ»¨
        if spot <= 10000
            bucketsize = 100;
        elseif spot > 10000 && spot <= 20000
            bucketsize = 200;
        else
            bucketsize = 400;
        end
    elseif strcmpi(code_underlier(1:2),'TA')
        %PTA
        if spot <= 5000
            bucket
        
    elseif strcmpi(code_underlier(1:2),'cu')
        bucketsize = 1000;
    elseif strcmpi(code_underlier(1:2),'ru')
        bucketsize = 250;
    elseif strcmpi(code_underlier(1),'m')
        bucketsize = 50;
    elseif strcmpi(code_underlier(1),'c') && ~strcmpi(code_underlier(1:2),'cu')
        bucketsize = 20;
    elseif strcmpi(code_underlier(1),'i') && ~strcmpi(code_underlier(1:2),'IF')
        bucketsize = 10;
    elseif strcmpi(code_underlier(1:2),'IF')
        bucketsize = 50;
    elseif strcmpi(code_underlier(1:2),'au')
        bucketsize = 4;
    else
        bucketsize = 20;
    end
end