CREATE PROCEDURE [lookup].[usp_UpdateAccountGroup]
    @AccountGroupId BIGINT,                -- Mandatory

    @GroupName      VARCHAR(100) = NULL,   -- Optional
    @Description    VARCHAR(500) = NULL,   -- Optional

    @UpdatedBy      BIGINT = NULL          -- Optional
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
    -- Validate GroupName only if provided
    -------------------------------------------------------------------------
    IF @GroupName IS NOT NULL
    BEGIN
        -- Cannot be empty
        IF LTRIM(RTRIM(@GroupName)) = ''
        BEGIN
            RAISERROR('GroupName cannot be empty.', 16, 1);
            RETURN;
        END

        -- Must be unique
        IF EXISTS (
            SELECT 1 
            FROM [lookup].[AccountGroups] 
            WHERE GroupName = @GroupName
              AND AccountGroupId <> @AccountGroupId
        )
        BEGIN
            RAISERROR('GroupName already exists.', 16, 1);
            RETURN;
        END
    END

    -------------------------------------------------------------------------
    -- Safe partial update using COALESCE
    -------------------------------------------------------------------------
    UPDATE [lookup].[AccountGroups]
    SET
        GroupName   = COALESCE(@GroupName, GroupName),
        Description = COALESCE(@Description, Description),

        UpdatedBy   = @UpdatedBy,
        UpdatedOn   = GETDATE()
    WHERE
        AccountGroupId = @AccountGroupId;
END
GO
