CREATE PROCEDURE dbo.usp_ExecuteXmlQuery
    @QueryXml XML
AS
BEGIN
    SET NOCOUNT ON;
        DECLARE @TableAttr SYSNAME = @QueryXml.value('(/root/@table)[1]', 'SYSNAME');
        IF @TableAttr IS NULL OR LTRIM(RTRIM(@TableAttr)) = ''
            RETURN; -- Table attribute missing (THROW removed)

        DECLARE @RawTable NVARCHAR(256) = REPLACE(REPLACE(@TableAttr, '[', ''), ']', '');
        DECLARE @Schema SYSNAME;
        DECLARE @Object SYSNAME;
        IF CHARINDEX('.', @RawTable) > 0
        BEGIN
            SET @Schema = PARSENAME(@RawTable, 2);
            SET @Object = PARSENAME(@RawTable, 1);
        END
        ELSE
        BEGIN
            SET @Schema = 'dbo';
            SET @Object = @RawTable;
        END

        IF @Schema IS NULL OR @Object IS NULL
            RETURN; -- Invalid table name

        DECLARE @ObjectId INT = OBJECT_ID(@Schema + '.' + @Object);
        IF @ObjectId IS NULL
            RETURN; -- Target table/view does not exist

                -- Preserve column order as specified in XML; remove DISTINCT to keep first occurrence order.
                DECLARE @Columns TABLE (Seq INT IDENTITY(1,1) PRIMARY KEY, ColumnName SYSNAME UNIQUE);
                INSERT INTO @Columns (ColumnName)
                SELECT LTRIM(RTRIM(c.value('text()[1]', 'SYSNAME')))
                FROM @QueryXml.nodes('/root/columns/column') AS T(c)
                WHERE LTRIM(RTRIM(c.value('text()[1]', 'SYSNAME'))) <> ''
                    AND NOT EXISTS (SELECT 1 FROM @Columns WHERE ColumnName = LTRIM(RTRIM(c.value('text()[1]', 'SYSNAME'))));

        IF NOT EXISTS (SELECT 1 FROM @Columns)
            RETURN; -- No columns specified

        IF EXISTS (
            SELECT 1
            FROM @Columns col
            WHERE NOT EXISTS (
                SELECT 1 FROM sys.columns sc WHERE sc.object_id = @ObjectId AND sc.name = col.ColumnName
            )
        )
            RETURN; -- Column not found

        DECLARE @SelectList NVARCHAR(MAX);
        SELECT @SelectList = STUFF((
            SELECT ',' + QUOTENAME(ColumnName)
            FROM @Columns
            ORDER BY Seq
            FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'),1,1,'');

        DECLARE @Conditions TABLE (
            ConditionId INT IDENTITY(1,1) PRIMARY KEY,
            ColumnName SYSNAME,
            Operator NVARCHAR(20),
            RawValue NVARCHAR(MAX)
        );
        INSERT INTO @Conditions (ColumnName, Operator, RawValue)
        SELECT 
            LTRIM(RTRIM(c.value('@column', 'SYSNAME'))),
            UPPER(LTRIM(RTRIM(c.value('@operator', 'NVARCHAR(20)')))),
            LTRIM(RTRIM(c.value('text()[1]', 'NVARCHAR(MAX)')))
        FROM @QueryXml.nodes('/root/conditions/condition') AS T(c)
        WHERE LTRIM(RTRIM(c.value('@column', 'SYSNAME'))) <> ''
          AND LTRIM(RTRIM(c.value('@operator', 'NVARCHAR(20)'))) <> '';

        DECLARE @Where NVARCHAR(MAX) = N'';
        DECLARE @i INT = 1;
        DECLARE @n INT = (SELECT COUNT(*) FROM @Conditions);
        WHILE @i <= @n
        BEGIN
            DECLARE @Col SYSNAME;
            DECLARE @Op NVARCHAR(20);
            DECLARE @Val NVARCHAR(MAX);
            SELECT @Col = ColumnName, @Op = Operator, @Val = RawValue FROM @Conditions WHERE ConditionId = @i;

            IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = @ObjectId AND name = @Col)
                BEGIN SET @i += 1; CONTINUE; END -- Skip invalid condition column

            IF @Op NOT IN ('=','!=','>','<','>=','<=','LIKE','IN','NOT IN')
                BEGIN SET @i += 1; CONTINUE; END -- Skip unsupported operator

            DECLARE @Expr NVARCHAR(MAX) = N'';

            IF @Op IN ('LIKE','IN','NOT IN') AND CHARINDEX('|', @Val) > 0
            BEGIN
                IF @Op = 'LIKE'
                BEGIN
                    DECLARE @OrParts NVARCHAR(MAX) = N'';
                    DECLARE @Vals TABLE(id INT IDENTITY(1,1), v NVARCHAR(MAX));
                    INSERT INTO @Vals(v)
                    SELECT value FROM string_split(@Val,'|') WHERE value <> '';
                    DECLARE @j INT = 1, @m INT = (SELECT COUNT(*) FROM @Vals);
                    WHILE @j <= @m
                    BEGIN
                        DECLARE @v NVARCHAR(MAX) = (SELECT v FROM @Vals WHERE id=@j);
                        IF @OrParts <> '' SET @OrParts += ' OR ';
                        SET @OrParts += '( ' + QUOTENAME(@Col) + ' LIKE ''%' + REPLACE(@v,'''','''''') + '%'' )';
                        SET @j += 1;
                    END
                    SET @Expr = '(' + @OrParts + ')';
                END
                ELSE IF @Op IN ('IN','NOT IN')
                BEGIN
                    DECLARE @InList NVARCHAR(MAX)='';
                    DECLARE @Vals2 TABLE(id INT IDENTITY(1,1), v NVARCHAR(MAX));
                    INSERT INTO @Vals2(v)
                    SELECT value FROM string_split(@Val,'|') WHERE value <> '';
                    DECLARE @k INT = 1, @p INT = (SELECT COUNT(*) FROM @Vals2);
                    WHILE @k <= @p
                    BEGIN
                        DECLARE @v2 NVARCHAR(MAX) = (SELECT v FROM @Vals2 WHERE id=@k);
                        IF @InList <> '' SET @InList += ',';
                        SET @InList += '''' + REPLACE(@v2,'''','''''') + '''';
                        SET @k += 1;
                    END
                    SET @Expr = QUOTENAME(@Col) + ' ' + @Op + ' (' + @InList + ')';
                END
            END
            ELSE IF @Op = 'LIKE'
            BEGIN
                SET @Expr = QUOTENAME(@Col) + ' LIKE ''%' + REPLACE(@Val,'''','''''') + '%''';
            END
            ELSE IF @Op IN ('IN','NOT IN')
            BEGIN
                DECLARE @SingleList NVARCHAR(MAX) = '''' + REPLACE(@Val,'''','''''') + '''';
                SET @Expr = QUOTENAME(@Col) + ' ' + @Op + ' (' + @SingleList + ')';
            END
            ELSE
            BEGIN
                DECLARE @Const NVARCHAR(MAX);
                IF @Val IS NULL OR @Val = ''
                    SET @Const = 'NULL';
                ELSE IF ISNUMERIC(@Val) = 1 AND @Val NOT LIKE '%e%' AND @Val NOT LIKE '%E%'
                    SET @Const = @Val;
                ELSE
                    SET @Const = '''' + REPLACE(@Val,'''','''''') + '''';

                IF @Op = '!=' SET @Op = '<>';
                SET @Expr = QUOTENAME(@Col) + ' ' + @Op + ' ' + @Const;
            END

            IF @Where = ''
                SET @Where = @Expr;
            ELSE
                SET @Where = @Where + ' AND ' + @Expr;

            SET @i += 1;
        END

        DECLARE @WhereClause NVARCHAR(MAX) = CASE WHEN @Where <> '' THEN ' WHERE ' + @Where ELSE '' END;

        DECLARE @SortCol SYSNAME = @QueryXml.value('(/root/sort/@column)[1]','SYSNAME');
        DECLARE @SortDir NVARCHAR(10) = @QueryXml.value('(/root/sort/@direction)[1]','NVARCHAR(10)');
        DECLARE @OrderBy NVARCHAR(MAX) = '';
        IF @SortCol IS NOT NULL AND @SortCol <> ''
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=@ObjectId AND name=@SortCol)
                SET @SortCol = NULL; -- Ignore invalid sort column
            SET @SortDir = LOWER(ISNULL(@SortDir,'ascending'));
            IF @SortDir NOT IN ('ascending','descending') SET @SortDir = 'ascending'; -- Default direction
            SET @OrderBy = ' ORDER BY ' + QUOTENAME(@SortCol) + CASE WHEN @SortDir='ascending' THEN ' ASC' ELSE ' DESC' END;
        END

        DECLARE @PageNumber INT = @QueryXml.value('(/root/page/@number)[1]','INT');
        DECLARE @PageSize INT = @QueryXml.value('(/root/page/@size)[1]','INT');
        DECLARE @Pagination NVARCHAR(MAX) = '';
        IF @PageNumber IS NOT NULL AND @PageSize IS NOT NULL
        BEGIN
            IF (@PageNumber < 1 OR @PageSize < 1) BEGIN SET @PageNumber = NULL; SET @PageSize = NULL; END -- Ignore invalid pagination
            IF @OrderBy = '' BEGIN SET @PageNumber = NULL; SET @PageSize = NULL; END -- Require ORDER BY; drop pagination if absent
            DECLARE @Offset BIGINT = (@PageNumber - 1) * @PageSize;
            SET @Pagination = ' OFFSET ' + CAST(@Offset AS NVARCHAR(20)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(20)) + ' ROWS ONLY';
        END

        -- Counts for metadata
        DECLARE @TotalRows INT = 0, @MatchingRows INT = 0;
        DECLARE @CountSql NVARCHAR(MAX) = 'SELECT @cnt = COUNT(*) FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Object);
        EXEC sp_executesql @CountSql, N'@cnt INT OUTPUT', @cnt=@TotalRows OUTPUT;

        DECLARE @MatchCountSql NVARCHAR(MAX) = 'SELECT @cnt = COUNT(*) FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Object) + ISNULL(@WhereClause,'');
        EXEC sp_executesql @MatchCountSql, N'@cnt INT OUTPUT', @cnt=@MatchingRows OUTPUT;

        -- Build JSON data via output variable (FOR JSON cannot be used in INSERT EXEC)
        DECLARE @DataJson NVARCHAR(MAX);
        DECLARE @JsonSql NVARCHAR(MAX) = N'SELECT @out = (SELECT ' + @SelectList + ' FROM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@Object) + @WhereClause + @OrderBy + @Pagination + ' FOR JSON PATH)';
        EXEC sp_executesql @JsonSql, N'@out NVARCHAR(MAX) OUTPUT', @out=@DataJson OUTPUT;
        IF @DataJson IS NULL SET @DataJson = '[]';

        SELECT 
            @TotalRows AS totalRows,
            @MatchingRows AS matchingRows,
            ISNULL(@PageSize, @MatchingRows) AS pageSize,
            ISNULL(@PageNumber, 1) AS currentPage,
            CASE WHEN ISNULL(@PageSize,0) > 0 THEN CEILING(@MatchingRows * 1.0 / @PageSize) ELSE 1 END AS totalPages,
            JSON_QUERY(@DataJson) AS data
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO
