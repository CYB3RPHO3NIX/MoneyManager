CREATE PROCEDURE [lookup].[usp_UpdateSubCategory]
    @SubCategoryId INT,                   -- Mandatory

    @CategoryId    INT           = NULL,  -- Optional
    @Name          VARCHAR(200)  = NULL,  -- Optional
    @Description   VARCHAR(500)  = NULL,  -- Optional

    @ModifiedBy    BIGINT        = NULL   -- Optional
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Check if subcategory exists
    -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [lookup].[SubCategories] WHERE SubCategoryId = @SubCategoryId)
    BEGIN
        RAISERROR('SubCategory not found.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Validate CategoryId only if provided
    -------------------------------------------------------------------------
    IF @CategoryId IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM [lookup].[Categories] WHERE CategoryId = @CategoryId)
    BEGIN
        RAISERROR('Invalid CategoryId. Category does not exist.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Validate Name if provided
    -------------------------------------------------------------------------
    IF @Name IS NOT NULL
    BEGIN
        IF LTRIM(RTRIM(@Name)) = ''
        BEGIN
            RAISERROR('Name cannot be empty.', 16, 1);
            RETURN;
        END

        -- Must be unique among other subcategories
        IF EXISTS (
            SELECT 1
            FROM [lookup].[SubCategories]
            WHERE Name = @Name
              AND SubCategoryId <> @SubCategoryId
        )
        BEGIN
            RAISERROR('SubCategory with the same Name already exists.', 16, 1);
            RETURN;
        END
    END

    -------------------------------------------------------------------------
    -- Safe COALESCE-based partial update
    -------------------------------------------------------------------------
    UPDATE [lookup].[SubCategories]
    SET
        CategoryId  = COALESCE(@CategoryId, CategoryId),
        Name        = COALESCE(@Name, Name),
        Description = COALESCE(@Description, Description),

        ModifiedBy  = @ModifiedBy,
        ModifiedOn  = GETDATE()
    WHERE
        SubCategoryId = @SubCategoryId;
END
GO
