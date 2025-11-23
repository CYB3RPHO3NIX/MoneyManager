CREATE PROCEDURE [data].[usp_DeleteTransaction]
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
    -- Delete transaction
    -------------------------------------------------------------------------
    DELETE FROM [data].[Transactions]
    WHERE [TransactionId] = @TransactionId;
END;
