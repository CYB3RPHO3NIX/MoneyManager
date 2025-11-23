CREATE PROCEDURE [lookup].[usp_AddSetting]
(
    @SectionName     VARCHAR(500),
    @SubSectionName  VARCHAR(500) = NULL,
    @Name            VARCHAR(500),
    @Value           VARCHAR(MAX),
    @Description     VARCHAR(1000) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Check duplicates (atomic check)
        IF EXISTS (
            SELECT 1
            FROM lookup.Settings WITH (UPDLOCK, HOLDLOCK)
            WHERE SectionName = @SectionName
              AND ISNULL(SubSectionName, '') = ISNULL(@SubSectionName, '')
              AND Name = @Name
        )
        BEGIN
            ROLLBACK TRAN;
            RAISERROR('A setting with the same SectionName, SubSectionName, and Name already exists.', 16, 1);
            RETURN;
        END

        -- Insert new setting
        INSERT INTO [lookup].[Settings]
        (
            SectionName,
            SubSectionName,
            Name,
            Value,
            Description
        )
        VALUES
        (
            @SectionName,
            @SubSectionName,
            @Name,
            @Value,
            @Description
        );

        DECLARE @NewSettingId BIGINT = SCOPE_IDENTITY();

        COMMIT TRAN;

        -- Return only via SELECT (no output parameter)
        SELECT @NewSettingId AS SettingId;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRAN;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('usp_AddSetting failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO
