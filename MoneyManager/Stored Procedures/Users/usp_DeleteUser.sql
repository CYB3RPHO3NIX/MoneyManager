CREATE PROCEDURE [identity].[usp_DeleteUser]
    @UserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Check if user exists
    -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [identity].[Users] WHERE UserId = @UserId)
    BEGIN
        RAISERROR('User not found.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Perform DELETE
    -------------------------------------------------------------------------
    DELETE FROM [identity].[Users]
    WHERE UserId = @UserId;
END
GO
