function total_mem = get_mem(obj) 
    %// Get all properties
    props = properties(obj); 

    total_mem = 0;
    %// Loop properties
    for ii=1:length(props)
        %// Make shallow copy
        curr_prop = obj.(props{ii});  %#ok<*NASGU>

        if isobject(curr_prop)

            total_mem = total_mem + get_mem(curr_prop);

        else    

            %// Get info struct for current property
            s = whos('curr_prop');
            %// Add to total memory consumption
            total_mem = total_mem + s.bytes; 

    end
end