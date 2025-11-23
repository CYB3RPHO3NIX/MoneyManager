CREATE PROCEDURE [data].[usp_UpdateCard]
    @CardId                        BIGINT,             -- Mandatory

    @UserId                        BIGINT        = NULL,   -- Optional
    @Name                          VARCHAR(200)  = NULL,   -- Optional
    @CardNumber                    VARCHAR(50)   = NULL,   -- Optional
    @Description                   VARCHAR(500)  = NULL,   -- Optional

    @BalancePayable                DECIMAL(18,2) = NULL,   -- Optional
    @OutstandingBalance            DECIMAL(18,2) = NULL,   -- Optional
    @CreditLimit                   DECIMAL(18,2) = NULL,   -- Optional

    @NextDueDate                   DATETIME      = NULL,   -- Optional

    @InvoiceGenerationDayOfMonth   INT           = NULL,   -- Optional
    @PaymentDueDayOfMonth          INT           = NULL,   -- Optional

    @UpdatedBy                     BIGINT        = NULL    -- Optional
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Check if card exists
    -------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [data].[Cards] WHERE CardId = @CardId)
    BEGIN
        RAISERROR('Card not found.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Validate CardNumber only if provided (must be unique)
    -------------------------------------------------------------------------
    IF @CardNumber IS NOT NULL
        AND EXISTS (SELECT 1 
                    FROM [data].[Cards] 
                    WHERE CardNumber = @CardNumber 
                      AND CardId <> @CardId)
    BEGIN
        RAISERROR('CardNumber already exists for another card.', 16, 1);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- Partial update using COALESCE
    -------------------------------------------------------------------------
    UPDATE [data].[Cards]
    SET
        UserId                      = COALESCE(@UserId, UserId),
        Name                        = COALESCE(@Name, Name),
        CardNumber                  = COALESCE(@CardNumber, CardNumber),
        Description                 = COALESCE(@Description, Description),

        BalancePayable              = COALESCE(@BalancePayable, BalancePayable),
        OutstandingBalance          = COALESCE(@OutstandingBalance, OutstandingBalance),
        CreditLimit                 = COALESCE(@CreditLimit, CreditLimit),

        NextDueDate                 = COALESCE(@NextDueDate, NextDueDate),

        InvoiceGenerationDayOfMonth = COALESCE(@InvoiceGenerationDayOfMonth, InvoiceGenerationDayOfMonth),
        PaymentDueDayOfMonth        = COALESCE(@PaymentDueDayOfMonth, PaymentDueDayOfMonth),

        UpdatedBy                   = @UpdatedBy,
        UpdatedOn                   = GETDATE()
    WHERE
        CardId = @CardId;
END
GO
