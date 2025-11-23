CREATE PROCEDURE [data].[usp_AddTransaction]
    @UserId BIGINT,
    @TransactionType VARCHAR(50),
    @Date DATE,
    @Amount DECIMAL(18, 2),
    @CategoryId INT,
    @SubCategoryId INT = NULL,
    @Note VARCHAR(MAX) = NULL,
    @CreatedBy BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Validate TransactionType
    -------------------------------------------------------------------------
    IF @TransactionType NOT IN ('Credit', 'Debit', 'Transfer')
    BEGIN
        RAISERROR('Invalid TransactionType. Allowed values: Credit, Debit, Transfer.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Insert new transaction
    -------------------------------------------------------------------------
    INSERT INTO [data].[Transactions] (
        [UserId],
        [TransactionType],
        [Date],
        [Amount],
        [CategoryId],
        [SubCategoryId],
        [Note],
        [CreatedBy],
        [CreatedOn]
    )
    VALUES (
        @UserId,
        @TransactionType,
        @Date,
        @Amount,
        @CategoryId,
        @SubCategoryId,
        @Note,
        @CreatedBy,
        GETDATE()
    );
END;
