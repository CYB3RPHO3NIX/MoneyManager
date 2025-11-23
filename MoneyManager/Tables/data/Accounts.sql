CREATE TABLE [data].[Accounts]
(
	[AccountId] BIGINT NOT NULL PRIMARY KEY IDENTITY,
	[UserId] BIGINT NOT NULL,
	[AccountGroupId] BIGINT NOT NULL,
	[Name] VARCHAR(200) NOT NULL,
	[Amount] DECIMAL(18,2) NOT NULL DEFAULT 0.00,
	[Description] VARCHAR(500) NULL,

	[CreatedBy] BIGINT NULL,
	[CreatedOn] DATETIME NULL,
	[UpdatedBy] BIGINT NULL,
	[UpdatedOn] DATETIME NULL,

	CONSTRAINT FK_Accounts_Users FOREIGN KEY (UserId) REFERENCES [identity].[Users](UserId),
)
