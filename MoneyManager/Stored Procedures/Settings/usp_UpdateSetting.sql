CREATE PROCEDURE [lookup].[usp_UpdateSetting]
    @SettingId       BIGINT,               -- Mandatory

    @SectionName     VARCHAR(500) = NULL,  -- Optional
    @SubSectionName  VARCHAR(500) = NULL,  -- Optional
    @Name            VARCHAR(500) = NULL,  -- Optional
    @Value           VARCHAR(MAX)  = NULL, -- Optional
    @Description     VARCHAR(1000) = NULL  -- Optional
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Check if setting exists
    -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [lookup].[Settings] WHERE SettingId = @SettingId)
    BEGIN
        RAISERROR('Setting not found.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Optional validation: Name should not be empty if provided
    -------------------------------------------------------------------------
    IF @Name IS NOT NULL AND LTRIM(RTRIM(@Name)) = ''
    BEGIN
        RAISERROR('Name cannot be empty.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Optional validation: SectionName cannot be empty if provided
    -------------------------------------------------------------------------
    IF @SectionName IS NOT NULL AND LTRIM(RTRIM(@SectionName)) = ''
    BEGIN
        RAISERROR('SectionName cannot be empty.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Safe PARTIAL update — only update fields that are passed
    -------------------------------------------------------------------------
    UPDATE [lookup].[Settings]
    SET
        SectionName     = COALESCE(@SectionName,     SectionName),
        SubSectionName  = COALESCE(@SubSectionName,  SubSectionName),
        Name            = COALESCE(@Name,            Name),
        Value           = COALESCE(@Value,           Value),
        Description     = COALESCE(@Description,     Description)
    WHERE 
        SettingId = @SettingId;
END
GO
