// TestCustomerCreditLimit
// HelloWorld.Test.al
codeunit 50000 "HelloWorld Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        // LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        // CreditManager: Codeunit "Customer Credit Manager";
        MessageDisplayed: Boolean;

    [Test]
    procedure TestDefaultCreditLimit()
    var
        lcuAssert: Codeunit "Library Assert";
        lcuLibrarySales: Codeunit "Library - Sales";
        lcuCreditManager: Codeunit "Customer Credit Manager";
        Customer: Record Customer;
        NewLimit: Decimal;
    begin
        // [SCENARIO] A customer with zero balance should get the default minimum credit limit

        // [GIVEN] A customer with zero balance and no special terms
        lcuLibrarySales.CreateCustomer(Customer);
        Customer."Balance (LCY)" := 0;
        Customer."Payment Terms Code" := '';  // Explicitly clear payment terms
        Customer."Customer Posting Group" := ''; // Explicitly clear posting group
        Customer.Modify();

        // [WHEN] Calculate new credit limit
        NewLimit := lcuCreditManager.CalculateNewCreditLimit(Customer);

        // [THEN] Credit limit should be the default minimum (1000)
        lcuAssert.AreEqual(1000, NewLimit, 'Default credit limit should be 1000 for zero balance');
    end;

    [Test]
    procedure TestCODCustomerBonus()
    var
        lcuAssert: Codeunit "Library Assert";
        lcuCreditManager: Codeunit "Customer Credit Manager";
        Customer: Record Customer;
        Balance: Decimal;
        NewLimit: Decimal;
        ExpectedLimit: Decimal;
    begin
        // [SCENARIO] A COD customer should get 20% extra credit limit

        // [GIVEN] A COD customer with positive balance
        Balance := LibraryRandom.RandDecInRange(5000, 10000, 2);
        CreateCustomerWithCOD(Customer, Balance);

        // [WHEN] Calculate new credit limit
        NewLimit := lcuCreditManager.CalculateNewCreditLimit(Customer);

        // [THEN] Credit limit should include 20% bonus
        ExpectedLimit := Balance * 2 * 1.2;
        lcuAssert.AreEqual(ExpectedLimit, NewLimit, 'COD customers should get 20% bonus');
    end;

    [Test]
    procedure TestForeignCustomerReduction()
    var
        lcuAssert: Codeunit "Library Assert";
        lcuCreditManager: Codeunit "Customer Credit Manager";
        Customer: Record Customer;
        Balance: Decimal;
        NewLimit: Decimal;
        ExpectedLimit: Decimal;
    begin
        // [SCENARIO] A foreign customer should get 20% lower credit limit

        // [GIVEN] A foreign customer with positive balance
        Balance := LibraryRandom.RandDecInRange(5000, 10000, 2);
        CreateForeignCustomer(Customer, Balance);

        // [WHEN] Calculate new credit limit
        NewLimit := lcuCreditManager.CalculateNewCreditLimit(Customer);

        // [THEN] Credit limit should include 20% reduction
        ExpectedLimit := Balance * 2 * 0.8;
        lcuAssert.AreEqual(ExpectedLimit, NewLimit, 'Foreign customers should get 20% reduction');
    end;

    [Test]
    procedure TestMaximumCreditLimit()
    var
        lcuAssert: Codeunit "Library Assert";
        lcuCreditManager: Codeunit "Customer Credit Manager";
        Customer: Record Customer;
        Balance: Decimal;
        NewLimit: Decimal;
    begin
        // [SCENARIO] Credit limits should be capped at 100000

        // [GIVEN] A customer with very high balance
        Balance := 100000; // Should result in limit > 100000
        CreateCustomerWithBalance(Customer, Balance);

        // [WHEN] Calculate new credit limit
        NewLimit := lcuCreditManager.CalculateNewCreditLimit(Customer);

        // [THEN] Credit limit should be capped at maximum
        lcuAssert.AreEqual(100000, NewLimit, 'Credit limit should be capped at 100000');
    end;

    [Test]
    procedure TestUpdateCustomerCreditLimit()
    var
        lcuAssert: Codeunit "Library Assert";
        lcuCreditManager: Codeunit "Customer Credit Manager";
        Customer: Record Customer;
        OldLimit: Decimal;
        NewLimit: Decimal;
        Success: Boolean;
    begin
        // [SCENARIO] UpdateCustomerCreditLimit should update a customer record

        // [GIVEN] A customer with old credit limit
        CreateCustomerWithBalance(Customer, 5000);
        OldLimit := Customer."Credit Limit (LCY)";

        // [WHEN] Update credit limit
        Success := lcuCreditManager.UpdateCustomerCreditLimit(Customer);

        // [THEN] Update should be successful
        lcuAssert.IsTrue(Success, 'Update should succeed');

        // [THEN] Credit limit should be updated
        lcuAssert.AreNotEqual(OldLimit, Customer."Credit Limit (LCY)", 'Credit limit should be changed');

        // [THEN] New limit should match expected calculation
        NewLimit := lcuCreditManager.CalculateNewCreditLimit(Customer);
        lcuAssert.AreEqual(NewLimit, Customer."Credit Limit (LCY)", 'Credit limit should match calculated value');
    end;

    [Test]
    procedure TestEmptyCustomerRecord()
    var
        lcuAssert: Codeunit "Library Assert";
        lcuCreditManager: Codeunit "Customer Credit Manager";
        Customer: Record Customer;
        Success: Boolean;
    begin
        // [SCENARIO] Update should fail for empty record

        // [GIVEN] An empty customer record
        Clear(Customer);

        // [WHEN] Try to update credit limit
        Success := lcuCreditManager.UpdateCustomerCreditLimit(Customer);

        // [THEN] Update should fail
        lcuAssert.IsFalse(Success, 'Update should fail for empty record');
    end;


    // [Test]
    // [HandlerFunctions('HelloWorldMessageHandler')]
    // procedure TestHelloWorldMessage()
    // var
    //     CustList: TestPage "Customer List";
    // begin
    //     CustList.OpenView();
    //     CustList.Close();
    //     if (not MessageDisplayed) then
    //         ERROR('Message was not displayed!');
    // end;

    // [MessageHandler]
    // procedure HelloWorldMessageHandler(Message: Text[1024])
    // begin
    //     MessageDisplayed := MessageDisplayed or (Message = 'Your App was published: Hello world');
    // end;

    // Helper methods to set up test data
    local procedure CreateCustomerWithBalance(var Customer: Record Customer; Balance: Decimal)
    var
        lcuLibrarySales: Codeunit "Library - Sales";
    begin
        lcuLibrarySales.CreateCustomer(Customer);
        Customer."Balance (LCY)" := Balance;
        Customer."Payment Terms Code" := '';  // Clear payment terms
        Customer."Customer Posting Group" := ''; // Clear posting group
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

