CREATE TABLE [data].[Budgets]
(
	[BudgetId] BIGINT NOT NULL PRIMARY KEY IDENTITY,
	[UserId] BIGINT NOT NULL,
	[CategoryId] INT NOT NULL,
	[SubCategoryId] INT NULL,
	[Amount] DECIMAL(18, 2) NOT NULL,

	[CreatedBy] BIGINT NULL,
	[CreatedOn] DATETIME NULL,
	[UpdatedBy] BIGINT NULL,
	[UpdatedOn] DATETIME NULL,

	CONSTRAINT FK_Budgets_Users FOREIGN KEY (UserId) REFERENCES [identity].[Users](UserId),
	CONSTRAINT FK_Budgets_Categories FOREIGN KEY (CategoryId) REFERENCES [lookup].[Categories](CategoryId),
	CONSTRAINT FK_Budgets_SubCategories FOREIGN KEY (SubCategoryId) REFERENCES [lookup].[SubCategories](SubCategoryId)
)
