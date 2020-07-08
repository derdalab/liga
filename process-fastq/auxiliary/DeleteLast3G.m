function [cAA] = DeleteLast3G(cAA, firstN)
% this function trims the firstN characters and last three G characters
% from the amino acid character array

DEBUG = 0;
% example of character aray that has variable lengths
if DEBUG
    cAA =  ['PEPTIDEGGG    ';
            'PEPTIGGG      ';
            'PDEGGG        ';
            'PEPTIDEGG     ';
            'EGGG          ';
            'GGG           ';
            'GG            ';
            'G             ';         
           ];
end

% step one, trim the firstN characters
if firstN
    cAA = cAA(:,firstN+1:end);
end
   
cAA = [cAA char(32*ones(size(cAA,1),1)) ];
[row, lastSpace] = find(cAA==' ');
[row,IX] = sort(row);
lastSpace = lastSpace(IX);

%find locations of the unique row numbers
[uRow,IX] = unique(row,'first');
uLastSpace = lastSpace(IX);

G3 = uLastSpace-1;
G2 = uLastSpace-2;
G1 = uLastSpace-3;

% correct any instances where G1-G3 become 0 or negative values
% it hsould be suggicient to check G1 only and fix G2 and G3
IX = find(G1<1);
G1(IX) = 1;

IX = find(G2<1);
G2(IX) = 1;

IX = find(G3<1);
G3(IX) = 1;
% the latter case will produce a blank string after trimming
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iG3 = sub2ind(size(cAA), [uRow uRow uRow], [G1 G2 G3]);

cAA(iG3) = ' ';

end