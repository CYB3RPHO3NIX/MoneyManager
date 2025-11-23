CREATE TABLE [data].[Cards]
(
	[CardId] BIGINT NOT NULL PRIMARY KEY IDENTITY,
	[UserId] BIGINT NOT NULL,
	[Name] VARCHAR(200) NOT NULL,
	[CardNumber] VARCHAR(50) NOT NULL UNIQUE,
	[Description] VARCHAR(500) NULL,

	[BalancePayable] DECIMAL(18,2) NOT NULL DEFAULT 0.00,
	[OutstandingBalance] DECIMAL(18,2) NOT NULL DEFAULT 0.00,
	[CreditLimit] DECIMAL(18,2) NOT NULL DEFAULT 0.00,

	[NextDueDate] DATETIME NULL,

	[InvoiceGenerationDayOfMonth] INT NULL,
	[PaymentDueDayOfMonth] INT NULL,

	[CreatedBy] BIGINT NULL,
	[CreatedOn] DATETIME NULL,
	[UpdatedBy] BIGINT NULL,
	[UpdatedOn] DATETIME NULL,

	CONSTRAINT FK_Cards_Users FOREIGN KEY (UserId) REFERENCES [identity].[Users](UserId),
)
