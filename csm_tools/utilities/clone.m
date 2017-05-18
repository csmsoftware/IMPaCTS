function new = clone(obj)
% CLONE - Clone an object
%
% Usage:
%
%   new = clone( obj );
%
% Returns:
%
%   new : (obj) A new cloned object.
%
% Description:
%
%   Use this function to deep copy (clone) an object

%
% Copyright (C) Division of Computational and Systems Medicine, Imperial College London - 2016

% Author - Gordon Haggart 2016

    new = feval(class(obj)); % create new object of correct subclass.

    mobj = metaclass(obj);

    % Only copy properties which are
    % * not dependent or dependent and have a SetMethod
    % * not constant
    % * not abstract
    % * defined in this class or have public SetAccess - not
    % sure whether this restriction is necessary

    classMethods = methods( obj );

    sel = find(cellfun(@(cProp)(~cProp.Constant && ~cProp.Abstract && (~cProp.Dependent || (cProp.Dependent && ~isempty(cProp.SetMethod)))),mobj.Properties));

    for k = sel(:)'

        % If it's not public, find a set method.
        if ~ strcmp( mobj.Properties{k}.SetAccess, 'public' )

            setMethodFound = false;
            setMethod = '';

            for i = 1 : length (classMethods)

                % Check for case-insensitive set method.
                found = regexpi( classMethods{ i }, strcat( 'set', mobj.Properties{k}.Name ) );

                if ~ isempty( found )

                    setMethodFound = true;
                    setMethod = classMethods{ i };
                    break;

                end

            end

            if true( setMethodFound )

                eval( strcat( 'new.', setMethod, '(obj.', mobj.Properties{k}.Name, ');' ));

            else

                warning( [ 'Property ', mobj.Properties{k}.Name, ' unable to be set. Please implement set method for non-public properties. ' ]);

            end

        else

            % If its a container, just rewrite the container.
            if isa(obj.( mobj.Properties{k}.Name ),'containers.Map')

                new.( mobj.Properties{k}.Name ) = containers.Map;

                hashKeys = keys (obj.( mobj.Properties{k}.Name ));

                for i = 1 : length( hashKeys )

                    new.( mobj.Properties{k}.Name )( hashKeys{ i } ) = obj.( mobj.Properties{k}.Name )(hashKeys{ i });

                end

            % If its a handle AND NOT ZERO, loop back into this object copier
            elseif ishandle( obj.( mobj.Properties{k}.Name ) ) & (obj.( mobj.Properties{k}.Name ) ~= 0)

                new.( mobj.Properties{k}.Name ) = clone( obj.( mobj.Properties{k}.Name ) );


            % Else, just effing copy it.
            else

                new.(mobj.Properties{k}.Name) = obj.( mobj.Properties{k}.Name );

            end

        end

    end

end