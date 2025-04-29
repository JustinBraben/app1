// CustomerCreditLimit.al
codeunit 50100 "Customer Credit Manager"
{
    procedure CalculateNewCreditLimit(customer: Record Customer): Decimal
    var
        NewLimit: Decimal;
    begin
        // Basic business logic to calculate a new credit limit based on customer data
        if customer."Balance (LCY)" <= 0 then
            NewLimit := 1000  // Default starting limit for customers with no balance
        else
            NewLimit := customer."Balance (LCY)" * 2;  // Double the current balance

        // Apply rules based on customer payment history
        if customer."Payment Terms Code" = 'COD' then
            NewLimit := NewLimit * 1.2;  // 20% bonus for COD customers

        if customer."Customer Posting Group" = 'FOREIGN' then
            NewLimit := NewLimit * 0.8;  // 20% reduction for foreign customers

        // Min/max constraints
        if NewLimit < 1000 then
            NewLimit := 1000;
        if NewLimit > 100000 then
            NewLimit := 100000;

        exit(NewLimit);
    end;

    procedure UpdateCustomerCreditLimit(var customer: Record Customer): Boolean
    var
        NewLimit: Decimal;
    begin
        if customer.IsEmpty then
            exit(false);

        NewLimit := CalculateNewCreditLimit(customer);

        // Only update if it's actually different
        if customer."Credit Limit (LCY)" <> NewLimit then begin
            customer."Credit Limit (LCY)" := NewLimit;
            exit(customer.Modify(true));
        end;

        exit(true);
    end;
}