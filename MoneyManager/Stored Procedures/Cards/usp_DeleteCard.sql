CREATE PROCEDURE [data].[usp_DeleteCard]
    @CardId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Check if card exists
    -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [data].[Cards] WHERE CardId = @CardId)
    BEGIN
        RAISERROR('Card not found.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Perform delete
    -------------------------------------------------------------------------
    DELETE FROM [data].[Cards]
    WHERE CardId = @CardId;
END
GO
