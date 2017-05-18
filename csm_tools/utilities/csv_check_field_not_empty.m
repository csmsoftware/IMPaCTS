function csv_check_field_not_empty( csv_name, row_number, field_name, field_value )

    if strcmp( field_value, '' )

        error( 'Data error in %s CSV. Field %s in Row %d is empty', csv_name, field_name, row_number );

    end

end
