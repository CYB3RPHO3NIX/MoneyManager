CREATE PROCEDURE [lookup].[usp_UpdateCategory]
    @CategoryId   INT,
    @Name         VARCHAR(200) = NULL,
    @Description  VARCHAR(500) = NULL,
    @ModifiedBy   BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate Category exists
    IF NOT EXISTS (SELECT 1 FROM [lookup].[Categories] WHERE CategoryId = @CategoryId)
    BEGIN
        RAISERROR('Invalid CategoryId. Category does not exist.', 16, 1);
        RETURN;
    END

    -- Validate duplicate Name (if supplied)
    IF @Name IS NOT NULL AND EXISTS (
        SELECT 1 FROM [lookup].[Categories]
        WHERE Name = @Name AND CategoryId <> @CategoryId
    )
    BEGIN
        RAISERROR('Another Category with this Name already exists.', 16, 1);
        RETURN;
    END

    -- Perform update (only provided columns)
    UPDATE [lookup].[Categories]
    SET 
        Name        = COALESCE(@Name, Name),
        Description = COALESCE(@Description, Description),
        ModifiedOn  = GETDATE(),
        ModifiedBy  = @ModifiedBy
    WHERE CategoryId = @CategoryId;

    -- Return updated record
    SELECT CategoryId, Name, Description, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy
    FROM [lookup].[Categories]
    WHERE CategoryId = @CategoryId;
END
GO