CREATE PROCEDURE [data].[usp_DeleteAccount]
    @AccountId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Check if account exists
    -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [data].[Accounts] WHERE AccountId = @AccountId)
    BEGIN
        RAISERROR('Account not found.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Perform DELETE
    -------------------------------------------------------------------------
    DELETE FROM [data].[Accounts]
    WHERE AccountId = @AccountId;
END
GO
