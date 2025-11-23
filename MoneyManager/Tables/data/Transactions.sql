CREATE TABLE [data].[Transactions]
(
	[TransactionId] BIGINT NOT NULL PRIMARY KEY IDENTITY,
	[UserId] BIGINT NOT NULL,
	[TransactionType] VARCHAR(50) NOT NULL CHECK (TransactionType IN ('Credit', 'Debit', 'Transfer')),
	[Date] DATE NOT NULL,
	[Amount] DECIMAL(18, 2) NOT NULL,
	[CategoryId] INT NOT NULL,
	[SubCategoryId] INT NULL,
	[Note] VARCHAR(MAX) NULL,

	[CreatedBy] BIGINT NULL,
	[CreatedOn] DATETIME NULL,
	[UpdatedBy] BIGINT NULL,
	[UpdatedOn] DATETIME NULL,

	CONSTRAINT FK_Transactions_Users FOREIGN KEY (UserId) REFERENCES [identity].[Users](UserId),
	CONSTRAINT FK_Transactions_Categories FOREIGN KEY (CategoryId) REFERENCES [lookup].[Categories](CategoryId),
	CONSTRAINT FK_Transactions_SubCategories FOREIGN KEY (SubCategoryId) REFERENCES [lookup].[SubCategories](SubCategoryId)
)
