codeunit 50000 "HelloWorld Test"
{
    Subtype = Test;

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
        MessageDisplayed := MessageDisplayed or (Message = 'App published: Hello world');
    end;

    [Test]
    procedure TestCustomerCreation()
    var
        Customer: Record Customer;
        IsHandled: Boolean;
        LibraryUtil: Record "Sales Line";
        CustomerNo: Code[20];
    begin
        // [GIVEN]
        // CustomerNo := cuCustomerTemplateMgt.CreateNewCustomer('Jon Doe', false);
        // IsHandled := false;
        // cuCustomerTemplateMgt.CreateCustomerFromTemplate(Customer, IsHandled);
        // Customer.create
        // Customer.Get(CustomerNo);
        // Customer.FindFirst();
        // CustomerNo := Customer."No.";
        // Customer.Get(CustomerNo);
        // if not Customer.Get() then begin
        //     Customer.Init();
        //     Customer.Name := 'Jon Doe';
        //     Customer.City := 'Test City';
        //     Customer."Country/Region Code" := 'US';
        //     Customer.Insert(true);
        // end;



        // [WHEN]
        // Customer.Name := 'Jon Doe';
        // Customer.City := 'Test City';
        // Customer."Country/Region Code" := 'US';
        // Customer.Modify(true);

        // [THEN]
        if Customer.FindFirst() then begin
            LibraryAssert.AreNotEqual('', Customer.Name, 'Customer name should not be empty');
            LibraryAssert.AreEqual('Adatum Corporation', Customer.Name, 'Customer name should match');
            LibraryAssert.AreEqual('Atlanta', Customer.City, 'City should match');
        end;

        // LibraryAssert.IsFalse();

        // if (Not Customer.Get()) then begin

        // end;
    end;

    // [ModalPageHandler]
    // procedure ModalPageHandler(var Modalpage: TestPage "Your Page")
    // begin

    // end;

    var
        // cuSales: Codeunit "Sales ";
        cuCustomerMgt: Codeunit "Customer Mgt.";
        cuCustomerTemplateMgt: Codeunit "Customer Templ. Mgt.";
        LibraryAssert: Codeunit "Library Assert";
        MessageDisplayed: Boolean;
}

