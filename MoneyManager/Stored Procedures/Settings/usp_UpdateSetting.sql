CREATE PROCEDURE [lookup].[usp_UpdateSetting]
(
    @SettingId       BIGINT,
    @SectionName     VARCHAR(500),
    @SubSectionName  VARCHAR(500) = NULL,
    @Name            VARCHAR(500),
    @Value           VARCHAR(MAX),
    @Description     VARCHAR(1000) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check existence
    IF NOT EXISTS (SELECT 1 FROM [lookup].[Settings] WHERE SettingId = @SettingId)
    BEGIN
        RAISERROR('SettingId %d does not exist.', 16, 1, @SettingId);
        RETURN;
    END

    UPDATE [lookup].[Settings]
    SET 
        SectionName    = @SectionName,
        SubSectionName = @SubSectionName,
        Name           = @Name,
        Value          = @Value,
        Description    = @Description
    WHERE 
        SettingId = @SettingId;
END
GO
