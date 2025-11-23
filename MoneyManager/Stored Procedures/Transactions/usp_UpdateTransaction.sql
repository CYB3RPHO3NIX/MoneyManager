CREATE PROCEDURE [data].[usp_UpdateTransaction]
    @TransactionId BIGINT,                 -- Mandatory
    @TransactionType VARCHAR(50) = NULL,   -- Optional
    @Date DATE = NULL,                     -- Optional
    @Amount DECIMAL(18, 2) = NULL,         -- Optional
    @CategoryId INT = NULL,                -- Optional
    @SubCategoryId INT = NULL,             -- Optional
    @Note VARCHAR(MAX) = NULL,             -- Optional
    @UpdatedBy BIGINT = NULL               -- Optional
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Check if transaction exists
    -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [data].[Transactions] WHERE [TransactionId] = @TransactionId)
    BEGIN
        RAISERROR('Transaction not found.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Validate TransactionType only if provided
    -------------------------------------------------------------------------
    IF @TransactionType IS NOT NULL 
        AND @TransactionType NOT IN ('Credit', 'Debit', 'Transfer')
    BEGIN
        RAISERROR('Invalid TransactionType. Allowed: Credit, Debit, Transfer.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Update transaction (only non-null values)
    -------------------------------------------------------------------------
    UPDATE [data].[Transactions]
    SET
        [TransactionType] = COALESCE(@TransactionType, [TransactionType]),
        [Date]            = COALESCE(@Date, [Date]),
        [Amount]          = COALESCE(@Amount, [Amount]),
        [CategoryId]      = COALESCE(@CategoryId, [CategoryId]),
        [SubCategoryId]   = COALESCE(@SubCategoryId, [SubCategoryId]),
        [Note]            = COALESCE(@Note, [Note]),
        [UpdatedBy]       = @UpdatedBy,
        [UpdatedOn]       = GETDATE()
    WHERE
        [TransactionId] = @TransactionId;
END;
