CREATE PROCEDURE [identity].[usp_UpdateUser]
    @UserId        BIGINT,               -- Mandatory

    @Username      VARCHAR(100) = NULL,  -- Optional
    @Email         VARCHAR(200) = NULL,  -- Optional
    @PasswordHash  VARCHAR(MAX) = NULL,  -- Optional (DO NOT send empty)
    @PasswordSalt  VARCHAR(MAX) = NULL,  -- Optional
    @IsActive      BIT          = NULL,  -- Optional

    @UpdatedBy     BIGINT       = NULL   -- Optional
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
    -- Validate Username if provided
    -------------------------------------------------------------------------
    IF @Username IS NOT NULL
    BEGIN
        IF LTRIM(RTRIM(@Username)) = ''
        BEGIN
            RAISERROR('Username cannot be empty.', 16, 1);
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM [identity].[Users]
            WHERE Username = @Username
              AND UserId <> @UserId
        )
        BEGIN
            RAISERROR('Username already exists. Choose a different one.', 16, 1);
            RETURN;
        END
    END

    -------------------------------------------------------------------------
    -- Validate Email if provided
    -------------------------------------------------------------------------
    IF @Email IS NOT NULL AND LTRIM(RTRIM(@Email)) = ''
    BEGIN
        RAISERROR('Email cannot be empty.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Security Check - If updating password, both hash and salt must be provided
    -------------------------------------------------------------------------
    IF (@PasswordHash IS NOT NULL AND @PasswordSalt IS NULL)
       OR (@PasswordSalt IS NOT NULL AND @PasswordHash IS NULL)
    BEGIN
        RAISERROR('PasswordHash and PasswordSalt must both be provided together.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Safe partial update using COALESCE
    -------------------------------------------------------------------------
    UPDATE [identity].[Users]
    SET
        Username      = COALESCE(@Username, Username),
        Email         = COALESCE(@Email, Email),
        PasswordHash  = COALESCE(@PasswordHash, PasswordHash),
        PasswordSalt  = COALESCE(@PasswordSalt, PasswordSalt),
        IsActive      = COALESCE(@IsActive, IsActive),

        UpdatedBy     = @UpdatedBy,
        UpdatedOn     = GETDATE()
    WHERE
        UserId = @UserId;
END
GO
