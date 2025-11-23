CREATE PROCEDURE [lookup].[usp_AddCategory]
    @Name         VARCHAR(200),
    @Description  VARCHAR(500) = NULL,
    @CreatedBy    BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for duplicate Name
    IF EXISTS (SELECT 1 FROM [lookup].[Categories] WHERE Name = @Name)
    BEGIN
        RAISERROR('Category with this Name already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO [lookup].[Categories]
    (
        Name,
        Description,
        CreatedOn,
        CreatedBy
    )
    VALUES
    (
        @Name,
        @Description,
        GETDATE(),
        @CreatedBy
    );

    SELECT SCOPE_IDENTITY() AS NewCategoryId;
END
GO
