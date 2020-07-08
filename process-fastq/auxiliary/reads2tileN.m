function [TILE,MATCH, MISMATCH] = reads2tileN(F, R)


N = size(F,2);
Match = -ones(size(F,1), 2*(N-1)+1);
Mismatch = -ones(size(F,1),  2*(N-1)+1);

for k=(-N+1):(N-1)
    if k<0
        FR  = R(:, -k+1:end) + F(:, 1:end+k);   % forward tiling
    elseif k>0      
        FR  = F(:, k+1:end) + R(:, 1:end-k);   % reverse tiling
    else
        FR = F+R;  % no tiling
    end
    
    LFR = ~(FR); % make a logical zero array for matches
    nFR = LFR;   % make identical-sized logical zero array for mis-matches

    I = (FR==130 | FR==134 | FR==142 | FR==168);

    LFR(I)=1;
    nFR(FR>129 & FR<156 & ~LFR) = 1;
    
    Match(:,k+N) = sum(LFR,2);
    Mismatch(:,k+N) = sum(nFR,2);
end

D=(Match-Mismatch);

%column number where D value is the largest in each row 
[~,I]=max(D,[],2);  

%linear indices of the same positions
IX = sub2ind(size(D), (1:size(D,1))', I); 
bias_range = repmat((-N+1):(N-1),size(F,1),1);
bias = bias_range(IX);

MATCH    = Match(IX);
MISMATCH = Mismatch(IX);

 
TILE = bias;  % negative value: forward tile, positive: reverse tile


end