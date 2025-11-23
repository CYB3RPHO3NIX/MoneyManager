CREATE TABLE [lookup].[AccountGroups]
(
	[AccountGroupId] BIGINT NOT NULL PRIMARY KEY IDENTITY,
	[GroupName] VARCHAR(100) NOT NULL UNIQUE,
	[Description] VARCHAR(500) NULL,

	[CreatedBy] BIGINT NULL,
	[CreatedOn] DATETIME NULL,
	[UpdatedBy] BIGINT NULL,
	[UpdatedOn] DATETIME NULL
)
