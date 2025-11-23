CREATE PROCEDURE [lookup].[usp_AddAccountGroup]
    @GroupName     VARCHAR(100),
    @Description   VARCHAR(500) = NULL,
    @CreatedBy     BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if GroupName already exists
    IF EXISTS (
        SELECT 1
        FROM [lookup].[AccountGroups]
        WHERE GroupName = @GroupName
    )
    BEGIN
        RAISERROR('Account Group with this GroupName already exists.', 16, 1);
        RETURN;
    END

    -- Insert new record
    INSERT INTO [lookup].[AccountGroups]
    (
        GroupName,
        Description,
        CreatedBy,
        CreatedOn
    )
    VALUES
    (
        @GroupName,
        @Description,
        @CreatedBy,
        GETDATE()
    );

    -- Return inserted ID (optional but useful)
    SELECT SCOPE_IDENTITY() AS NewAccountGroupId;
END
GO
