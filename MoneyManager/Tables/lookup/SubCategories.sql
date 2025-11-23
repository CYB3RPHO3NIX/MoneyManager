CREATE TABLE [lookup].[SubCategories]
(
	[SubCategoryId] INT NOT NULL PRIMARY KEY IDENTITY,
	[CategoryId] INT NOT NULL,
	[Name] VARCHAR(200) NOT NULL UNIQUE,
	[Description] VARCHAR(500) NULL,
	
	[CreatedOn] DATETIME NULL,
	[CreatedBy] BIGINT NULL,
	[ModifiedOn] DATETIME NULL,
	[ModifiedBy] BIGINT NULL,

	CONSTRAINT FK_SubCategories_Categories FOREIGN KEY (CategoryId) REFERENCES [lookup].[Categories](CategoryId)
)