CREATE PROCEDURE [lookup].[usp_AddSubCategory]
    @CategoryId    INT,
    @Name          VARCHAR(200),
    @Description   VARCHAR(500) = NULL,
    @CreatedBy     BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if Category exists
    IF NOT EXISTS (
        SELECT 1 FROM [lookup].[Categories]
        WHERE CategoryId = @CategoryId
    )
    BEGIN
        RAISERROR('Invalid CategoryId. Category does not exist.', 16, 1);
        RETURN;
    END

    -- Check for duplicate SubCategory Name
    IF EXISTS (
        SELECT 1 FROM [lookup].[SubCategories]
        WHERE Name = @Name
    )
    BEGIN
        RAISERROR('SubCategory with this Name already exists.', 16, 1);
        RETURN;
    END

    -- Insert new subcategory
    INSERT INTO [lookup].[SubCategories]
    (
        CategoryId,
        Name,
        Description,
        CreatedOn,
        CreatedBy
    )
    VALUES
    (
        @CategoryId,
        @Name,
        @Description,
        GETDATE(),
        @CreatedBy
    );

    SELECT SCOPE_IDENTITY() AS NewSubCategoryId;
END
GO
