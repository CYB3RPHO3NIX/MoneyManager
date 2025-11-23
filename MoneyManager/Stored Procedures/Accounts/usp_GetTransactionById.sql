CREATE PROCEDURE [data].[usp_GetTransactionById]
    @TransactionId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Validate existence
    -------------------------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1 
        FROM [data].[Transactions] 
        WHERE [TransactionId] = @TransactionId
    )
    BEGIN
        RAISERROR('Transaction not found.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Return the transaction
    -------------------------------------------------------------------------
    SELECT 
        [TransactionId],
        [UserId],
        [TransactionType],
        [Date],
        [Amount],
        [CategoryId],
        [SubCategoryId],
        [Note],
        [CreatedBy],
        [CreatedOn],
        [UpdatedBy],
        [UpdatedOn]
    FROM [data].[Transactions]
    WHERE [TransactionId] = @TransactionId;
END;
