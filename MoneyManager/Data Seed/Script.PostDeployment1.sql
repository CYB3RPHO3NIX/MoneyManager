/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
EXEC [identity].usp_AddUser
    @Username = 'RootUser',
    @Email = 'root@system.local',
    @Password = 'Admin@123',
    @IsActive = 1,
    @CreatedBy = NULL;

EXEC [lookup].usp_AddSetting
    @SectionName    = 'Authentication',
    @SubSectionName = 'Access Token',
    @Name           = 'Token Expiry Minutes',
    @Value          = '10',
    @Description    = 'Access token expiry time in minutes.';