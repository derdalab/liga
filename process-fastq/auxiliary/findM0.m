function [Matches] = findM0(Tags, M0tag, DISPLAY)


%%%% this is a faster way that searches for 'M' and characters after 'M'
    IX = find(Tags=='M'); 
    
    % To shift the linear index by 2 columns, add two column heights to it
    IX = IX + 2*size(Tags,1);
    % The index IX now points to the 2nd character after 'M' in each row
    
    IX2 = Tags(IX)=='0';
    [Matches,~]=ind2sub(size(Tags),IX(IX2)); % return the row index of M{0}
    

    if DISPLAY
        
        fprintf([num2str(size(Matches,1)) ' M{0} ' ...
                '(' num2str(toc,'%10.1f')   ' s); ']);
    end
end