function [SeqOut] = ReplaceBlankByDash(NUC)
% identifid nucleotide could be a '' blank string, this functions converts
% all blanks to a string that contains one dash '-'

    spaces = char(32*ones(size(NUC)));  % matrix of spaces
    diff = sum( NUC - spaces, 2);       % subtract matrices. Add elements
    isblank = find(diff==0);            % find the line that yields diff=0
    NUC(isblank,1)='-';                 % modify the read in that line
    
    SeqOut = NUC;
end
