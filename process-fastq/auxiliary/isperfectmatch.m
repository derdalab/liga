function [Mismatch, Match] = isperfectmatch(F,R, k)
% this function takes one tile -N for forward of +N for reverse and returns
% 1 if row of the nucleotides had a perfect match and 0 if it was not

% definition of tile
% TILE = I-N-1;  % negative value: forward tile, positive: reverse tile


    if k<0
        %FR  = R(:, (-k+1):end) + F(:, 1:end+k);   % forward tiling
        FR  = R(:, (-k+1):end) + F(:, 1:end+k);   % forward tiling_Bifang
    elseif k>0      
        FR  = F(:, (k+1):end) + R(:, 1:end-k);   % reverse tiling
    else
        FR = F+R;  % no tiling
    end
    
    LFR = ~(FR); % make a logical zero array for matches
    nFR = LFR;   % make identical-sized logical zero array for mis-matches

    I = (FR==130 | FR==134 | FR==142 | FR==168);

    LFR(I)=1;
    nFR(FR>129 & FR<156 & ~LFR) = 1;
    
    Match = sum(LFR,2);
    Mismatch = sum(nFR,2);


end