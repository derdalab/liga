function [uSeqLo, sumNum, Occur] = uniqueCOMB (SeqLo, NumLo)

[SeqLo,IX] = sort(SeqLo);  
NumLo     = NumLo(IX);   % sort both arrays
%clear IX;

[uSeqLo, M, ~] = unique (SeqLo, 'first');  
M2 = [M(2:end); numel(SeqLo)+1] ;          % M2 is the last element +1
Occur = M2-M; 
%clear M2;

% for truncated seqeunces that occured only once, 
% the frequencies are the same as those of the original seqeunces

I1 = find(Occur==1); % indices of sequences that occured once
% M(Il) are the indices of the sequences that occured only once in the
% original array SeqLo
% I1 are the indices of the sequences that occured once in the unique array

sumNum = nan(size(uSeqLo));
sumNum( I1 ) = NumLo( M(I1) );
%clear I1;

% if truncations were found more than once, the frequencies must be added

I2 = find(Occur>1);  
Nu = Occur(I2);   % ths number of times each sub-seqeunce was found

for iii = 1:numel(I2)
    temp = M(I2(iii));
    sumNum( I2(iii) ) = sum (NumLo( temp:temp+Nu(iii)-1 ) );
end

[sumNum, IX] = sort(sumNum, 'descend');
 uSeqLo = uSeqLo(IX);
 Occur  =  Occur(IX);

end