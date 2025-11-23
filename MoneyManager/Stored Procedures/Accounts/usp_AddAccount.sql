CREATE PROCEDURE [data].[usp_AddAccount]
    @UserId BIGINT,
    @AccountGroupId BIGINT,
    @Name VARCHAR(200),
    @Amount DECIMAL(18,2) = 0.00,
    @Description VARCHAR(500) = NULL,
    @CreatedBy BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for duplicate account name for the same user and group
    IF EXISTS (
        SELECT 1
        FROM [data].[Accounts]
        WHERE [UserId] = @UserId
          AND [AccountGroupId] = @AccountGroupId
          AND [Name] = @Name
    )
    BEGIN
        RAISERROR('An account with the same name already exists for this user and account group.', 16, 1);
        RETURN;
    END

    -- Insert new account
    INSERT INTO [data].[Accounts] (
        [UserId],
        [AccountGroupId],
        [Name],
        [Amount],
        [Description],
        [CreatedBy],
        [CreatedOn]
    )
    VALUES (
        @UserId,
        @AccountGroupId,
        @Name,
        @Amount,
        @Description,
        @CreatedBy,
        GETDATE()
    );
END;
