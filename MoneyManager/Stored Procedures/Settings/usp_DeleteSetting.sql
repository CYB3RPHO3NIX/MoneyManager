CREATE PROCEDURE [lookup].[usp_DeleteSetting]
(
    @SettingId BIGINT
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

    DELETE FROM [lookup].[Settings]
    WHERE SettingId = @SettingId;
END
GO
