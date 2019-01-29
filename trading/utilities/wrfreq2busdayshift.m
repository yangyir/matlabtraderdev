function nbshift = wrfreq2busdayshift(freq)
%note:function to compute the number of business days shift (backward)
%given sample freq (in minutes) in WR strategy
    if freq == 1
        nbshift = 1;
    elseif freq == 3
        nbshift = 3;
    elseif freq == 5
        nbshift = 5;
    elseif freq == 15
        nbshift = 10;
    else
        error('wrfreq2busdayshift:invalid freq input')
    end
end