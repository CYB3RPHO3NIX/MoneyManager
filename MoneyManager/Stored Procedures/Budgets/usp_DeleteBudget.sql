CREATE PROCEDURE [data].[usp_DeleteBudget]
    @BudgetId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Check if budget exists
    -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [data].[Budgets] WHERE BudgetId = @BudgetId)
    BEGIN
        RAISERROR('Budget not found.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Perform DELETE
    -------------------------------------------------------------------------
    DELETE FROM [data].[Budgets]
    WHERE BudgetId = @BudgetId;
END
GO
