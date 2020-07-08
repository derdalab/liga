function [N] = bar2numer(AllFB, direction, B)

    if isempty(AllFB)
        N=[];
        return;
    else
        N=zeros(size(AllFB,1),1);
    end
    
    if direction == 1
        barcodes = B.FB;
    elseif direction == -1
        barcodes = B.RB; 
    end

    for i=1:numel(barcodes)

        b = barcodes{i}; 

        % numeric search is the fastest; faster then regexp
        IX=find(AllFB(:,1)==b(1) &...
                AllFB(:,2)==b(2) &...
                AllFB(:,3)==b(3) &...
                AllFB(:,4)==b(4));

        S  = numel(find(IX));
        if S
            N(IX)=i;
        end     
    end
end