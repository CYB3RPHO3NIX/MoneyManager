CREATE PROCEDURE [lookup].[usp_DeleteCategory]
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate Category exists
    IF NOT EXISTS (SELECT 1 FROM [lookup].[Categories] WHERE CategoryId = @CategoryId)
    BEGIN
        RAISERROR('Invalid CategoryId. Category does not exist.', 16, 1);
        RETURN;
    END

    -- Prevent delete if SubCategories exist
    IF EXISTS (SELECT 1 FROM [lookup].[SubCategories] WHERE CategoryId = @CategoryId)
    BEGIN
        RAISERROR('Cannot delete Category that has SubCategories.', 16, 1);
        RETURN;
    END

    DELETE FROM [lookup].[Categories]
    WHERE CategoryId = @CategoryId;

    SELECT @CategoryId AS DeletedCategoryId;
END
GO