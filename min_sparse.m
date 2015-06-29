%% Finds the minimum of a sparse 1D array ,when you don't want to include 0 
function [min_val,min_idx] = min_sparse(arr)


min_idx =1;
min_val =inf;

for i=1:length(arr)
    if arr(i)~=0 && arr(i)<min_val
        min_idx=i;
        min_val = arr(i);
    end
end

end