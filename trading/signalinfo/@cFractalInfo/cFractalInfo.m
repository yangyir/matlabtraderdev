classdef cFractalInfo < cSignalInfo
    properties
        type_@char = 'unset'
        mode_@char = 'unset'
        nfractal_@double
        hh_@double
        ll_@double
        hh1_@double
        ll1_@double
    end
    
    methods
        function obj = cFractalInfo
            obj.name_ = 'fractal';
        end
        
        function [] = set.type_(obj,val)
            if strcmpi(val,'unset') || ...
                    strcmpi(val,'breachup-B') || ...
                    strcmpi(val,'reverse-B') || ...
                    strcmpi(val,'breachdn-S') || ...
                    strcmpi(val,'reverse-S')
                obj.type_ = val;
            else
                error('cFractalInfo:invalid type input')
            end 
        end
        %
        function [] = set.mode_(obj,val)
            if strcmpi(val,'unset') || ...
                    strcmpi(val,'breachup-lvlup') || ...
                    strcmpi(val,'breachup-lvldn') || ...
                    strcmpi(val,'breachdn-lvldn') || ...
                    strcmpi(val,'breachdn-lvlup') || ...
                    strcmpi(val,'breachup-highsc13') || ...
                    strcmpi(val,'breachup-highsc13-negative') || ...
                    strcmpi(val,'breachdn-highbc13') || ...
                    strcmpi(val,'breachdn-highbc13-positive') || ...
                    strcmpi(val,'breachup-sshighvalue') || ...
                    strcmpi(val,'breachdn-bshighvalue') || ...
                    strcmpi(val,'mediumbreach-trendconfirmed') || ...
                    strcmpi(val,'mediumbreach-sshighvalue') || ...
                    strcmpi(val,'mediumbreach-bshighvalue') || ...
                    strcmpi(val,'mediumbreach-trendbreak') || ...
                    strcmpi(val,'mediumbreach-trendbreak-s1') || ...
                    strcmpi(val,'mediumbreach-trendbreak-s2') || ...
                    strcmpi(val,'mediumbreach-trendbreak-s3') || ...
                    strcmpi(val,'mediumbreach-trendbreak-bslowbreach') || ...
                    strcmpi(val,'mediumbreach-trendbreak-sslowbreach') || ...
                    strcmpi(val,'strongbreach-trendconfirmed') || ...
                    strcmpi(val,'strongbreach-trendbreak') || ...
                    strcmpi(val,'strongbreach-trendbreak-s1') || ...
                    strcmpi(val,'strongbreach-trendbreak-s2') || ...
                    strcmpi(val,'strongbreach-trendbreak-s3') || ...
                    strcmpi(val,'strongbreach-trendbreak-bslowbreach') || ...
                    strcmpi(val,'strongbreach-trendbreak-sslowbreach') || ...
                    strcmpi(val,'volblowup') || ...
                    strcmpi(val,'volblowup-alligatorfailed') || ...
                    strcmpi(val,'volblowup-trendbreak') || ...
                    strcmpi(val,'volblowup-s1') || ...
                    strcmpi(val,'volblowup-s2') || ...
                    strcmpi(val,'volblowup-s3') || ...
                    strcmpi(val,'volblowup-bcreverse') || ...
                    strcmpi(val,'volblowup-bsreverse') || ...
                    strcmpi(val,'volblowup-bsbcdoublereverse') || ...
                    strcmpi(val,'volblowup-screverse') || ...
                    strcmpi(val,'volblowup-ssreverse') || ...
                    strcmpi(val,'volblowup-ssscdoublereverse') || ...
                    strcmpi(val,'volblowup2') || ...
                    strcmpi(val,'volblowup2-alligatorfailed') || ...
                    strcmpi(val,'volblowup2-trendbreak') || ...
                    strcmpi(val,'volblowup2-s1') || ...
                    strcmpi(val,'volblowup2-s2') || ...
                    strcmpi(val,'volblowup2-s3') || ...
                    strcmpi(val,'volblowup2-bcreverse') || ...
                    strcmpi(val,'volblowup2-bsreverse') || ...
                    strcmpi(val,'volblowup2-bsbcdoublereverse') || ...
                    strcmpi(val,'volblowup2-screverse') || ...
                    strcmpi(val,'volblowup2-ssreverse') || ...
                    strcmpi(val,'volblowup2-ssscdoublereverse') || ...
                    strcmpi(val,'close2lvlup') || ...
                    strcmpi(val,'close2lvldn') || ...
                    strcmpi(val,'closetolvlup') || ...
                    strcmpi(val,'closetolvldn') || ...
                    strcmpi(val,'conditional-uptrendconfirmed') || ...
                    strcmpi(val,'conditional-uptrendconfirmed-1') || ...
                    strcmpi(val,'conditional-uptrendconfirmed-2') || ...
                    strcmpi(val,'conditional-uptrendconfirmed-3') || ...
                    strcmpi(val,'conditional-dntrendconfirmed') || ...
                    strcmpi(val,'conditional-dntrendconfirmed-1') || ...
                    strcmpi(val,'conditional-dntrendconfirmed-2') || ...
                    strcmpi(val,'conditional-dntrendconfirmed-3') || ...
                    strcmpi(val,'conditional-uptrendbreak') || ...
                    strcmpi(val,'conditional-dntrendbreak') || ...
                    strcmpi(val,'conditional-close2lvlup') || ...
                    strcmpi(val,'conditional-close2lvldn') || ...
                    strcmpi(val,'conditional-breachuplvlup') || ...
                    strcmpi(val,'conditional-breachdnlvldn')
                obj.mode_ = val;
            else
                error('cFractalInfo:invalid mode input')
            end     
        end
        
    end
end