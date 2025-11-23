CREATE PROCEDURE [data].[usp_AddCard]
    @UserId BIGINT,
    @Name VARCHAR(200),
    @CardNumber VARCHAR(50),
    @Description VARCHAR(500) = NULL,
    @BalancePayable DECIMAL(18,2) = 0.00,
    @OutstandingBalance DECIMAL(18,2) = 0.00,
    @CreditLimit DECIMAL(18,2) = 0.00,
    @NextDueDate DATETIME = NULL,
    @InvoiceGenerationDayOfMonth INT = NULL,
    @PaymentDueDayOfMonth INT = NULL,
    @CreatedBy BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for duplicate card number
    IF EXISTS (
        SELECT 1
        FROM [data].[Cards]
        WHERE [CardNumber] = @CardNumber
    )
    BEGIN
        RAISERROR('A card with the same card number already exists.', 16, 1);
        RETURN;
    END

    -- Insert new card record
    INSERT INTO [data].[Cards] (
        [UserId],
        [Name],
        [CardNumber],
        [Description],
        [BalancePayable],
        [OutstandingBalance],
        [CreditLimit],
        [NextDueDate],
        [InvoiceGenerationDayOfMonth],
        [PaymentDueDayOfMonth],
        [CreatedBy],
        [CreatedOn]
    )
    VALUES (
        @UserId,
        @Name,
        @CardNumber,
        @Description,
        @BalancePayable,
        @OutstandingBalance,
        @CreditLimit,
        @NextDueDate,
        @InvoiceGenerationDayOfMonth,
        @PaymentDueDayOfMonth,
        @CreatedBy,
        GETDATE()
    );
END;
