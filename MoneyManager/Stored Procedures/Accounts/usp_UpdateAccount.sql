CREATE PROCEDURE [data].[usp_UpdateAccount]
    @AccountId BIGINT,                     -- Mandatory
    @UserId BIGINT = NULL,                 -- Optional
    @AccountGroupId BIGINT = NULL,         -- Optional
    @Name VARCHAR(200) = NULL,             -- Optional
    @Amount DECIMAL(18,2) = NULL,          -- Optional
    @Description VARCHAR(500) = NULL,      -- Optional
    @UpdatedBy BIGINT = NULL               -- Optional
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Validate existence
    -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [data].[Accounts] WHERE [AccountId] = @AccountId)
    BEGIN
        RAISERROR('Account not found.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Load existing values (needed for duplicate validation)
    -------------------------------------------------------------------------
    DECLARE 
        @CurrentUserId BIGINT,
        @CurrentAccountGroupId BIGINT,
        @CurrentName VARCHAR(200);

    SELECT 
        @CurrentUserId = UserId,
        @CurrentAccountGroupId = AccountGroupId,
        @CurrentName = Name
    FROM [data].[Accounts]
    WHERE AccountId = @AccountId;

    -------------------------------------------------------------------------
    -- Determine NEW values (for duplicate check)
    -------------------------------------------------------------------------
    DECLARE 
        @NewUserId BIGINT = COALESCE(@UserId, @CurrentUserId),
        @NewAccountGroupId BIGINT = COALESCE(@AccountGroupId, @CurrentAccountGroupId),
        @NewName VARCHAR(200) = COALESCE(@Name, @CurrentName);

    -------------------------------------------------------------------------
    -- Duplicate check: Name + UserId + AccountGroupId must be unique
    -------------------------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM [data].[Accounts]
        WHERE UserId = @NewUserId
          AND AccountGroupId = @NewAccountGroupId
          AND Name = @NewName
          AND AccountId <> @AccountId
    )
    BEGIN
        RAISERROR('Another account with the same Name already exists for this user and account group.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Perform update
    -------------------------------------------------------------------------
    UPDATE [data].[Accounts]
    SET
        [UserId]         = COALESCE(@UserId, [UserId]),
        [AccountGroupId] = COALESCE(@AccountGroupId, [AccountGroupId]),
        [Name]           = COALESCE(@Name, [Name]),
        [Amount]         = COALESCE(@Amount, [Amount]),
        [Description]    = COALESCE(@Description, [Description]),
        [UpdatedBy]      = @UpdatedBy,
        [UpdatedOn]      = GETDATE()
    WHERE
        [AccountId] = @AccountId;
END;
