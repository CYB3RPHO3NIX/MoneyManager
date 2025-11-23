CREATE PROCEDURE [lookup].[usp_DeleteAccountGroup]
    @AccountGroupId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Check if the account group exists
    -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [lookup].[AccountGroups] WHERE AccountGroupId = @AccountGroupId)
    BEGIN
        RAISERROR('Account Group not found.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Perform DELETE
    -------------------------------------------------------------------------
    DELETE FROM [lookup].[AccountGroups]
    WHERE AccountGroupId = @AccountGroupId;
END
GO
