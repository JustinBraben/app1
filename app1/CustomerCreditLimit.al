// CustomerCreditLimit.al
codeunit 50100 "Customer Credit Manager"
{
    procedure CalculateNewCreditLimit(customer: Record Customer): Decimal
    var
        NewLimit: Decimal;
        CustomerAge: Integer;
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

        // Apply loyalty bonus based on customer age
        CustomerAge := CalculateCustomerAgeInYears(customer);
        if CustomerAge >= 5 then
            NewLimit := NewLimit * (1 + (CustomerAge * 0.02));  // 2% increase per year, max 10 years (20%)
            
        // Premium customer bonus
        if IsPremiumCustomer(customer) then
            NewLimit := NewLimit * 1.5;  // 50% bonus for premium customers

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
        OldLimit: Decimal;
    begin
        if customer.IsEmpty then
            exit(false);

        OldLimit := customer."Credit Limit (LCY)";
        NewLimit := CalculateNewCreditLimit(customer);

        // Only update if it's actually different
        if OldLimit <> NewLimit then begin
            customer."Credit Limit (LCY)" := NewLimit;
            
            // Notify if significant change (>25%)
            if (Abs(NewLimit - OldLimit) / OldLimit > 0.25) and (OldLimit > 0) then
                LogSignificantCreditChange(customer, OldLimit, NewLimit);
                
            exit(customer.Modify(true));
        end;

        exit(true);
    end;

    procedure BatchUpdateCreditLimits(var TempCustomer: Record Customer temporary): Integer
    var
        Customer: Record Customer;
        UpdatedCount: Integer;
    begin
        UpdatedCount := 0;
        
        if TempCustomer.FindSet() then
            repeat
                if Customer.Get(TempCustomer."No.") then
                    if UpdateCustomerCreditLimit(Customer) then
                        UpdatedCount += 1;
            until TempCustomer.Next() = 0;
            
        exit(UpdatedCount);
    end;
    
    local procedure CalculateCustomerAgeInYears(customer: Record Customer): Integer
    var
        Setup: Record "Sales & Receivables Setup";
        DateFormula: DateFormula;
    begin
        if customer."Creation Date" = 0D then
            exit(0);
            
        exit(Round((WorkDate() - customer."Creation Date") / 365.25, 1, '<'));
    end;
    
    local procedure IsPremiumCustomer(customer: Record Customer): Boolean
    begin
        // Premium status based on customer category code
        exit(customer."Customer Posting Group" = 'PREMIUM');
    end;
    
    local procedure LogSignificantCreditChange(customer: Record Customer; OldLimit: Decimal; NewLimit: Decimal)
    var
        CreditChangeLog: Record "Credit Limit Change Log";
    begin
        CreditChangeLog.Init();
        CreditChangeLog."Entry No." := 0;  // Autoincrement
        CreditChangeLog."Customer No." := customer."No.";
        CreditChangeLog."Change Date" := WorkDate();
        CreditChangeLog."Old Credit Limit" := OldLimit;
        CreditChangeLog."New Credit Limit" := NewLimit;
        CreditChangeLog."Change Percentage" := Round((NewLimit - OldLimit) / OldLimit * 100, 0.01);
        CreditChangeLog."User ID" := UserId;
        CreditChangeLog.Insert(true);
    end;
}