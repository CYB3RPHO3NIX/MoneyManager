CREATE PROCEDURE [data].[usp_UpdateBudget]
    @BudgetId      BIGINT,              -- Mandatory

    @UserId        BIGINT        = NULL,   -- Optional
    @CategoryId    INT           = NULL,   -- Optional
    @SubCategoryId INT           = NULL,   -- Optional
    @Amount        DECIMAL(18,2) = NULL,   -- Optional

    @UpdatedBy     BIGINT        = NULL    -- Optional
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Check if Budget exists
    -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [data].[Budgets] WHERE BudgetId = @BudgetId)
    BEGIN
        RAISERROR('Budget not found.', 16, 1);
        RETURN;
    END


    -------------------------------------------------------------------------
    -- Validate UserId only if provided
    -------------------------------------------------------------------------
    IF @UserId IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM [identity].[Users] WHERE UserId = @UserId)
    BEGIN
        RAISERROR('Invalid UserId. User does not exist.', 16, 1);
        RETURN;
    END


    -------------------------------------------------------------------------
    -- Validate CategoryId only if provided
    -------------------------------------------------------------------------
    IF @CategoryId IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM [lookup].[Categories] WHERE CategoryId = @CategoryId)
    BEGIN
        RAISERROR('Invalid CategoryId. Category does not exist.', 16, 1);
        RETURN;
    END


    -------------------------------------------------------------------------
    -- Validate SubCategoryId only if provided
    -------------------------------------------------------------------------
    IF @SubCategoryId IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM [lookup].[SubCategories] WHERE SubCategoryId = @SubCategoryId)
    BEGIN
        RAISERROR('Invalid SubCategoryId. SubCategory does not exist.', 16, 1);
        RETURN;
    END


    -------------------------------------------------------------------------
    -- Perform UPDATE using safe COALESCE logic (partial update)
    -------------------------------------------------------------------------
    UPDATE [data].[Budgets]
    SET
        UserId        = COALESCE(@UserId,        UserId),
        CategoryId    = COALESCE(@CategoryId,    CategoryId),
        SubCategoryId = COALESCE(@SubCategoryId, SubCategoryId),
        Amount        = COALESCE(@Amount,        Amount),

        UpdatedBy     = @UpdatedBy,
        UpdatedOn     = GETDATE()
    WHERE
        BudgetId = @BudgetId;
END
GO
