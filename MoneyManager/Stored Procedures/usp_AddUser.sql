/***************************************************************
  Stored procedure: identity.usp_AddUser
  - Generates a random salt (32 bytes)
  - Hashes salt + password (SHA2_512)
  - Stores VARBINARY directly (no hex strings)
  - Prevents duplicate username/email
  - Returns new UserId using SELECT only
***************************************************************/
CREATE PROCEDURE [identity].[usp_AddUser]
(
    @Username        VARCHAR(100),
    @Email           VARCHAR(200),
    @Password        NVARCHAR(4000),
    @IsActive        BIT = 1,
    @CreatedBy       BIGINT = NULL,
    @CreatedOn       DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @CreatedOn IS NULL
        SET @CreatedOn = GETUTCDATE();

    BEGIN TRY
        BEGIN TRAN;

        -- Prevent duplicates
        IF EXISTS (
            SELECT 1
            FROM [identity].[Users] WITH (UPDLOCK, HOLDLOCK)
            WHERE Username = @Username OR Email = @Email
        )
        BEGIN
            ROLLBACK TRAN;
            RAISERROR('Username or Email already exists.', 16, 1);
            RETURN;
        END

        -- Generate salt (32 bytes)
        DECLARE @Salt VARBINARY(32) = CRYPT_GEN_RANDOM(32);

        -- Convert password to bytes
        DECLARE @PasswordBytes VARBINARY(MAX) = CONVERT(VARBINARY(MAX), @Password);

        -- Hash = SHA2_512(salt + password)
        DECLARE @Hash VARBINARY(64) = HASHBYTES('SHA2_512', @Salt + @PasswordBytes);

        -- Insert user
        INSERT INTO [identity].[Users]
        (
            Username,
            Email,
            PasswordHash,
            PasswordSalt,
            IsActive,
            CreatedBy,
            CreatedOn
        )
        VALUES
        (
            @Username,
            @Email,
            @Hash,
            @Salt,
            @IsActive,
            @CreatedBy,
            @CreatedOn
        );

        DECLARE @NewUserId BIGINT = SCOPE_IDENTITY();

        COMMIT TRAN;

        -- Return value only by SELECT
        SELECT @NewUserId AS UserId;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRAN;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('usp_AddUser failed: %s', 16, 1, @ErrMsg);
        THROW;
    END CATCH
END
GO
