CREATE TABLE [lookup].[Categories]
(
	[CategoryId] INT NOT NULL PRIMARY KEY IDENTITY,
	[Name] VARCHAR(200) NOT NULL UNIQUE,
	[Description] VARCHAR(500) NULL,
	
	[CreatedOn] DATETIME NULL,
	[CreatedBy] BIGINT NULL,
	[ModifiedOn] DATETIME NULL,
	[ModifiedBy] BIGINT NULL
)
