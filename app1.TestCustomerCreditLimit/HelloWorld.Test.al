codeunit 50000 "HelloWorld Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
        MessageDisplayed: Boolean;
        CreditManager: Codeunit "Customer Credit Manager";

    [Test]
    procedure TestDefaultCreditLimit()
    var
        Customer: Record Customer;
        NewLimit: Decimal;
    begin
        // [SCENARIO] A customer with zero balance should get the default minimum credit limit

        // [GIVEN] A customer with zero balance
        CreateCustomerWithBalance(Customer, 0);

        // [WHEN] Calculate new credit limit
        NewLimit := CreditManager.CalculateNewCreditLimit(Customer);

        // [THEN] Credit limit should be the default minimum (1000)
        Assert.AreEqual(1000, NewLimit, 'Default credit limit should be 1000 for zero balance');
    end;


    [Test]
    [HandlerFunctions('HelloWorldMessageHandler')]
    procedure TestHelloWorldMessage()
    var
        CustList: TestPage "Customer List";
    begin
        CustList.OpenView();
        CustList.Close();
        if (not MessageDisplayed) then
            ERROR('Message was not displayed!');
    end;

    [MessageHandler]
    procedure HelloWorldMessageHandler(Message: Text[1024])
    begin
        MessageDisplayed := MessageDisplayed or (Message = 'Your App was published: Hello world');
    end;

    // Helper methods to set up test data
    local procedure CreateCustomerWithBalance(var Customer: Record Customer; Balance: Decimal)
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer."Balance (LCY)" := Balance;
        Customer.Modify();
    end;

    local procedure CreateCustomerWithCOD(var Customer: Record Customer; Balance: Decimal)
    begin
        CreateCustomerWithBalance(Customer, Balance);
        Customer."Payment Terms Code" := 'COD';
        Customer.Modify();
    end;

    local procedure CreateForeignCustomer(var Customer: Record Customer; Balance: Decimal)
    begin
        CreateCustomerWithBalance(Customer, Balance);
        Customer."Customer Posting Group" := 'FOREIGN';
        Customer.Modify();
    end;
}

