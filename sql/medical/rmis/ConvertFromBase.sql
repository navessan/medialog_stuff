CREATE FUNCTION ConvertFromBase
(
    @value AS VARCHAR(MAX),
    @base AS BIGINT
) RETURNS BIGINT AS BEGIN

    -- just some variables
    DECLARE @characters CHAR(36),
            @result BIGINT,
            @index SMALLINT;

    -- initialize our charater set, our result, and the index
    SELECT @characters = '0123456789abcdefghijklmnopqrstuvwxyz',
           @result = 0,
           @index = 0;

    -- make sure we can make the base conversion.  there can't
    -- be a base 1, but you could support greater than base 36
    -- if you add characters to the @charater string
    IF @base < 2 OR @base > 36 RETURN NULL;

    -- while we have characters to convert, convert them and
    -- prepend them to the result.  we start on the far right
    -- and move to the left until we run out of digits.  the
    -- conversion is the standard (base ^ index) * digit
 WHILE @index < LEN(@value)
        SELECT @result = @result + POWER(@base, @index) * 
                         (CHARINDEX
                            (SUBSTRING(@value, LEN(@value) - @index, 1)
                            , @characters) - 1
                         ),
               @index = @index + 1;

    -- return the result
    RETURN @result;

END