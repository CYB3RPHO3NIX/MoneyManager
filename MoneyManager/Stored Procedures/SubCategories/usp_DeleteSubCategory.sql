CREATE PROCEDURE [lookup].[usp_DeleteSubCategory]
    @SubCategoryId INT
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
    -- Perform DELETE
    -------------------------------------------------------------------------
    DELETE FROM [lookup].[SubCategories]
    WHERE SubCategoryId = @SubCategoryId;
END
GO
