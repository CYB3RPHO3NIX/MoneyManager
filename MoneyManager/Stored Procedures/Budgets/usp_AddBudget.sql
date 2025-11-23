CREATE PROCEDURE [data].[usp_AddBudget]
    @UserId BIGINT,
    @CategoryId INT,
    @SubCategoryId INT = NULL,
    @Amount DECIMAL(18, 2),
    @CreatedBy BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for duplicate budget entry for the same user, category, and subcategory
    IF EXISTS (
        SELECT 1
        FROM [data].[Budgets]
        WHERE [UserId] = @UserId
          AND [CategoryId] = @CategoryId
          AND ((@SubCategoryId IS NULL AND [SubCategoryId] IS NULL)
               OR [SubCategoryId] = @SubCategoryId)
    )
    BEGIN
        RAISERROR('A budget for the same category and subcategory already exists for this user.', 16, 1);
        RETURN;
    END

    -- Insert new budget
    INSERT INTO [data].[Budgets] (
        [UserId],
        [CategoryId],
        [SubCategoryId],
        [Amount],
        [CreatedBy],
        [CreatedOn]
    )
    VALUES (
        @UserId,
        @CategoryId,
        @SubCategoryId,
        @Amount,
        @CreatedBy,
        GETDATE()
    );
END;
